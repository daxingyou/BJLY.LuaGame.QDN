#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# CMP_PATH=$QUICK_V3_ROOT/quick/bin
CMP_PATH="$DIR/quick//bin"
SRC_PATH=$DIR/../src
#CLIENT_VER=1.0.0
OUT_PATH=$DIR/../res/sc
MYSIG="LAIYAGAME"
MYKEY="L@Y#G^^"

cd $CMP_PATH
# ./compile_scripts.sh  -i $SRC_PATH -x main,config,cocos,framework -o $OUT_PATH/game.tg -e xxtea_zip -es $MYSIG -ek $MYKEY

./compile_scripts.sh  -m files -i $SRC_PATH -x main,config,cocos,framework -o $OUT_PATH/ -e xxtea_chunk -es $MYSIG -ek $MYKEY

# ./compile_scripts.sh -m files -i "/Users/xujian/laiya_src_lua_client/export_diff/src" -o "/Users/xujian/laiya_src_lua_client/export_vn/1/src" -e xxtea_chunk -ek "L@Y#G^^" -es "LAIYAGAME"