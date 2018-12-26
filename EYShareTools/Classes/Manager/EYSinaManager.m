//
//  EYSinaManager.m
//  EYShareTools
//
//

#import "EYSinaManager.h"
#import "EYShareManagerUtil.h"

@interface EYSinaManager() <WeiboSDKDelegate>
@property (nonatomic,copy) completionBlock block;

@property (nonatomic,strong) NSString *appkey;
@property (nonatomic,strong) NSString *redirect_URL;

@property (nonatomic, strong) NSString *userID;         //用户ID
@property (nonatomic, strong) NSString *accessToken;    //认证口令
@property (nonatomic, strong) NSDate *expirationDate;   //认证过期时间
@property (nonatomic, strong) NSString *refreshToken;   //当认证口令过期时用于换取认证口令的更新口令

@end

@implementation EYSinaManager
#pragma mark - Lifecycle Methods
static EYSinaManager *sharedEYSinaManager = nil;

+ (EYSinaManager *)sharedEYSinaManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEYSinaManager = [[EYSinaManager alloc] init];
    });
    return sharedEYSinaManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedEYSinaManager == nil)
        {
            sharedEYSinaManager = [super allocWithZone:zone];
            return sharedEYSinaManager;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
#pragma mark - Property Methods
- (void)setAppkey:(NSString *)appkey{
    if (_appkey && ![_appkey isEqualToString:@""]) {
        NSLog(@"新浪appkey设置后无法重新设置！");
        return;
    }
    _appkey = appkey;
}

#pragma mark - Public Methods
+ (BOOL)registerApp:(NSString *)appKey{
    if (![EYShareManagerUtil validateString:appKey]) {
        return NO;
    }
    [[EYSinaManager sharedEYSinaManager] setAppkey:appKey];
    return [WeiboSDK registerApp:[[EYSinaManager sharedEYSinaManager] appkey]];
}

+(NSString *)getSianAppKey{
    return [[EYSinaManager sharedEYSinaManager]appkey];
}

+ (BOOL)isWeiboAppInstalled{
    return [WeiboSDK isWeiboAppInstalled];
}

+ (BOOL)isWeiboSupportApi{
    return [WeiboSDK isCanShareInWeiboAPP];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

+ (BOOL)sendShareReq:(WBMessageObject *)message target:(id<EYSinaManagerDelegate>)target completion:(completionBlock)completion{
    [[EYSinaManager sharedEYSinaManager] setSinaDelegate:target];
    [[EYSinaManager sharedEYSinaManager] setBlock:completion];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [EYSinaManager sharedEYSinaManager].redirect_URL;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:[EYSinaManager sharedEYSinaManager].accessToken];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    return [WeiboSDK sendRequest:request];
}

+ (BOOL)sendSSOReq:(WBAuthorizeRequest *)authRequest target:(id<EYSinaManagerDelegate>)target completion:(completionBlock)completion{
    [[EYSinaManager sharedEYSinaManager] setSinaDelegate:target];
    [[EYSinaManager sharedEYSinaManager] setBlock:completion];
    return [WeiboSDK sendRequest:authRequest];
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    NSLog(@"recevive ... ");
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    
    BOOL state;
    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        state = YES;
    }
    else{
        state = NO;
    }
    
    NSString *message = nil;
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSLog(@"WBBase 微博sdk发送消息");
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.accessToken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.userID = userID;
        }
        NSDate *expirationDate = [sendMessageToWeiboResponse.authResponse expirationDate];
        if (expirationDate) {
            self.expirationDate = expirationDate;
        }
        NSString *refreshToken = [sendMessageToWeiboResponse.authResponse refreshToken];
        if (refreshToken) {
            self.refreshToken = refreshToken;
        }
        
        message = response.statusCode==WeiboSDKResponseStatusCodeSuccess?@"分享成功":(response.statusCode==WeiboSDKResponseStatusCodeUserCancel?@"分享取消":@"分享失败");
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSLog(@"WBAuthorize认证结果 ");
        NSString* accessToken = [(WBAuthorizeResponse*)response accessToken];
        if (accessToken)
        {
            self.accessToken = accessToken;
        }
        NSString* userID = [(WBAuthorizeResponse*)response userID];
        if (userID) {
            self.userID = userID;
        }
        NSDate *expirationDate = [(WBAuthorizeResponse*)response expirationDate];
        if (expirationDate) {
            self.expirationDate = expirationDate;
        }
        NSString *refreshToken = [(WBAuthorizeResponse*)response refreshToken];
        if (refreshToken) {
            self.refreshToken = refreshToken;
        }
        message = response.statusCode==WeiboSDKResponseStatusCodeSuccess?@"认证成功":(response.statusCode==WeiboSDKResponseStatusCodeUserCancel?@"认证取消":@"认证失败");
        
    }
    //    else if ([response isKindOfClass:we.class])
    //    {
    //        NSLog(@"WBPayment支付结果 ");
    //    }
    
    if (self.block) {
        self.block(state, message, response);
    }
    
    if (self.sinaDelegate && [self.sinaDelegate respondsToSelector:@selector(SinaMessageFinishedState:Message:ResultInfo:)]) {
        [self.sinaDelegate SinaMessageFinishedState:state Message:message ResultInfo:response];
    }
}
@end
