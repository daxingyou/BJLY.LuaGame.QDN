#ifndef WeiChatLogin_hpp
#define WeiChatLogin_hpp

#include <iostream>
#include <string>
using namespace std;

class WeiChatLogin{
public:
    static WeiChatLogin* getInstance();
    void sendAuthReq();//这里是微信登录方法
    static void startBrowserJni( const char * url);
    //分享到微信朋友
    //static void shareWithWeixinFriendTxt(const char * pTxt,const char * pUrl);
    static void shareWithWeixinFriendTxt(const char* kUrl,const char* kTitle,const char* kDesc);
    //分享到微信朋友圈
    //static void shareWithWeixinCircleTxt(const char * pTxt,const char * pUrl);
    static void shareWithWeixinCircleTxt(const char* kUrl,const char* kTitle,const char* kDesc);
    
    static void shareWithWeixinFriendImg(const char * pTxt,const char *FileName);
    
    static void shareWithWeixinCircleImg(const char * pTxt,const char *FileName);
    static void sharedComplete();
    static void varite();
    static void copyText(const char* copyTxt);
    static float getPower();
    static string getVersion();

    
    
    static void beginRecord(const char *_fileName);
    static const char * endRecord();
    void playaudio(std::string path);
private:
    WeiChatLogin();
    ~WeiChatLogin();
    
    static WeiChatLogin* m_wxLogin;
};


#endif /* WeiChatLogin_hpp */
