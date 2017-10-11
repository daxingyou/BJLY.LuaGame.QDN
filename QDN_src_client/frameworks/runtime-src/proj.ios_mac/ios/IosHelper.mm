#include "iosHelper.h"
#include "WXApiObject.h"
#include "WXApi.h"
#import "iOSPlatform.h"
#import <AVFoundation/AVFoundation.h>

#include "cocos2d.h"
USING_NS_CC;

WeiChatLogin* WeiChatLogin::m_wxLogin = nullptr;

WeiChatLogin::WeiChatLogin()
{
    
}

WeiChatLogin::~WeiChatLogin()
{
    if (m_wxLogin) {
        delete m_wxLogin;
    }
    m_wxLogin = nullptr;
}

WeiChatLogin* WeiChatLogin::getInstance()
{
    if (!m_wxLogin) {
        m_wxLogin = new WeiChatLogin();
    }
    return m_wxLogin;
}

void WeiChatLogin::sendAuthReq()
{
    //构造sendAuthReq结构体
    SendAuthReq* req = [[[SendAuthReq alloc] init] autorelease];
    req.scope = @"snsapi_userinfo";
    req.state = @"baibianwx";
    [WXApi sendReq:req];
}

void WeiChatLogin::shareWithWeixinCircleTxt(const char* kUrl,const char* kTitle,const char* kDesc)
//void WeiChatLogin::shareWithWeixinCircleTxt(const char * pTxt,const char * pUrl)
{
    UIImage *image = [UIImage imageNamed:@"Icon-72.png"];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [[NSString alloc]initWithUTF8String:kTitle];
    message.description = [[NSString alloc]initWithUTF8String:kDesc];
    //png图片压缩成data的方法，如果是jpg就要用 UIImageJPEGRepresentation
    message.thumbData = UIImagePNGRepresentation(image);
    [message setThumbImage:image];
    
    NSString *txt = [NSString stringWithCString:kUrl encoding:NSUTF8StringEncoding];
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = txt;
    message.mediaObject = ext;
    message.mediaTagName = @"ISOFTEN_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq *sentMsg = [[SendMessageToWXReq alloc]init];
    sentMsg.message = message;
    sentMsg.bText = NO;
    //选择发送到会话(WXSceneSession)或者朋友圈(WXSceneTimeline)
    
    
    sentMsg.scene =  WXSceneTimeline;  //分享到会话。
    [WXApi sendReq:sentMsg];
}

void WeiChatLogin::shareWithWeixinFriendTxt(const char* kUrl,const char* kTitle,const char* kDesc)
//void WeiChatLogin::shareWithWeixinFriendTxt(const char * pTxt,const char * pUrl)
{
    UIImage *image = [UIImage imageNamed:@"Icon-72.png"];
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [[NSString alloc]initWithUTF8String:kTitle];
    message.description = [[NSString alloc]initWithUTF8String:kDesc];
    //png图片压缩成data的方法，如果是jpg就要用 UIImageJPEGRepresentation
    message.thumbData = UIImagePNGRepresentation(image);
    [message setThumbImage:image];
    
    NSString *txt = [NSString stringWithCString:kUrl encoding:NSUTF8StringEncoding];
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = txt;
    message.mediaObject = ext;
    message.mediaTagName = @"ISOFTEN_TAG_JUMP_SHOWRANK";
    
    SendMessageToWXReq *sentMsg = [[SendMessageToWXReq alloc]init];
    sentMsg.message = message;
    sentMsg.bText = NO;
    //选择发送到会话(WXSceneSession)或者朋友圈(WXSceneTimeline)
    
    sentMsg.scene =  WXSceneSession;  //分享到会话。
    [WXApi sendReq:sentMsg];
    
}
void WeiChatLogin::varite()
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
void WeiChatLogin::shareWithWeixinFriendImg(const char * pTxt,const char *FileName)
{
    NSString *txt = [NSString stringWithCString:pTxt encoding:NSUTF8StringEncoding];
    NSString *filePath = [NSString stringWithCString:FileName encoding:NSUTF8StringEncoding];
    WXMediaMessage *message = [WXMediaMessage message];
    
    message.title = txt;
    message.description = txt;
    [message setThumbImage:[UIImage imageNamed:@"Icon-80.png"]];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = [NSData dataWithContentsOfFile:filePath];
    
    
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}
void WeiChatLogin::shareWithWeixinCircleImg(const char * pTxt,const char *FileName)
{
    NSString *txt = [NSString stringWithCString:pTxt encoding:NSUTF8StringEncoding];
    NSString *filePath = [NSString stringWithCString:FileName encoding:NSUTF8StringEncoding];
    WXMediaMessage *message = [WXMediaMessage message];
    
    message.title = txt;
    message.description = txt;
    [message setThumbImage:[UIImage imageNamed:@"Icon-152.png"]];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = [NSData dataWithContentsOfFile:filePath];
    
    
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}
void WeiChatLogin::startBrowserJni( const char * url)
{
    NSString *nsFineName = [NSString stringWithCString:url encoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsFineName]];
}
AVAudioRecorder *recorder = NULL;
void WeiChatLogin::beginRecord(const char *_fileName)
{
    if (recorder == nil)
    {
        //设置文件名和录音路径
        NSString *recordFilePath = [NSString stringWithCString:_fileName encoding:NSUTF8StringEncoding];
        
        NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                       [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                       [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                       [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                       nil];
        //初始化录音
        NSError *error = nil;
        recorder = [[ AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:recordFilePath] settings:recordSetting error:&error];
    }
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    //开始录音
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    
    // 扬声器播放
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [recorder record];
}
const char * WeiChatLogin::endRecord()
{
    if (recorder == nil)
        return "";
    if (recorder.isRecording)
        [recorder stop];
    return "";
}
void WeiChatLogin::playaudio(std::string path)
{
    NSString *str= [NSString stringWithCString:path.c_str() encoding:[NSString defaultCStringEncoding]];
    NSURL *url=[NSURL URLWithString:str];
    
    AVAudioPlayer* audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url
                                                      error:nil];
    
    audioPlayer.volume=1;
    
    //准备播放
    [audioPlayer prepareToPlay];
    //播放
    [audioPlayer play];
}
void WeiChatLogin::copyText(const char* copyTxt)
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [[NSString alloc] initWithUTF8String:copyTxt];
}
float WeiChatLogin::getPower()//返回[0,1.0]
{
    //float power = [[UIDevice currentDevice] batteryLevel];
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    float power = device.batteryLevel;
    return power;
}

string WeiChatLogin::getVersion()
{
    NSString *Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    string str = [Version UTF8String];
    return str;
}

