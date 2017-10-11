#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#主文件夹

#生成对应的lua数据表
cd $DIR
python py/x2lua.py 音频列表.xlsx card 0
python py/x2lua.py 音频列表.xlsx operate 1
python py/x2lua.py 音频列表.xlsx music 2
python py/x2lua.py 音频列表.xlsx sound 3

#合成
python py/luaMerge.py audio_config True card operate music sound