//#import <Foundation/Foundation.h>

#import "WXApi.h"


@protocol WXApiManagerDelegate <NSObject>

@end

@interface WXApiManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;

+ (instancetype)sharedManager;



@end
