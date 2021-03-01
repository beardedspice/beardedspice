#!/bin/bash

curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Stillness-2/beardie/releases/latest | python3 -c 'import sys, json; dict=(json.load(sys.stdin)); print("\n".join([ "Downloads {} = {}".format(asset["name"], asset["download_count"]) for asset in dict["assets"]]))'