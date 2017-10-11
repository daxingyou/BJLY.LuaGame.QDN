#ifndef GVOICE_HELP_H
#define GVOICE_HELP_H
#include "cocos2d.h"

#include "GCloudVoice.h"
using namespace gcloud_voice;

using namespace cocos2d;
class GcloudVoiceHelper
{
public:
	static GcloudVoiceHelper * getinstance();

  //  IGCloudVoiceEngine  * getgvoiceegine();

	void setAppinfo(const char *appID,const char *appKey, const char *openID);

	void initEngine();

	void setGvoiceModel(int model);//0 实时 1 短消息 2 语音翻译

	void pauseEngine();
	void resumeEngine();
	void pollEngine();

    void jointeamroom(const char *roomName);

	void quickteamroom(const char *roomName);

	void openmic();

	void closemic();

	void opemspeaker();

	void closespeaker();
    const char * testapp();
    
    static GcloudVoiceHelper* g;
	
};

#endif
