#!/usr/bin/env bash

set -xu
cd "`dirname "$0"`/.."

PROJECT_NAME=unweighted

rm exports/$PROJECT_NAME-web.zip
rm exports/web/*

godot --headless --export-release Web
cd exports/web
mv $PROJECT_NAME.html index.html
zip -r ../$PROJECT_NAME-web.zip *
gzip -k9 $PROJECT_NAME.wasm
