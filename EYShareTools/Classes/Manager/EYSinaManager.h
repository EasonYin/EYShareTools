//
//  EYSinaManager.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>

@protocol EYSinaManagerDelegate <NSObject>
/**
 *  调用结束时间回调方法
 *
 *  @param state          bool                 是否成功
 *  @param message        NSString             成功或失败信息
 *  @param resultInfo     id                   回调内容(原SDK回调数据)
 */
- (void)SinaMessageFinishedState:(BOOL)state Message:(NSString*)message ResultInfo:(id)resultInfo;

@end

/**
 *  block回调参数
 *
 *  @param state          bool                 是否成功
 *  @param message        NSString             成功或失败信息
 *  @param resultInfo     id                   回调内容(原SDK回调数据)
 */
typedef void(^completionBlock)(BOOL state, NSString *message,id resultInfo);
NS_ASSUME_NONNULL_BEGIN

@interface EYSinaManager : NSObject
@property (nonatomic,weak)id<EYSinaManagerDelegate> sinaDelegate;

+ (EYSinaManager *)sharedEYSinaManager;
+ (BOOL)registerApp:(NSString *)appKey;
+ (NSString*)getSianAppKey;
+ (BOOL)isWeiboAppInstalled;
+ (BOOL)isWeiboSupportApi;
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 *  发送请求，等待返回
 *
 *  @param message      具体的发送请求
 *  @param target       指定代理
 *  @param completion   返回block
 *
 *  @return 成功返回YES，失败返回NO。
 */
+ (BOOL)sendShareReq:(id)message target:(id<EYSinaManagerDelegate>)target completion:(_Nullable completionBlock)completion;

/**
 *  授权方法，等待返回
 *
 *  @param authRequest  具体的发送请求
 *  @param target       指定代理
 *  @param completion   返回block
 *
 *  @return 成功返回YES，失败返回NO。
 */
+ (BOOL)sendSSOReq:(id)authRequest target:(id<EYSinaManagerDelegate>)target completion:(_Nullable completionBlock)completion;

@end

NS_ASSUME_NONNULL_END
