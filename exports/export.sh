#!/usr/bin/env bash

set -xu
cd "`dirname "$0"`/.."

PROJECT_NAME=unweighted

rm exports/*.zip
rm exports/*.tar.gz
rm exports/*.dmg
rm exports/linux/*
rm exports/win/*
rm exports/mac/*

./exports/export-web.sh

godot --headless --export-release Windows
cd exports/win
zip -r ../$PROJECT_NAME-win.zip *
cd -

godot --headless --export-release Linux
cd exports/linux
tar -caf ../$PROJECT_NAME-linux.tar.gz *
cd -

godot --headless --export-release macOS
cp exports/mac/$PROJECT_NAME.dmg exports/$PROJECT_NAME-mac.dmg
