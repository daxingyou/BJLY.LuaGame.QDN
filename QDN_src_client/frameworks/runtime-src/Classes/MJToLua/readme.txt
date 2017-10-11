1、把要转换的文件放在当前目录下
2、把头文件加进public.h文件
3、进到cocos2dx-x/tools/tolua目录修改my.ini文件  在classes字段后加入要添加的cpp文件以空格隔开
4、控制台进到cocos2dx-x/tools/tolua 目录 执行 python my.py  命令
5、在lua代码中通过my(暂定)调用
