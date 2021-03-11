#!/bin/bash

#  extruct-pause-names.sh
#  Beardie
#
#  Created by Roman Sokolov on 11.03.2021.
#  Copyright © 2021 GPL v3 http://www.gnu.org/licenses/gpl.html

TMP_DIR=/tmp/asar/extruct/deezer
LOCALES="$TMP_DIR/locales"

OUTPUT=$(dirname $0)/Deezer-Pause-Names.h
echo "#define DEEZZER_PAUSE_NAMES @[\\" > "$OUTPUT"

npx asar extract "$1/Contents/Resources/app.asar" "$TMP_DIR"
for f in "$LOCALES/"*.json;
do
cat "$f" | python3 -c 'import sys, json; dict=(json.load(sys.stdin)); print("@\"{}\",\\".format(dict["menu_pause_label"]))' >> "$OUTPUT"
done

echo "]" >> "$OUTPUT"
