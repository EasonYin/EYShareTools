//
//  EYQQManager.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>

@protocol EYQQManagerDelegate <NSObject>
/**
 *  调用结束时间回调方法
 *
 *  @param state          bool                 是否成功
 *  @param message        NSString             成功或失败信息
 *  @param resultInfo     id                   回调内容(原SDK回调数据)
 */
- (void)QQMessageFinishedState:(BOOL)state Message:(NSString*)message ResultInfo:(id)resultInfo;

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

@interface EYQQManager : NSObject
@property (nonatomic,weak)id<EYQQManagerDelegate> qqDelegate;

+ (EYQQManager *)sharedEYQQManager;
+ (void)registerApp:(NSString *)appid;
+ (NSString*)getQQAppId;
+ (BOOL)isQQorTIMInstalled;
+ (BOOL)isQQorTIMSupportApi;
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 * 分享相关,分享至QQ或QQ空间
 */
+ (BOOL)sendReqQQ:(id)message target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion;
+ (BOOL)sendReqQQZone:(id)message target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion;

/**
 * 授权
 * \param permissions 授权信息列表，同登录授权
 * \return 授权调用是否成功
 */
+ (BOOL)authorize:(NSArray *)permissions target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion;
/**
 * 重新授权，因token废除或失效导致接口调用失败，需用户重新授权
 * \param permissions 授权信息列表，同登录授权
 * \return 授权调用是否成功
 */
+ (BOOL)reauthorizeWithPermissions:(NSArray *)permissions target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion;

@end

NS_ASSUME_NONNULL_END
