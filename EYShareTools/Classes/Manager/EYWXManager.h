//
//  EYWXManager.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>

@protocol EYWXManagerDelegate <NSObject>
/**
 *  调用结束时间回调方法
 *
 *  @param state          bool                 是否成功
 *  @param message        NSString             成功或失败信息
 *  @param resultInfo     id                   回调内容(原SDK回调数据)
 */
- (void)WXMessageFinishedState:(BOOL)state Message:(NSString*)message ResultInfo:(id)resultInfo;

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

@interface EYWXManager : NSObject
@property (nonatomic,weak)id<EYWXManagerDelegate> wxDelegate;

+ (EYWXManager *)sharedEYWXManager;
+ (BOOL)registerApp:(NSString *)appid;
+ (NSString*)getWXAppId;
+ (BOOL)isWXAppInstalled;
+ (BOOL)isWXAppSupportApi;
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 *  发送请求，等待返回
 *
 *  @param req          具体的发送请求
 *  @param target       指定代理
 *  @param completion   返回block
 *
 *  @return 成功返回YES，失败返回NO。
 */
+ (BOOL)sendReq:(id)req target:(id<EYWXManagerDelegate>)target completion:(_Nullable completionBlock)completion;

@end

NS_ASSUME_NONNULL_END
