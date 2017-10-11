//
//  TeamRoomNotify.hpp
//  VoiceTutorial
//
//  Created by apollo on 8/23/16.
//
//

#ifndef TeamRoomNotify_hpp
#define TeamRoomNotify_hpp

#include "GCloudVoice.h"
#include "cocos2d.h"


class TeamRoomNotify: public gcloud_voice::IGCloudVoiceNotify
{
public:
    TeamRoomNotify();
    
public:
    // Real-Time Callback
    virtual void OnJoinRoom(gcloud_voice::GCloudVoiceCompleteCode code, const char *roomName, int memberID) ;
    virtual void OnQuitRoom(gcloud_voice::GCloudVoiceCompleteCode code, const char *roomName) ;
    void OnStatusUpdate(gcloud_voice::GCloudVoiceCompleteCode status, const char *roomName, uint32_t memberID) ;
    virtual void OnMemberVoice	(const unsigned int *members, int count) ;
    
    virtual void OnUploadFile(gcloud_voice::GCloudVoiceCompleteCode code, const char *filePath, const char *fileID) {}
    virtual void OnDownloadFile(gcloud_voice::GCloudVoiceCompleteCode code, const char *filePath, const char *fileID) {}
    virtual void OnPlayRecordedFile(gcloud_voice::GCloudVoiceCompleteCode code, const char *filePath) {}
    virtual void OnApplyMessageKey(gcloud_voice::GCloudVoiceCompleteCode code) {}
    virtual void OnSpeechToText(gcloud_voice::GCloudVoiceCompleteCode code, const char *fileID, const char *result) {}
    

};

#endif /* TeamRoomNotify_hpp */
