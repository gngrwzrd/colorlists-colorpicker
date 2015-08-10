#!/bin/sh
VERSION=$1
mkdir -p release
pkgbuild --component "Color Lists/build/Release/Color Lists.colorPicker" --install-location /Library/ColorPickers "release/ColorLists-$VERSION.pkg"
