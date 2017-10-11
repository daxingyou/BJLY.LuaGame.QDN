#ifndef GVOICE_INSTANCE_H
#define GVOICE_INSTANCE_H
#include "cocos2d.h"

using namespace cocos2d;
class GcloudVoiceInstance
{
public:


    static GcloudVoiceInstance * getinstance();
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
    
    
	
};

#endif
