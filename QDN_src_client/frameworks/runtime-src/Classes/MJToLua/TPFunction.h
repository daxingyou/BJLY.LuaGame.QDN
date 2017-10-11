#ifndef _TPFunctionA_H_
#define _TPFunctionA_H_
#include "cocos2d.h"
#include <string>
using namespace std;
class TPFunction {
public:
    static const char* getNumberString(long long _number);
    void setGray(cocos2d::Node *node);
    static void messageBox(const char* _title, const char* _msg);
    
    static void sendAuthWeiXin();
    
    static float getPower();
    static void copyText(const char* copyTxt);
    
    static string getVersion();
    //干掉客户端
    static void exit();
    
    //type:1朋友圈,0微信朋友
    static void shareWithWeixinTxt(const char* kUrl,const char* kTitle,const char* kDesc,int type);
    static void shareWithWeixinImg(const char * pTxt,const char *FileName,int type);
    
};
#endif
