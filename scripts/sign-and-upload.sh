#!/bin/sh

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
#   echo "This is a pull request. No deployment will be done."
#   exit 0
# fi
# if [[ "$TRAVIS_BRANCH" != "master" ]]; then
#   echo "Testing on a branch other than master. No deployment will be done."
#   exit 0
# fi

gem install shenzhen
ipa build
ipa distribute:itunesconnect -a derrick.showers@me.com -p $ITUNES_PASSWORD -i 951556200 --verbose
