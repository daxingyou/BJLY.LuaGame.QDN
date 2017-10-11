#!/bin/bash
CUR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $CUR_PATH #当前文件夹路径


# 填写自己的路径
TP="/Applications/TexturePacker.app/Contents/MacOS/TexturePacker"

#项目res路径
DIR_ROOT="$CUR_PATH/../../../laiya_tianzhu_src_client/res/images"
#cocos builder 项目路径
CCB_ROOT="$CUR_PATH/../../UiProject/Resources/images"

# --premultiply-alpha \ #这个参数可以消除白边，但对白色透明变黑
# --dither-atkinson-alpha \

# --content-protection 5abc11740879b2ff6d36f2c9d4d7d088 \ #这个参数是图片加密
function PackTextures(){
	if [ -f "${TP}" ]; then
		echo "building Images... ${2}--${1} "

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
		--data  "${2}"/"${1}".plist \
		--sheet "${2}"/"${1}".pvr.ccz \
		--size-constraints AnySize \
		--opt RGBA8888 \
		--dither-atkinson-alpha \
		"${1}"/*.png
		echo "--------- ${2}--${1} \n\n"
	else
	    #if here the TexturePacker command line file could not be found
	    echo "TexturePacker tool not installed in ${TP}"
	    echo "skipping requested operation."
	    exit 1
	fi
}

#对当前目录下的子文件下的png文件进行合图操作
for dir in `ls` ;do
	if [ -d $dir ];then
		num="$(ls -l ${dir} | grep '.png' | wc -l)"
		if (($num > 0));then
			PackTextures $dir $DIR_ROOT
			PackTextures $dir $CCB_ROOT
		fi
	fi
done


echo "\n\nCUR_PATH=${CUR_PATH}"
echo "------------PackTextures over-----------------"

