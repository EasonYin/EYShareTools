//
//  EYSocialSDKManager.m
//  EYShareTools
//
//

#import "EYSocialSDKManager.h"
#import "EYShareManagerUtil.h"
#import "EYQQManager.h"
#import "EYWXManager.h"
#import "EYSinaManager.h"

@implementation EYSocialSDKManager

+ (BOOL)registerWeChatWithAppId:(NSString *)appid{
    if (![EYShareManagerUtil validateString:appid]) {
        return NO;
    }
    return [EYWXManager registerApp:appid];
}

+ (BOOL)registerSinaWithAppId:(NSString *)appid{
    if (![EYShareManagerUtil validateString:appid]) {
        return NO;
    }
    return [EYSinaManager registerApp:appid];
}

+ (BOOL)registerQQWithAppId:(NSString *)appid{
    if (![EYShareManagerUtil validateString:appid]) {
        return NO;
    }
    [EYQQManager registerApp:appid];
    if (![[EYQQManager getQQAppId] isEqualToString:appid]) {
        return NO;
    }
    return YES;
}

+ (void)registerWeChat:(NSString *)wxAppId Sina:(NSString *)sinaAppId QQ:(NSString *)qqAppId{
    [EYSocialSDKManager registerWeChatWithAppId:wxAppId];
    [EYSocialSDKManager registerSinaWithAppId:sinaAppId];
    [EYSocialSDKManager registerQQWithAppId:qqAppId];
}

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if ([options[@"UIApplicationOpenURLOptionsSourceApplicationKey"] isEqualToString:@"com.tencent.xin"]) {
        //wechat
        if ([[EYWXManager sharedEYWXManager] respondsToSelector:@selector(handleOpenURL:)]){
            return [[EYWXManager sharedEYWXManager] handleOpenURL:url];
        }
    }else if ([options[@"UIApplicationOpenURLOptionsSourceApplicationKey"] isEqualToString:@"com.tencent.mqq"] || [options[@"UIApplicationOpenURLOptionsSourceApplicationKey"] isEqualToString:@"com.tencent.tim"]){
        //qq
        if ([[EYQQManager sharedEYQQManager] respondsToSelector:@selector(handleOpenURL:)]){
            return [[EYQQManager sharedEYQQManager] handleOpenURL:url];
        }
    }else if ([options[@"UIApplicationOpenURLOptionsSourceApplicationKey"] isEqualToString:@"com.sina.weibo"]){
        //sina
        if ([[EYSinaManager sharedEYSinaManager] respondsToSelector:@selector(handleOpenURL:)]){
            return [[EYSinaManager sharedEYSinaManager] handleOpenURL:url];
        }
    }
    return YES;
}

@end
