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
PACKER_RUN_FOLDER="packer-run/$TIMESTAMP"

if [ -z "$ENV_FILE" ]; then
  echo "ERROR: .env file not specified
  You must run: ./run-packer.sh [.env file]"
  exit
fi

. $ENV_FILE

# Create Packer Run folder
mkdir -p $PACKER_RUN_FOLDER
cd $PACKER_RUN_FOLDER

echo "run-packer.sh started - `date`" >> packer-run.log
rm $ROOT_FOLDER/packer-run/latest.log
rm $ROOT_FOLDER/packer-run/latest-run
ln -s $PWD/packer-run.log $ROOT_FOLDER/packer-run/latest.log
ln -s $PWD $ROOT_FOLDER/packer-run/latest-run

#Determine Github SSH or HTTPS endpoints
if [ "$GITHUB_ENDPOINT_TYPE" -eq "https" ]; then
  GITHUB_PREFIX="https://github.com/"
fi

# Download packer-common.rb and ks.cfg
if [ -n "$GITHUB_PACKER_REPO" ]; then
  git clone $GITHUB_PREFIX$GITHUB_PACKER_REPO.git packer_common_checkout >> packer-run.log
  cd packer_common_checkout
  git checkout $GITHUB_PACKER_VERSION >> ../packer-run.log
  cd -

  export KS_DIRECTORY=./packer_common_checkout/$GITHUB_PACKER_REL_PATH
  PACKER_BUILDER_TPL=./packer_common_checkout/$GITHUB_PACKER_REL_PATH/packer-builder-$PACKER_BUILDER_TPL_NAME.rb
  PACKER_PROVISIONER_TPL=./packer_common_checkout/$GITHUB_PACKER_REL_PATH/packer-provisioner-$PACKER_PROVISIONER_TPL_NAME.rb
fi

# Download data_bags
if [ -n "$GITHUB_DATABAGS_REPO" ]; then
  git clone $GITHUB_PREFIX$GITHUB_DATABAGS_REPO.git databags_checkout >> packer-run.log
  cd databags_checkout
  git checkout $GITHUB_DATABAGS_VERSION  >> packer-run.log
  rm -f *
  cd -

  export DATA_BAGS_PATH=./databags_checkout/$GITHUB_DATABAGS_REL_PATH
fi

# Installs racker command
RACKER_GEM=`gem list | grep "racker (0.1.6)"`
if [ -z "$RACKER_GEM" ]; then
  gem install racker >> packer-run.log
else
  echo "racker gem 0.1.6 already installed" >> packer-run.log
fi

# Resolves all Chef cookbooks needed for provisioning in the local berks-cookbooks folder
rm -Rf $BERKS_FILE.lock
berks vendor -b $BERKS_FILE >> packer-run.log

# Generate Packer JSON Template, from Racker .rb files
racker $PACKER_BUILDER_TPL $PACKER_PROVISIONER_TPL $PACKER_INSTANCE_TPL packer.json >> packer-run.log

export PACKER_CACHE_DIR

DEBUG=""
if [ "$PACKER_LOG"="1" ]; then
  DEBUG="-debug"
fi

$PACKER_BIN build $DEBUG packer.json >> packer-run.log
# TODO - upload Vagrant box somewhere inside VPN boundaries

echo "run-packer.sh finished - `date`" >> packer-run.log

cd $ROOT_FOLDER
