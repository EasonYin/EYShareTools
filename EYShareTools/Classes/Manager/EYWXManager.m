//
//  EYWXManager.m
//  EYShareTools
//
//

#import "EYWXManager.h"
#import "EYShareManagerUtil.h"
#import "WXApi.h"

@interface EYWXManager()<WXApiDelegate>
@property (nonatomic,strong)NSString *wxAppId;
@property (nonatomic,copy) completionBlock block;
@end

@implementation EYWXManager
#pragma mark - Lifecycle Methods
static EYWXManager *sharedEYWXManager = nil;

+ (EYWXManager *)sharedEYWXManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEYWXManager = [[EYWXManager alloc] init];
    });
    return sharedEYWXManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedEYWXManager == nil)
        {
            sharedEYWXManager = [super allocWithZone:zone];
            return sharedEYWXManager;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Property Methods
- (void)setWxAppId:(NSString *)wxAppId{
    if (_wxAppId && ![_wxAppId isEqualToString:@""]) {
        NSLog(@"微信appkey设置后无法重新设置！");
        return;
    }
    _wxAppId = wxAppId;
}

#pragma mark - Public Methods
+ (BOOL) registerApp:(NSString *)appid universalLink:(NSString *)universalLink
{
    // 注册微信
    if ([EYShareManagerUtil validateString:appid]) {
        [[EYWXManager sharedEYWXManager] setWxAppId:appid];
    }
    return [WXApi registerApp:appid universalLink:universalLink];
}

+ (NSString *)getWXAppId{
    return [[EYWXManager sharedEYWXManager]wxAppId];
}

+ (BOOL)isWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

+ (BOOL)isWXAppSupportApi
{
    return [WXApi isWXAppSupportApi];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity{
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

+ (BOOL)sendReq:(id)req completion:(_Nullable completionBlock)completion
{
    [[EYWXManager sharedEYWXManager] setBlock:completion];
    [WXApi sendReq:req completion:nil];
    return YES;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp
{
    BOOL state;
    if (resp.errCode == WXSuccess) {
        state = YES;
    }
    else{
        state = NO;
    }
    
    NSString *message = nil;
    // 发送消息结果
    if ([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        message = resp.errCode==WXSuccess?@"分享成功":(resp.errCode==WXErrCodeUserCancel?@"分享取消":@"分享失败");
    }
    // 支付结果
    else if ([resp isKindOfClass:[PayResp class]])
    {
        message = resp.errCode==WXSuccess?@"支付成功":(resp.errCode==WXErrCodeUserCancel?@"支付取消":@"支付失败");
    }
    // 微信登录
    else if ([resp isKindOfClass:[SendAuthResp class]])
    {
        message = resp.errCode==WXSuccess?@"登录成功":(resp.errCode==WXErrCodeUserCancel?@"登录取消":@"登录失败");
    }
    
    if (self.block)
    {
        self.block(state,message,resp.copy);
    }
        
}

@end
