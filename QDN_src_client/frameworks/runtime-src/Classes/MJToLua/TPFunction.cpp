

#include "TPFunction.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include "iosHelper.h"
#endif


const char* TPFunction::getNumberString(long long _number)
{
    static char tmpChar[64] = {0};
    sprintf(tmpChar,  "%lld", _number);
    return tmpChar;
}



void TPFunction::setGray(cocos2d::Node *node)
{
    USING_NS_CC;
    do
    {
        const GLchar* pszFragSource =
        "#ifdef GL_ES \n \
        precision mediump float; \n \
        #endif \n \
        uniform sampler2D u_texture; \n \
        varying vec2 v_texCoord; \n \
        varying vec4 v_fragmentColor; \n \
        void main(void) \n \
        { \n \
        // Convert to greyscale using NTSC weightings \n \
        vec4 col = texture2D(u_texture, v_texCoord); \n \
        float grey = dot(col.rgb, vec3(0.299, 0.587, 0.114)); \n \
        gl_FragColor = vec4(grey, grey, grey, col.a); \n \
        }";
        
        GLProgram* pProgram = new GLProgram();
        pProgram->initWithByteArrays(ccPositionTextureColor_noMVP_vert, pszFragSource);
        node->setGLProgram(pProgram);
        CHECK_GL_ERROR_DEBUG();
    }while(0);
}

void TPFunction::sendAuthWeiXin()
{
#if(CC_TARGET_PLATFORM==CC_PLATFORM_IOS)
	{
		WeiChatLogin::getInstance()->sendAuthReq();
	}
#endif
}

void TPFunction::messageBox(const char *_title, const char *_msg)
{
    cocos2d::MessageBox(_msg, _title);
}

float TPFunction::getPower()
{
    float power = 0.0f;
#if(CC_TARGET_PLATFORM==CC_PLATFORM_IOS)
    {
        power = WeiChatLogin::getInstance()->getPower();
    }
#endif
    return power;
}
void TPFunction::copyText(const char* copyTxt)
{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    WeiChatLogin::getInstance()->copyText(copyTxt);
#endif
}
string TPFunction::getVersion()
{
    string version="";
#if( CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    version = WeiChatLogin::getInstance()->getVersion();
#endif
    return version;
}

//type:1朋友圈,0微信朋友
void TPFunction::shareWithWeixinTxt(const char* kUrl,const char* kTitle,const char* kDesc,int type)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if (type == 1) {
        WeiChatLogin::getInstance()->shareWithWeixinCircleTxt(kUrl,kTitle,kDesc);
    } else {
        WeiChatLogin::getInstance()->shareWithWeixinFriendTxt(kUrl,kTitle,kDesc);
    }
#endif
}
void TPFunction::shareWithWeixinImg(const char * pTxt,const char *FileName,int type)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if (type == 1) {
        WeiChatLogin::getInstance()->shareWithWeixinCircleImg(pTxt,FileName);
    } else {
        WeiChatLogin::getInstance()->shareWithWeixinFriendImg(pTxt,FileName);
    }
#endif
}
void TPFunction::exit()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    ::exit(0);
#endif
}

