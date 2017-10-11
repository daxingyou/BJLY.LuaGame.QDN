# encoding: utf-8

import os,sys,inspect,re
import xdrlib,xlrd

reload(sys)
sys.setdefaultencoding("utf-8")

g_argv = []

#获取脚本文件的当前路径
def cur_file_dir():
    path = os.path.realpath(sys.path[0])
    print path
    if os.path.isfile(path):
        print "exe"
        path = os.path.dirname(path)
        return os.path.abspath(path)
    else:
        print "文件"
        caller_file = inspect.stack()[1][1]
        return os.path.abspath(os.path.dirname(caller_file))

#搜索指定文件夹下面的文件（默认当前目录）
def find_file_by_pattern(pattern='.*', base=".", circle=True):  
    '''''查找给定文件夹下面所有 '''
    re_file = re.compile(pattern)
    if base == ".":
        base = cur_file_dir()
    print "开始搜索文件夹：",base

    final_file_list = []
    cur_list = os.listdir(base)  
    for item in cur_list:
        # print item
        if item == ".svn":
            continue
          
        full_path = os.path.join(base, item)

        if full_path.startswith("~"):
            continue

        if full_path.endswith(".xlsx") or full_path.endswith(".xls"):
            print "in:" + full_path
            bfile = os.path.isfile(item)
            if os.path.isfile(full_path):
                if re_file.search(full_path):
                    final_file_list.append(full_path)  
            else:
                final_file_list += find_file_by_pattern(pattern, full_path)

    '''返回文件列表'''
    return final_file_list


#打开excel
def open_excel(file= 'file.xls'):
    try:
        data = xlrd.open_workbook(file)
        return data
    except Exception,e:
        print str(e)


#根据索引获取Excel表格中的数据 参数:file：Excel文件路径, colnameindex：表头列名所在行的索引, by_index：表的索引
def excel_table_byindex(file='file.xls', colnameindex=0, by_index=0):
    data = open_excel(file)
    table = data.sheets()[by_index]
    nrows = table.nrows #行数
    ncols = table.ncols #列数
    rowlist = []
    # print heads
    '''开始读取数据'''
    for rownum in range(colnameindex, nrows):
        rowdata = table.row_values(rownum)
        if rowdata:
            collist = []
            for i in range(ncols):
                collist.append(rowdata[i])
            rowlist.append(collist)
    return rowlist

#保存csv文件
def savaToLua(_file, _list, _path, _luafile):
    toluafile = _luafile
    filename = ""
    content = "local " + toluafile + "={\n"
    key = []
    vtype = []
    #生成文件内容 local a = { ["1001"] = {["k1"]="v1",["k2"]="v2",},}
    # for collist in _list:
    for j in range(len(_list)):
        collist = _list[j]
        # print collist
        #跳过第1个
        if 0 == j or 2 == j:#序号,注释 丢弃
            pass
        elif 1 == j:#key
            for i in range(len(collist)):
                v = collist[i]
                key.append(v)
        elif 3 == j:#数据类型
            for i in range(len(collist)):
                v = collist[i]
                vtype.append(v)
        elif j > 1:#内容
            for i in range(len(collist)):
                v = collist[i]
                vstr = ""
                # print v
                #if isinstance(v, float) or isinstance(v, int):
                if "int" == vtype[i]:#int类型去掉浮点
                    vstr = str(int(v))
                elif "float" == vtype[i]: #float
                    vstr = str(float(v))   
                else:#string elif isinstance(v, str):
                    vstr = str(v)
                if "string" == vtype[i]:#string类型加引号
                    vstr = "\"" + vstr + "\""
                if 0 == i:
                    content = content + "\t[" + vstr + "] = { "
                else:
                    content = content + "[\"" + key[i] + "\"]=" + vstr + ","
            content = content + " },\n"
    content = content + "}\nreturn " + toluafile

    #生成文件后缀
    # fname = os.path.splitext(_file)
    filename = toluafile + ".lua"

    #写文件
    if len(filename)>0 and len(content)>0:
        # filename = _path + "/" + filename
        print "out:" + filename
        file_object = open(filename, 'w')
        file_object.write(content)
        file_object.close()


def main(argv):
    path = ""
    file = argv[1]
    sheetIndex = 0
    if len(argv)>3:
        sheetIndex = int(argv[3])
    datalist = excel_table_byindex(file, 0, sheetIndex)
    if len(datalist)>0:
        savaToLua(file, datalist, path, argv[2])

if __name__=="__main__":
    main(sys.argv)