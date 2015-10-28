#!/bin/bash

# Locate gem executables
export PATH=/usr/local/packer:/opt/apache-maven/bin:/Users/Shared/apache-maven/3.2.3/bin:$HOME/.chefdk/gem/ruby/2.1.0/bin:/opt/chefdk/bin:/opt/chefdk/embedded/bin:$PATH

# Fetching Gemfile, containing all gems used below for linting and testing
curl -L https://raw.githubusercontent.com/Alfresco/packer-common/master/chef/Gemfile --no-sessionid > Gemfile

# Installing gems in the user $HOME
bundle update --user

# Running All checks per types
find . -name "*.erb" -exec rails-erb-check {} \;
find . -name "*.json" -exec jsonlint {} \;
find . -name "*.rb" -exec ruby -c {} \;
find . -name "*.yml" -not -path "./.kitchen.yml" -exec yaml-lint {} \;

# Run knife, foodcritic and rubocop, if this is a Chef recipe
if [ -d './recipes' ]
then
  knife cookbook test cookbook -o ./ -a
  foodcritic -f any .
  # Next one should use warning as fail-level, printing only the progress review
  rubocop --fail-level warn | sed -n 2p
fi
