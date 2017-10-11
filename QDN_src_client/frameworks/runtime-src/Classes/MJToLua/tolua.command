#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYDIR="$DIR/../../../cocos2d-x/tools/tolua"
cd $PYDIR
python my.py

