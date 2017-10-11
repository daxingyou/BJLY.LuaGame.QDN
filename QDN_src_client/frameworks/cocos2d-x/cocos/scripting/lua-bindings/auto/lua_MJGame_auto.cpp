#include "lua_MJGame_auto.hpp"
#include "TPPublic.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_MJGame_TPTest_doTestMethod(lua_State* tolua_S)
{
    int argc = 0;
    TPTest* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"TPTest",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (TPTest*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_TPTest_doTestMethod'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPTest_doTestMethod'", nullptr);
            return 0;
        }
        const char* ret = cobj->doTestMethod();
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TPTest:doTestMethod",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPTest_doTestMethod'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_TPTest_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPTest",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPTest_getInstance'", nullptr);
            return 0;
        }
        TPTest* ret = TPTest::getInstance();
        object_to_luaval<TPTest>(tolua_S, "TPTest",(TPTest*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPTest:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPTest_getInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPTest_constructor(lua_State* tolua_S)
{
    int argc = 0;
    TPTest* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPTest_constructor'", nullptr);
            return 0;
        }
        cobj = new TPTest();
        tolua_pushusertype(tolua_S,(void*)cobj,"TPTest");
        tolua_register_gc(tolua_S,lua_gettop(tolua_S));
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TPTest:TPTest",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPTest_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_MJGame_TPTest_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (TPTest)");
    return 0;
}

int lua_register_MJGame_TPTest(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"TPTest");
    tolua_cclass(tolua_S,"TPTest","TPTest","",nullptr);

    tolua_beginmodule(tolua_S,"TPTest");
        tolua_function(tolua_S,"new",lua_MJGame_TPTest_constructor);
        tolua_function(tolua_S,"doTestMethod",lua_MJGame_TPTest_doTestMethod);
        tolua_function(tolua_S,"getInstance", lua_MJGame_TPTest_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(TPTest).name();
    g_luaType[typeName] = "TPTest";
    g_typeCast["TPTest"] = "TPTest";
    return 1;
}

int lua_MJGame_TPFunction_setGray(lua_State* tolua_S)
{
    int argc = 0;
    TPFunction* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (TPFunction*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_TPFunction_setGray'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Node* arg0;

        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_setGray'", nullptr);
            return 0;
        }
        cobj->setGray(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TPFunction:setGray",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_setGray'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_TPFunction_messageBox(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        const char* arg0;
        const char* arg1;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "TPFunction:messageBox"); arg0 = arg0_tmp.c_str();
        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "TPFunction:messageBox"); arg1 = arg1_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_messageBox'", nullptr);
            return 0;
        }
        TPFunction::messageBox(arg0, arg1);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:messageBox",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_messageBox'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_sendAuthWeiXin(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_sendAuthWeiXin'", nullptr);
            return 0;
        }
        TPFunction::sendAuthWeiXin();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:sendAuthWeiXin",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_sendAuthWeiXin'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_getNumberString(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        long long arg0;
        ok &= luaval_to_long_long(tolua_S, 2,&arg0, "TPFunction:getNumberString");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_getNumberString'", nullptr);
            return 0;
        }
        const char* ret = TPFunction::getNumberString(arg0);
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:getNumberString",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_getNumberString'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_exit(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_exit'", nullptr);
            return 0;
        }
        TPFunction::exit();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:exit",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_exit'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_shareWithWeixinTxt(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        const char* arg0;
        const char* arg1;
        const char* arg2;
        int arg3;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "TPFunction:shareWithWeixinTxt"); arg0 = arg0_tmp.c_str();
        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "TPFunction:shareWithWeixinTxt"); arg1 = arg1_tmp.c_str();
        std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "TPFunction:shareWithWeixinTxt"); arg2 = arg2_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "TPFunction:shareWithWeixinTxt");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_shareWithWeixinTxt'", nullptr);
            return 0;
        }
        TPFunction::shareWithWeixinTxt(arg0, arg1, arg2, arg3);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:shareWithWeixinTxt",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_shareWithWeixinTxt'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_getVersion(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_getVersion'", nullptr);
            return 0;
        }
        std::string ret = TPFunction::getVersion();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:getVersion",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_getVersion'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_copyText(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        const char* arg0;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "TPFunction:copyText"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_copyText'", nullptr);
            return 0;
        }
        TPFunction::copyText(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:copyText",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_copyText'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_shareWithWeixinImg(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        const char* arg0;
        const char* arg1;
        int arg2;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "TPFunction:shareWithWeixinImg"); arg0 = arg0_tmp.c_str();
        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "TPFunction:shareWithWeixinImg"); arg1 = arg1_tmp.c_str();
        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "TPFunction:shareWithWeixinImg");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_shareWithWeixinImg'", nullptr);
            return 0;
        }
        TPFunction::shareWithWeixinImg(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:shareWithWeixinImg",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_shareWithWeixinImg'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPFunction_getPower(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPFunction",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPFunction_getPower'", nullptr);
            return 0;
        }
        double ret = TPFunction::getPower();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPFunction:getPower",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPFunction_getPower'.",&tolua_err);
#endif
    return 0;
}
static int lua_MJGame_TPFunction_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (TPFunction)");
    return 0;
}

int lua_register_MJGame_TPFunction(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"TPFunction");
    tolua_cclass(tolua_S,"TPFunction","TPFunction","",nullptr);

    tolua_beginmodule(tolua_S,"TPFunction");
        tolua_function(tolua_S,"setGray",lua_MJGame_TPFunction_setGray);
        tolua_function(tolua_S,"messageBox", lua_MJGame_TPFunction_messageBox);
        tolua_function(tolua_S,"sendAuthWeiXin", lua_MJGame_TPFunction_sendAuthWeiXin);
        tolua_function(tolua_S,"getNumberString", lua_MJGame_TPFunction_getNumberString);
        tolua_function(tolua_S,"exit", lua_MJGame_TPFunction_exit);
        tolua_function(tolua_S,"shareWithWeixinTxt", lua_MJGame_TPFunction_shareWithWeixinTxt);
        tolua_function(tolua_S,"getVersion", lua_MJGame_TPFunction_getVersion);
        tolua_function(tolua_S,"copyText", lua_MJGame_TPFunction_copyText);
        tolua_function(tolua_S,"shareWithWeixinImg", lua_MJGame_TPFunction_shareWithWeixinImg);
        tolua_function(tolua_S,"getPower", lua_MJGame_TPFunction_getPower);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(TPFunction).name();
    g_luaType[typeName] = "TPFunction";
    g_typeCast["TPFunction"] = "TPFunction";
    return 1;
}

int lua_MJGame_TPTimeManager_getMilliscond(lua_State* tolua_S)
{
    int argc = 0;
    TPTimeManager* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"TPTimeManager",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (TPTimeManager*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_TPTimeManager_getMilliscond'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPTimeManager_getMilliscond'", nullptr);
            return 0;
        }
        long long ret = cobj->getMilliscond();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TPTimeManager:getMilliscond",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPTimeManager_getMilliscond'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_TPTimeManager_destroyInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPTimeManager",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPTimeManager_destroyInstance'", nullptr);
            return 0;
        }
        TPTimeManager::destroyInstance();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPTimeManager:destroyInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPTimeManager_destroyInstance'.",&tolua_err);
#endif
    return 0;
}
int lua_MJGame_TPTimeManager_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TPTimeManager",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_TPTimeManager_getInstance'", nullptr);
            return 0;
        }
        TPTimeManager* ret = TPTimeManager::getInstance();
        object_to_luaval<TPTimeManager>(tolua_S, "TPTimeManager",(TPTimeManager*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TPTimeManager:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_TPTimeManager_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_MJGame_TPTimeManager_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (TPTimeManager)");
    return 0;
}

int lua_register_MJGame_TPTimeManager(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"TPTimeManager");
    tolua_cclass(tolua_S,"TPTimeManager","TPTimeManager","",nullptr);

    tolua_beginmodule(tolua_S,"TPTimeManager");
        tolua_function(tolua_S,"getMilliscond",lua_MJGame_TPTimeManager_getMilliscond);
        tolua_function(tolua_S,"destroyInstance", lua_MJGame_TPTimeManager_destroyInstance);
        tolua_function(tolua_S,"getInstance", lua_MJGame_TPTimeManager_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(TPTimeManager).name();
    g_luaType[typeName] = "TPTimeManager";
    g_typeCast["TPTimeManager"] = "TPTimeManager";
    return 1;
}

int lua_MJGame_GcloudVoiceInstance_initEngine(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_initEngine'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_initEngine'", nullptr);
            return 0;
        }
        cobj->initEngine();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:initEngine",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_initEngine'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_closemic(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_closemic'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_closemic'", nullptr);
            return 0;
        }
        cobj->closemic();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:closemic",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_closemic'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_resumeEngine(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_resumeEngine'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_resumeEngine'", nullptr);
            return 0;
        }
        cobj->resumeEngine();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:resumeEngine",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_resumeEngine'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_pollEngine(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_pollEngine'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_pollEngine'", nullptr);
            return 0;
        }
        cobj->pollEngine();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:pollEngine",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_pollEngine'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_quickteamroom(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_quickteamroom'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "GcloudVoiceInstance:quickteamroom"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_quickteamroom'", nullptr);
            return 0;
        }
        cobj->quickteamroom(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:quickteamroom",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_quickteamroom'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_jointeamroom(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_jointeamroom'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "GcloudVoiceInstance:jointeamroom"); arg0 = arg0_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_jointeamroom'", nullptr);
            return 0;
        }
        cobj->jointeamroom(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:jointeamroom",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_jointeamroom'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_setAppinfo(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_setAppinfo'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 3) 
    {
        const char* arg0;
        const char* arg1;
        const char* arg2;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "GcloudVoiceInstance:setAppinfo"); arg0 = arg0_tmp.c_str();

        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "GcloudVoiceInstance:setAppinfo"); arg1 = arg1_tmp.c_str();

        std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "GcloudVoiceInstance:setAppinfo"); arg2 = arg2_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_setAppinfo'", nullptr);
            return 0;
        }
        cobj->setAppinfo(arg0, arg1, arg2);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:setAppinfo",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_setAppinfo'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_pauseEngine(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_pauseEngine'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_pauseEngine'", nullptr);
            return 0;
        }
        cobj->pauseEngine();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:pauseEngine",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_pauseEngine'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_setGvoiceModel(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_setGvoiceModel'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "GcloudVoiceInstance:setGvoiceModel");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_setGvoiceModel'", nullptr);
            return 0;
        }
        cobj->setGvoiceModel(arg0);
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:setGvoiceModel",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_setGvoiceModel'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_openmic(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_openmic'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_openmic'", nullptr);
            return 0;
        }
        cobj->openmic();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:openmic",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_openmic'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_opemspeaker(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_opemspeaker'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_opemspeaker'", nullptr);
            return 0;
        }
        cobj->opemspeaker();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:opemspeaker",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_opemspeaker'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_closespeaker(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_closespeaker'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_closespeaker'", nullptr);
            return 0;
        }
        cobj->closespeaker();
        lua_settop(tolua_S, 1);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:closespeaker",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_closespeaker'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_testapp(lua_State* tolua_S)
{
    int argc = 0;
    GcloudVoiceInstance* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (GcloudVoiceInstance*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_MJGame_GcloudVoiceInstance_testapp'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_testapp'", nullptr);
            return 0;
        }
        const char* ret = cobj->testapp();
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "GcloudVoiceInstance:testapp",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_testapp'.",&tolua_err);
#endif

    return 0;
}
int lua_MJGame_GcloudVoiceInstance_getinstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"GcloudVoiceInstance",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_MJGame_GcloudVoiceInstance_getinstance'", nullptr);
            return 0;
        }
        GcloudVoiceInstance* ret = GcloudVoiceInstance::getinstance();
        object_to_luaval<GcloudVoiceInstance>(tolua_S, "GcloudVoiceInstance",(GcloudVoiceInstance*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "GcloudVoiceInstance:getinstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_MJGame_GcloudVoiceInstance_getinstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_MJGame_GcloudVoiceInstance_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (GcloudVoiceInstance)");
    return 0;
}

int lua_register_MJGame_GcloudVoiceInstance(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"GcloudVoiceInstance");
    tolua_cclass(tolua_S,"GcloudVoiceInstance","GcloudVoiceInstance","",nullptr);

    tolua_beginmodule(tolua_S,"GcloudVoiceInstance");
        tolua_function(tolua_S,"initEngine",lua_MJGame_GcloudVoiceInstance_initEngine);
        tolua_function(tolua_S,"closemic",lua_MJGame_GcloudVoiceInstance_closemic);
        tolua_function(tolua_S,"resumeEngine",lua_MJGame_GcloudVoiceInstance_resumeEngine);
        tolua_function(tolua_S,"pollEngine",lua_MJGame_GcloudVoiceInstance_pollEngine);
        tolua_function(tolua_S,"quickteamroom",lua_MJGame_GcloudVoiceInstance_quickteamroom);
        tolua_function(tolua_S,"jointeamroom",lua_MJGame_GcloudVoiceInstance_jointeamroom);
        tolua_function(tolua_S,"setAppinfo",lua_MJGame_GcloudVoiceInstance_setAppinfo);
        tolua_function(tolua_S,"pauseEngine",lua_MJGame_GcloudVoiceInstance_pauseEngine);
        tolua_function(tolua_S,"setGvoiceModel",lua_MJGame_GcloudVoiceInstance_setGvoiceModel);
        tolua_function(tolua_S,"openmic",lua_MJGame_GcloudVoiceInstance_openmic);
        tolua_function(tolua_S,"opemspeaker",lua_MJGame_GcloudVoiceInstance_opemspeaker);
        tolua_function(tolua_S,"closespeaker",lua_MJGame_GcloudVoiceInstance_closespeaker);
        tolua_function(tolua_S,"testapp",lua_MJGame_GcloudVoiceInstance_testapp);
        tolua_function(tolua_S,"getinstance", lua_MJGame_GcloudVoiceInstance_getinstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(GcloudVoiceInstance).name();
    g_luaType[typeName] = "GcloudVoiceInstance";
    g_typeCast["GcloudVoiceInstance"] = "GcloudVoiceInstance";
    return 1;
}
TOLUA_API int register_all_MJGame(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"my",0);
	tolua_beginmodule(tolua_S,"my");

	lua_register_MJGame_TPTimeManager(tolua_S);
	lua_register_MJGame_GcloudVoiceInstance(tolua_S);
	lua_register_MJGame_TPFunction(tolua_S);
	lua_register_MJGame_TPTest(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

