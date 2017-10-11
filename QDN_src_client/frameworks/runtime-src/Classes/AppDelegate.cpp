
#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "lua_MJGame_auto.hpp"
#include "pbc-lua.h"
#include "MJToLua/CLuaHelper.h"
#include "Gvoice/GcloudVoiceHelper.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "android/jni/JniHelper.h"
#endif
using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

// If you want to use packages manager to install more packages, 
// don't modify or remove this function
static int register_all_packages()
{
    extern void package_quick_register();
	package_quick_register();
	return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);
   
    // register lua module
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
 
     //2dx模块注册
    lua_module_register(L);
    //quick tolua注册
    register_all_packages();
    //注册自己的模块
    register_all_MJGame(L);
    
    //protofuf lua
    luaopen_protobuf_c(L);
  
    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("L@Y#G^^", strlen("L@Y#G^^"), "LAIYAGAME", strlen("LAIYAGAME"));
    string path = FileUtils::getInstance()->fullPathForFilename("src/main.lua");
    CCLOG("path ==%s",path.c_str());
//    stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

    size_t pos;
    while ((pos = path.find_first_of("\\")) != std::string::npos)
    {
        path.replace(pos, 1, "/");
    }
    size_t p = path.find_last_of("/\\");
    if (p != path.npos)
    {
        const string dir = path.substr(0, p);
        stack->addSearchPath(dir.c_str());
        
        p = dir.find_last_of("/\\");
        if (p != dir.npos)
        {
            stack->addSearchPath(dir.substr(0, p).c_str());
        }
    }
    
    string env = "__LUA_STARTUP_FILE__=\"";
    env.append(path);
    env.append("\"");
    stack->executeString(env.c_str());
    
    CCLOG("------------------------------------------------");
    CCLOG("LOAD LUA FILE: %s", path.c_str());
    CCLOG("------------------------------------------------");

//#ifdef DEBUG
//    
    engine->executeScriptFile(path.c_str());
//
//#else
//    //    stack->executeScriptFile(path.c_str());
//    stack->loadChunksFromZIP("res/sc/game.tg");
//    string script_main = "";
//    script_main += "require(\"main\")";
//    //    CCLOG("Boot script: \n%s", script_main.c_str());
//    engine->executeString(script_main.c_str());
//
//    
//#endif

    return true;
}


void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

//    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
    
#endif
    //SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_BACKGROUND_EVENT");
    
    //gcloud_voice::GetVoiceEngine()->CloseSpeaker();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
    JniMethodInfo minfo;
    bool isHave = JniHelper::getStaticMethodInfo(minfo,"com.laiya.game.tianzhuMJ.AppActivity","hideBottomUIMenu","()V");
    if (isHave)
    {
        
        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID);
    }
    
#endif
    //SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_FOREGROUND_EVENT");
   //gcloud_voice::GetVoiceEngine()->OpenSpeaker();
}

