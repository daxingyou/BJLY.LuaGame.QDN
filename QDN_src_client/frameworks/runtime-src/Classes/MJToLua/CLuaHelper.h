#ifndef _CLuaHelper_h
#define _CLuaHelper_h

#include "cocos2d.h"
using namespace std;
using namespace cocos2d;
class CLuaHelper
{
private:
    CLuaHelper();
    virtual ~CLuaHelper();
    
private:
    static CLuaHelper* _instance;
    
public:
    static CLuaHelper* getInstance();
    
    /*调用lua中定义的方法，  funcID：方法ID，data：传递的参数集合*/
    /*调用 C2LuaSystem.lua中 定义的C2LuaSystem_CallBack方法*/
    void callbackLuaFunc(std::string funcID, ValueMap& data);
    
};
#endif
