#!/bin/bash
#
# run-packer [.env file]
# .env file must define some variables, read below.
#
# Hereby the list of actions performed by this script.
# 1. Downloads packer-common, containing files that are commonly needed by Packer build:
# 1.1 packer-common.rb
# 1.2 ks.cfg
# 2. Runs provided ($1) .env shell script for variable definition
# 3. Creates packer-run-$TIMESTAMP folder containing packer-run.log and other run data
# 4. Runs Berkshelf resolving all Chef cookbooks; $BERKS_FILE is used to locate Berksfile
# 5. Downloads Chef databags, using the following variables:
# GITHUB_DATABAGS_REPO=<my-github-user>/<my-databags-project>
# GITHUB_DATABAGS_VERSION=master
# GITHUB_DATABAGS_REL_PATH=test/integration/data_bags
# 6. Download Packer Common from Github; the following variables are required:
# GITHUB_PACKER_REPO=<my-github-user>/<my-packer-common-project>
# GITHUB_PACKER_VERSION=master
# GITHUB_PACKER_REL_PATH=packer-common
# 7. Compose Packer final template (using Racker) as follows: PACKER_BUILDER_TPL + PACKER_PROVISIONER_TPL + PACKER_INSTANCE_TPL; the following variables are required:
# PACKER_BUILDER_TPL_NAME=vbox-iso #Looks for $GITHUB_PACKER_REL_PATH/packer-builder-$PACKER_BUILDER_TPL_NAME.rb Racker template in Packer Common
# PACKER_PROVISIONER_TPL_NAME=chef #Looks for $GITHUB_PACKER_REL_PATH/packer-provisioner-$PACKER_PROVISIONER_TPL_NAME.rb Racker template in Packer Common
# PACKER_INSTANCE_TPL=$ROOT_FOLDER/packer.rb #Defines the path of a custom Racker template
# 8. Run Packer builder (specified by $2)
# PACKER_CACHE_DIR allows you to specify a reusable packer_cache folder
# PACKER_LOG=1 shows Packer debugging messages
TIMESTAMP=`date +%s`
ENV_FILE=$1
ROOT_FOLDER=`pwd`
GITHUB_ENDPOINT_TYPE="ssh"
GITHUB_PREFIX="git@github.com:"

if [ -z "$PACKER_BIN" ]; then
  export PACKER_BIN=packer
fi

WORKING_DIR=/tmp
PACKER_RUN_ROOT_FOLDER="$WORKING_DIR/packer-run"
PACKER_RUN_FOLDER="$PACKER_RUN_ROOT_FOLDER/$TIMESTAMP"
PACKER_RUN_LOG="$PACKER_RUN_FOLDER/packer-run.log"

if [ -z "$ENV_FILE" ]; then
  echo "ERROR: .env file not specified
  You must run: ./run-packer.sh [.env file]"
  exit
fi

. $ENV_FILE

# Create Packer Run folder
mkdir -p $PACKER_RUN_FOLDER
cd $PACKER_RUN_FOLDER

echo "run-packer.sh started - `date`" >> $PACKER_RUN_LOG
rm $PACKER_RUN_ROOT_FOLDER/latest.log
rm $PACKER_RUN_ROOT_FOLDER/latest-run
ln -s $PACKER_RUN_FOLDER/packer-run.log $PACKER_RUN_ROOT_FOLDER/latest.log
ln -s $PACKER_RUN_FOLDER $PACKER_RUN_ROOT_FOLDER/latest-run

#Determine Github SSH or HTTPS endpoints
if [ "$GITHUB_ENDPOINT_TYPE" = "https" ]; then
  GITHUB_PREFIX="https://github.com/"
fi

# Download packer-common.rb and ks.cfg
if [ -n "$GITHUB_PACKER_REPO" ]; then
  echo "Checking out Github repo: $GITHUB_PREFIX$GITHUB_PACKER_REPO.git" >> $PACKER_RUN_LOG
  git clone $GITHUB_PREFIX$GITHUB_PACKER_REPO.git packer_common_checkout >> $PACKER_RUN_LOG
  cd packer_common_checkout
  git checkout $GITHUB_PACKER_VERSION >> $PACKER_RUN_LOG
  cd -

  export KS_DIRECTORY=$PACKER_RUN_FOLDER/packer_common_checkout/$GITHUB_PACKER_REL_PATH
  PACKER_BUILDER_TPL=$PACKER_RUN_FOLDER/packer_common_checkout/$GITHUB_PACKER_REL_PATH/packer-builder-$PACKER_BUILDER_TPL_NAME.rb
  PACKER_PROVISIONER_TPL=$PACKER_RUN_FOLDER/packer_common_checkout/$GITHUB_PACKER_REL_PATH/packer-provisioner-$PACKER_PROVISIONER_TPL_NAME.rb
fi

# Download data_bags
if [ -n "$GITHUB_DATABAGS_REPO" ]; then
  echo "Checking out Github repo: $GITHUB_PREFIX$GITHUB_DATABAGS_REPO.git" >> $PACKER_RUN_LOG
  git clone $GITHUB_PREFIX$GITHUB_DATABAGS_REPO.git databags_checkout >> $PACKER_RUN_LOG
  cd databags_checkout
  git checkout $GITHUB_DATABAGS_VERSION  >> $PACKER_RUN_LOG
  cd -

  export DATA_BAGS_PATH=$PACKER_RUN_FOLDER/databags_checkout/$GITHUB_DATABAGS_REL_PATH
  echo "Final Databags Path is $DATA_BAGS_PATH" >> $PACKER_RUN_LOG
fi

# Installs racker command
RACKER_GEM=`gem list | grep "racker (0.1.6)"`
if [ -z "$RACKER_GEM" ]; then
  gem install racker >> $PACKER_RUN_LOG
else
  echo "racker gem 0.1.6 already installed" >> $PACKER_RUN_LOG
fi

# Resolves all Chef cookbooks needed for provisioning in the local berks-cookbooks folder
rm -Rf $BERKS_FILE.lock
berks vendor -b $BERKS_FILE >> $PACKER_RUN_LOG

# Generate Packer JSON Template, from Racker .rb files
racker $PACKER_BUILDER_TPL $PACKER_PROVISIONER_TPL $PACKER_INSTANCE_TPL packer.json >> $PACKER_RUN_LOG

export PACKER_CACHE_DIR

DEBUG=""
if [ "$PACKER_LOG" = "1" ]; then
  DEBUG="-debug"
fi

$PACKER_BIN build $DEBUG packer.json >> $PACKER_RUN_LOG
# TODO - upload Vagrant box somewhere inside VPN boundaries

echo "run-packer.sh finished - `date`" >> $PACKER_RUN_LOG

cd $ROOT_FOLDER
