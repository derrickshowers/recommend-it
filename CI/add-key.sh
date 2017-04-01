#!/bin/sh

KEY_CHAIN=ios-build.keychain
CERTS_DIR=./CI/certs/
PROFILE_DIR=./CI/profile/

# Decrypt certs and provisioning profiles
openssl aes-256-cbc -k "$ENCRYPTION_SECRET_PROVISIONING_PROFILE" -in ${PROFILE_DIR}RecommendIt_Development.enc -d -a -out ${PROFILE_DIR}RecommendIt_Development.mobileprovision
openssl aes-256-cbc -k "$ENCRYPTION_SECRET_PROVISIONING_PROFILE" -in ${PROFILE_DIR}RecommendIt_Distribution.enc -d -a -out ${PROFILE_DIR}RecommendIt_Distribution.mobileprovision
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in ${CERTS_DIR}development.cer.enc -d -a -out ${CERTS_DIR}development.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in ${CERTS_DIR}distribution.cer.enc -d -a -out ${CERTS_DIR}distribution.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in ${CERTS_DIR}development.p12.enc -d -a -out ${CERTS_DIR}development.p12
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in ${CERTS_DIR}distribution.p12.enc -d -a -out ${CERTS_DIR}distribution.p12

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
cp "${PROFILE_DIR}RecommendIt_Development.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
cp "${PROFILE_DIR}RecommendIt_Distribution.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
