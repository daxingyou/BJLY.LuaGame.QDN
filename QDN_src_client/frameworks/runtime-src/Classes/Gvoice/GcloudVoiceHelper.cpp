#include "GcloudVoiceHelper.h"

//#if defined(__GNUC__) && ( defined(__APPLE_CPP__) || defined(__APPLE_CC__) || defined(__MACOS_CLASSIC__) )
#define TARGET_IPHONE_SIMULATOR 0



//#endif
#include "GvoiceListener.h"
GcloudVoiceHelper* GcloudVoiceHelper::g = nullptr;

GcloudVoiceHelper * GcloudVoiceHelper::getinstance()
{
	if(g == nullptr)
	{
		g= new GcloudVoiceHelper();
	}
	return g;
}
/*
IGCloudVoiceEngine * GvoiceHelper::getgvoiceegine()
{
	return gcloud_voice::GetVoiceEngine();
}
 */
const char * GcloudVoiceHelper::testapp()
{
    CCLOG("GcloudVoiceHelper::testapp ");
    return "testsuccess";
}
void GcloudVoiceHelper::setAppinfo(const char *appID,const char *appKey, const char *openID)
{
#if TARGET_IPHONE_SIMULATOR
#else
    CCLOG("TARGET_IPHONE_SIMULATOR NOT");
    gcloud_voice::GetVoiceEngine()->SetAppInfo(appID,appKey,openID);
#endif
}
void GcloudVoiceHelper::initEngine()
{

#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->Init();
    
    TeamRoomNotify *s=new TeamRoomNotify();
    gcloud_voice::GetVoiceEngine()->SetNotify(s);
#endif
}

void GcloudVoiceHelper::setGvoiceModel(int model)
{
#if TARGET_IPHONE_SIMULATOR
#else
    switch (model)
    {
        case 0:
            gcloud_voice::GetVoiceEngine()->SetMode(IGCloudVoiceEngine::RealTime);
            break;
        case 1:
            gcloud_voice::GetVoiceEngine()->SetMode(IGCloudVoiceEngine::Messages);
            break;
        case 2:
            gcloud_voice::GetVoiceEngine()->SetMode(IGCloudVoiceEngine::Translation);
            break;
        default:
            break;
    }
#endif
}
void GcloudVoiceHelper::pauseEngine()
{
#if TARGET_IPHONE_SIMULATOR
#else
  gcloud_voice::GetVoiceEngine()->Pause();
#endif
}
void GcloudVoiceHelper::resumeEngine()
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->Resume();
#endif
}
void GcloudVoiceHelper::pollEngine()
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->Poll();
#endif
}
void GcloudVoiceHelper::jointeamroom(const char *roomName)
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->JoinTeamRoom(roomName,5000);
#endif
}
void GcloudVoiceHelper::quickteamroom(const char *roomName)
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->QuitRoom(roomName,5000);
#endif
}
void GcloudVoiceHelper::openmic()
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->OpenMic();
#endif
}
void GcloudVoiceHelper::closemic()
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->CloseMic();
#endif
}
void GcloudVoiceHelper::opemspeaker()
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->OpenSpeaker();
#endif
}
void GcloudVoiceHelper::closespeaker()
{
#if TARGET_IPHONE_SIMULATOR
#else
    gcloud_voice::GetVoiceEngine()->CloseSpeaker();
#endif
}
