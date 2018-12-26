//
//  EYSocialSDKManager.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EYSocialSDKManager : NSObject

/**
 * 注册各个的appid
 
 @param appid 平台appid
 @return YES or NO
 */
+ (BOOL)registerWeChatWithAppId:(NSString *)appid;
+ (BOOL)registerSinaWithAppId:(NSString *)appid;
+ (BOOL)registerQQWithAppId:(NSString *)appid;

/**
 * 统一管理分享跳转过来的url
 
 @param app app description
 @param url url description
 @param options options description
 @return return value description
 */
+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

@end

NS_ASSUME_NONNULL_END
