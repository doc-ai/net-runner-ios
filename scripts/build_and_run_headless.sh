#!/bin/bash

# located in $PROJECT_DIR/scripts

PROJECT_DIR="$(pwd)/.."
WORKSPACE="$PROJECT_DIR/Net Runner.xcworkspace"
TARGET="Net Runner"
SCHEME="Net Runner Headless"
DSTROOT="$PROJECT_DIR/build"
SYMROOT="$PROJECT_DIR/build"
APP_BUNDLE="$PROJECT_DIR/build/Debug Headless-iphoneos/Net Runner.app"

# clean

rm -r "$DSTROOT"
mkdir "$DSTROOT"

# build

xcodebuild build -workspace "$WORKSPACE" -scheme "$SCHEME" SYMROOT="$SYMROOT" DSTROOT="$DSTROOT"

# deploy 
# https://github.com/ios-control/ios-deploy

ios-deploy --debug --no-wifi --uninstall --justlaunch --bundle "$APP_BUNDLE"
