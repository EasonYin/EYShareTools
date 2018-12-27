//
//  EYQQManager.m
//  EYShareTools
//
//

#import "EYQQManager.h"
#import "EYShareManagerUtil.h"

@interface EYQQManager ()<QQApiInterfaceDelegate,TencentSessionDelegate>
@property (nonatomic,copy) completionBlock block;
@end

static NSString *qqAppId;

@implementation EYQQManager

#pragma mark - Lifecycle Methods
static EYQQManager *sharedEYQQManager = nil;

+ (EYQQManager *)sharedEYQQManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEYQQManager = [[EYQQManager alloc] init];
    });
    return sharedEYQQManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedEYQQManager == nil)
        {
            sharedEYQQManager = [super allocWithZone:zone];
            return sharedEYQQManager;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(instancetype)init{
    return [super initWithAppId:qqAppId andDelegate:self];
}

#pragma mark - Public Methods
+ (void)registerApp:(NSString *)appid{
    qqAppId = appid;
    [EYQQManager sharedEYQQManager];
}

+(NSString *)getQQAppId{
    return [[EYQQManager sharedEYQQManager] appId];
}

+ (BOOL)isQQorTIMInstalled
{
    BOOL state;
    if ([QQApiInterface isQQInstalled]) {
        state = YES;
    }
    else if ([QQApiInterface isTIMInstalled]){
        state = YES;
    }
    else{
        state = NO;
    }
    return state;
}

+ (BOOL)isQQorTIMSupportApi
{
    BOOL state;
    if ([QQApiInterface isQQSupportApi]) {
        state = YES;
    }
    else if ([QQApiInterface isTIMInstalled]){
        state = YES;
    }
    else{
        state = NO;
    }
    return state;
}

- (BOOL)handleOpenURL:(NSURL *)url{
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    else{
        return [QQApiInterface handleOpenURL:url delegate:self];
    }
}

+ (QQApiSendResultCode)sendReqQQ:(QQApiNewsObject *)message target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setQqDelegate:target];
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:message];
    return [QQApiInterface sendReq:req];
}

+ (QQApiSendResultCode)sendReqQQZone:(QQApiNewsObject *)message target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setQqDelegate:target];
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:message];
    return [QQApiInterface SendReqToQZone:req];
}

+ (BOOL)authorize:(NSArray *)permissions target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setQqDelegate:target];
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    NSString *tempLocalAppId = @"";
    if ([[EYQQManager sharedEYQQManager] appId]) {
        tempLocalAppId = [NSString stringWithFormat:@"tencent%@",[[EYQQManager sharedEYQQManager] appId]];
    }
    return [[EYQQManager sharedEYQQManager] authorize:permissions localAppId:tempLocalAppId inSafari:NO];
}

+ (BOOL)reauthorizeWithPermissions:(NSArray *)permissions target:(id<EYQQManagerDelegate>)target completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setQqDelegate:target];
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    return [[EYQQManager sharedEYQQManager] reauthorizeWithPermissions:permissions];
}

#pragma mark - QQSDKDelegate
/**
 处理来至QQ的请求
 */
- (void)onReq:(QQBaseReq *)req
{
    
}

//处理QQ在线状态的回调
- (void)isOnlineResponse:(NSDictionary *)response
{
    
}

//处理来至QQ的响应
- (void)onResp:(QQBaseResp *)resp
{
    BOOL state;
    NSString *message = nil;
    
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            if ([sendResp.result isEqualToString:@"0"])
            {
                state = YES;
                message = @"分享成功";
                break;
            }
            else if ([sendResp.result isEqualToString:@"-4"])
            {
                state = NO;
                message = @"分享取消";
                break;
            }
            else if ([sendResp.result isEqualToString:@"-1"])
            {
                state = NO;
                message = @"分享失败";
                break;
            }
        }
        default:
        {
            state = NO;
            message = @"分享失败";
            break;
        }
    }
    
    if (self.block) {
        self.block(state, message, resp.copy);
    }
    
    if (self.qqDelegate && [self.qqDelegate respondsToSelector:@selector(QQMessageFinishedState:Message:ResultInfo:)]) {
        [self.qqDelegate QQMessageFinishedState:state Message:message ResultInfo:resp.copy];
    }
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin
{
    NSLog(@"tencentDidLogin:accessToken:%@ openId:%@ expireIn:%@", [self accessToken], [self openId], [self expirationDate]);
    
    if (self.block) {
        self.block(YES, @"登录成功", [EYQQManager sharedEYQQManager]);
    }
    if (self.qqDelegate && [self.qqDelegate respondsToSelector:@selector(QQMessageFinishedState:Message:ResultInfo:)]) {
        [self.qqDelegate QQMessageFinishedState:YES Message:@"登录成功" ResultInfo:[EYQQManager sharedEYQQManager]];
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSString *message = nil;
    if (cancelled) {
        message = @"登录取消";
    }
    else{
        message = @"登录失败";
    }
    
    if (self.block) {
        self.block(NO, message, @"tencentDidNotLogin");
    }
    
    if (self.qqDelegate && [self.qqDelegate respondsToSelector:@selector(QQMessageFinishedState:Message:ResultInfo:)]) {
        [self.qqDelegate QQMessageFinishedState:NO Message:message ResultInfo:@"tencentDidNotLogin"];
    }
}

- (void)tencentDidNotNetWork
{
    if (self.block) {
        self.block(NO, @"登录失败", @"tencentDidNotNetWork");
    }
    
    if (self.qqDelegate && [self.qqDelegate respondsToSelector:@selector(QQMessageFinishedState:Message:ResultInfo:)]) {
        [self.qqDelegate QQMessageFinishedState:NO Message:@"登录失败" ResultInfo:@"tencentDidNotNetWork"];
    }
}

@end
