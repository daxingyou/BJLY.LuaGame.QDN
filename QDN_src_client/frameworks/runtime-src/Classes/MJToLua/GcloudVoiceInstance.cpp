#include "GcloudVoiceInstance.h"
#include "GcloudVoiceHelper.h"
static GcloudVoiceInstance *g=nullptr;
GcloudVoiceInstance * GcloudVoiceInstance::getinstance()
{
    if(g == nullptr)
    {
        g = new GcloudVoiceInstance();
    }
    return g;
    
}
const char * GcloudVoiceInstance::testapp()
{
    CCLOG("GcloudVoiceHelper::testapp ");
    return "testsuccess";
}
void GcloudVoiceInstance::setAppinfo(const char *appID,const char *appKey, const char *openID)
{
    GcloudVoiceHelper::getinstance()->setAppinfo(appID, appKey, openID);
}
void GcloudVoiceInstance::initEngine()
{
    GcloudVoiceHelper::getinstance()->initEngine();
}

void GcloudVoiceInstance::setGvoiceModel(int model)
{
    GcloudVoiceHelper::getinstance()->setGvoiceModel(model);
}
void GcloudVoiceInstance::pauseEngine()
{
    GcloudVoiceHelper::getinstance()->pauseEngine();
}
void GcloudVoiceInstance::resumeEngine()
{
    GcloudVoiceHelper::getinstance()->resumeEngine();
}
void GcloudVoiceInstance::pollEngine()
{
    GcloudVoiceHelper::getinstance()->pollEngine();
}
void GcloudVoiceInstance::jointeamroom(const char *roomName)
{
    GcloudVoiceHelper::getinstance()->jointeamroom(roomName);
}
void GcloudVoiceInstance::quickteamroom(const char *roomName)
{
    GcloudVoiceHelper::getinstance()->quickteamroom(roomName);
}
void GcloudVoiceInstance::openmic()
{
    GcloudVoiceHelper::getinstance()->openmic();
}
void GcloudVoiceInstance::closemic()
{
    GcloudVoiceHelper::getinstance()->closemic();
}
void GcloudVoiceInstance::opemspeaker()
{
       GcloudVoiceHelper::getinstance()->opemspeaker();
}
void GcloudVoiceInstance::closespeaker()
{
    GcloudVoiceHelper::getinstance()->closespeaker();
}
