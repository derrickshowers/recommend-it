#!/bin/sh

KEY_CHAIN=ios-build.keychain

# Create a custom keychain
security create-keychain -p travis $KEY_CHAIN

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s $KEY_CHAIN

# Unlock the keychain
security unlock-keychain -p travis $KEY_CHAIN

# Set keychain timeout to 1 hour for long builds
# see http://www.egeek.me/2013/02/23/jenkins-and-xcode-user-interaction-is-not-allowed/
security set-keychain-settings -t 3600 -u $KEY_CHAIN

# Add certificates to keychain and allow codesign to access them
security import ./CI/certs/development.p12 -k $KEY_CHAIN -P $KEY_PASSWORD -T /usr/bin/codesign
security import ./CI/certs/distribution.p12 -k $KEY_CHAIN -P $KEY_PASSWORD -T /usr/bin/codesign

# Remove UI prompt causing build to timeout
# http://stackoverflow.com/questions/39868578/security-codesign-in-sierra-keychain-ignores-access-control-settings-and-ui-p
security set-key-partition-list -S apple-tool:,apple: -s -k travis $KEY_CHAIN

# Put the provisioning profile in place
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "./CI/profile/XC_iOS_comderrickshowersRecommendIt_Development.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
cp "./CI/profile/XC_iOS_comderrickshowersRecommendIt_Distribution.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
