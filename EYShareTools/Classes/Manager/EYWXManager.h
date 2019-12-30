//
//  EYWXManager.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>

/**
 *  block回调参数
 *
 *  @param state          bool                 是否成功
 *  @param message        NSString             成功或失败信息
 *  @param resultInfo     id                   回调内容(原SDK回调数据)
 */
typedef void(^completionBlock)(BOOL state, NSString * __nullable message,id __nullable resultInfo);
NS_ASSUME_NONNULL_BEGIN

@interface EYWXManager : NSObject

+ (EYWXManager *)sharedEYWXManager;
+ (BOOL) registerApp:(NSString *)appid universalLink:(NSString *)universalLink;
+ (NSString*)getWXAppId;
+ (BOOL)isWXAppInstalled;
+ (BOOL)isWXAppSupportApi;

- (BOOL)handleOpenURL:(NSURL *)url;
- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity;

/**
 *  发送请求，等待返回
 *
 *  @param req          具体的发送请求
 *  @param completion   返回block
 *
 *  @return 成功返回YES，失败返回NO。
 */
+ (BOOL)sendReq:(id)req completion:(_Nullable completionBlock)completion;

@end

NS_ASSUME_NONNULL_END
