#import "iOSPlatform.h"

#include "IosHelper.h"
#include "CLuaHelper.h"
//#include "platform/MissionWeiXin.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    

 
    NSLog(@"onResp-------");
    if (WXSuccess == resp.errCode)
    {
        if ([resp isKindOfClass:[SendAuthResp class]])
        {
            SendAuthResp *temp = (SendAuthResp *)resp;
            NSLog(@"%@",temp.code);
            
            NSString *AppId=@"wxfc202ca14bf4d7e0";
            NSString *AppSerect=@"ba33bb872418ed816cc2cfcd04b31f92";
            NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",AppId,AppSerect,temp.code];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *zoneUrl = [NSURL URLWithString:url];
                NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
                NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (data){
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        NSString *openID = dic[@"openid"];
//                        NSString *unionid = dic[@"unionid"];
                        NSString *accesstoken = dic[@"access_token"];
             
                        std::string acc=[accesstoken UTF8String];
                        std::string open=[openID UTF8String];
                        
                        //压入Lua
                        ValueMap valueMap ;
                        valueMap["token"] = Value(acc);
                        valueMap["openid"] = Value(open);
                        CLuaHelper::getInstance()->callbackLuaFunc("C2Lua_WeiXinAccess",valueMap);
            
                    }
                });
            });
        }
        else if ([resp isKindOfClass:[SendMessageToWXResp class]])
        {
            SendMessageToWXResp *temp = (SendMessageToWXResp *)resp;
            NSLog(@"----SendMessageToWXReq");
            dispatch_async(dispatch_get_main_queue(), ^{
                ValueMap valueMap ;
                CLuaHelper::getInstance()->callbackLuaFunc("C2Lua_WXShareSuccess",valueMap);
            });
        }
    }
    
}



-(float)getPower
{
    return 1.2;
}
@end
