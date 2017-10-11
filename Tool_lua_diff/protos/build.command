#!/bin/bash
#prtobuf转换pro命令
#注意文件路径
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
OUT=../GenProtobuf

# 遍历所有的proto文件 并 protoc
for file_a in ${DIR}/*; do  
    temp_file=`basename $file_a`
    if [[ $temp_file =~ .*\.proto ]] 
    then 
		protoc -o$OUT/${temp_file/proto/pb} $temp_file
    	echo $OUT/${temp_file/proto/pb}
	fi
done
echo "完成"
