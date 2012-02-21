#!/usr/bin/env bash

usage() {
  echo "Please install a system ruby first:"
  echo "  On debian/ubuntu:"
  echo "    aptitude update"
  echo "    aptitude install -y ruby1.9.1 ruby1.9.1-dev make"
  echo "    gem1.9.1 install --no-rdoc --no-ri chef"
  echo "  On darwin:"
  echo "    sudo chown -R $(whoami):staff /usr/local"
  echo "    sudo gem install --no-rdoc --no-ri chef"
  exit 1
}


RUBY="$(which ruby)"
if [ -e "$RUBY" ]
then
  echo "Using ruby: $RUBY"
else
  usage
  exit 1
fi

CHEF="$(which chef-solo)"
if [ -e "$CHEF" ]
then
  echo "Using chef: $CHEF"
else
  usage
  exit 1
fi

if [ "$(uname -s)" = "Darwin" ]
then
  BREW="$(which brew)"
  if [ -e "$BREW" ]
  then
    echo "Using brew: $BREW"
  else
    usage
    exit 1
  fi
fi

export ROOT=$(pwd)
echo "At root:    $ROOT"

exec "$CHEF" -c env/chef/solo.rb
