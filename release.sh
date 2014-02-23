#!/bin/bash

set -e
xctool -workspace BeardedSpice.xcworkspace -scheme BeardedSpice -configuration RELEASE archive
