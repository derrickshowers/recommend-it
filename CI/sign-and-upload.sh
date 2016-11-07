#!/bin/sh

# if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
#   echo "This is a pull request. No deployment will be done."
#   exit 0
# fi
# if [[ "$TRAVIS_BRANCH" != "master" ]]; then
#   echo "Testing on a branch other than master. No deployment will be done."
#   exit 0
# fi

# Install shenzhen for `ipa distribute`
gem install shenzhen

# Archive and package as IPA
xcodebuild -workspace Recommend-It.xcworkspace -scheme Recommend-It -sdk iphoneos -configuration AppStoreDistribution archive -archivePath ./build/Recommend-It.xcarchive
xcodebuild -exportArchive -archivePath ./build/Recommend-It.xcarchive -exportOptionsPlist ./CI/exportOptions.plist -exportPath ./build

# Send to iTunes connect
ipa distribute:itunesconnect -a derrick.showers@me.com -p $ITUNES_PASSWORD -i 951556200 -f ./build/Recommend-It.ipa --upload --verbose
