#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# 填写自己的路径
TP="/Applications/TexturePacker.app/Contents/MacOS/TexturePacker"


#项目res路径
DIR_ROOT="$DIR/../../../laiya_tianzhu_src_client/res/images"
#cocos builder 项目路径
CCB_ROOT="$DIR/../../UiProject/Resources/images"

# #本地路径名
Local_DIR=${1}
# #文件名称
File_Name=${2}

echo $Local_DIR
echo $File_Name

echo "building Images"

# --premultiply-alpha \ 这个参数可以消除白边，但对白色透明变黑
# --dither-atkinson-alpha \

# --content-protection 5abc11740879b2ff6d36f2c9d4d7d088 \

echo "building Images "
${TP} --smart-update \
--texture-format pvr2ccz \
--format cocos2d \
--enable-rotation \
--padding 2 \
--shape-padding 2 \
--trim-mode None \
--scale 1.0 \
--max-width 4096 \
--max-height 4096 \
--data  "$DIR_ROOT"/"$File_Name".plist \
--sheet "$DIR_ROOT"/"$File_Name".pvr.ccz \
--size-constraints AnySize \
--opt RGBA8888 \
--dither-atkinson-alpha \
"$Local_DIR"/*.png

#生成到ccb路径中
echo "building ccb..."
${TP} --smart-update \
--texture-format pvr2ccz \
--format cocos2d \
--enable-rotation \
--padding 2 \
--shape-padding 2 \
--max-width 4096 \
--max-height 4096 \
--trim-mode None \
--scale 1.0 \
--data  "$CCB_ROOT"/"$File_Name".plist \
--sheet "$CCB_ROOT"/"$File_Name".pvr.ccz \
--size-constraints AnySize \
--opt RGBA8888 \
--dither-atkinson-alpha \
"$Local_DIR"/*.png

