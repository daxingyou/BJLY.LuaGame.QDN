#include "CLuaHelper.h"
#include "CCLuaEngine.h"
#include "LuaBasicConversions.h"


//
//  c++调用lua
//
CLuaHelper* CLuaHelper::_instance = nullptr;

CLuaHelper* CLuaHelper::getInstance()
{
    if(_instance == nullptr)
    {
        _instance = new CLuaHelper();
    }
    return _instance;
}

CLuaHelper::CLuaHelper()
{
}

CLuaHelper::~CLuaHelper()
{
}

void CLuaHelper::callbackLuaFunc(std::string funcID, ValueMap& data)
{
    LuaStack* pStack = LuaEngine::getInstance()->getLuaStack();
    lua_State* pL = pStack->getLuaState();
    lua_getglobal(pL, "C2LuaSystem_CallBack");
    lua_pushstring(pL, funcID.c_str());
    ccvaluemap_to_luaval(pL, data);
    lua_call(pL, 2, 0);
    lua_settop(pL, 0);
}





