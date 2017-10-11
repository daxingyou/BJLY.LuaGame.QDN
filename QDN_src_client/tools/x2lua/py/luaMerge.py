# encoding: utf-8
'mergeTextFile--用于合并两个文本文件'
import os,sys
import re
reload(sys)
sys.setdefaultencoding("utf-8")

def main(argv):
    path = ""
    savafile = argv[1] + '.lua'
    baseclass = argv[1]
    isRemove = bool(argv[2])
    if len(argv) < 4:
        return
    contents = []
    contents.append('local %s = {}\n\n' % baseclass)
    for i in range(3, len(argv)):
        #一个个文件内容读取
        readfile = argv[i] + '.lua'
        try:
            fobj = open(readfile, 'r')
        except IOError, error:
            print ' %s 打开失败:%s' % (readfile, error)
        else:
            for eachline in fobj:
                # print eachline
                contents.append(eachline)
            #修改最后一行
            value = contents[len(contents)-1]
            strinfo = re.compile('return ')
            value = strinfo.sub(baseclass+'.', value)
            value += " = "+ argv[i] +"\n\n"
            contents[len(contents)-1] = value
        fobj.close()
        #移除原文件
        if isRemove:
            os.remove(readfile)

    #添加文件定义
    contents.append('return %s' % baseclass)
    # 写入文件
    fobj = open(savafile, 'w')
    fobj.writelines(['%s' % (eachline) for eachline in contents])
    fobj.close()
    print("合并完成"+savafile)

if __name__=="__main__":
    main(sys.argv)