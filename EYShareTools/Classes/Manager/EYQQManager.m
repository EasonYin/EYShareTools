//
//  EYQQManager.m
//  EYShareTools
//
//

#import "EYQQManager.h"
#import "EYShareManagerUtil.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface EYQQManager ()<QQApiInterfaceDelegate,TencentSessionDelegate>
@property (nonatomic,strong) TencentOAuth* oauth;
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

-(TencentOAuth *)oauth{
    if (!_oauth) {
        _oauth = [[TencentOAuth alloc]initWithAppId:qqAppId andDelegate:self];
    }
    return _oauth;
}
#pragma mark - Public Methods
+ (void)registerApp:(NSString *)appid{
    qqAppId = appid;
    [EYQQManager sharedEYQQManager];
}

+(NSString *)getQQAppId{
    return qqAppId;
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

+ (BOOL)sendReqQQ:(id)message completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:message];
    return [QQApiInterface sendReq:req];
}

+ (BOOL)sendReqQQZone:(id)message completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:message];
    return [QQApiInterface SendReqToQZone:req];
}

+ (BOOL)authorize:(NSArray *)permissions completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    NSString *tempLocalAppId = @"";
    if ([EYQQManager getQQAppId]) {
        tempLocalAppId = [NSString stringWithFormat:@"tencent%@",[EYQQManager getQQAppId]];
    }
    return [[[EYQQManager sharedEYQQManager] oauth] authorize:permissions localAppId:tempLocalAppId inSafari:NO];
}

+ (BOOL)reauthorizeWithPermissions:(NSArray *)permissions completion:(_Nullable completionBlock)completion{
    [[EYQQManager sharedEYQQManager] setBlock:completion];
    
    return [[[EYQQManager sharedEYQQManager] oauth] reauthorizeWithPermissions:permissions];
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
    
}

#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin
{
    NSLog(@"tencentDidLogin:accessToken:%@ openId:%@ expireIn:%@", [[[EYQQManager sharedEYQQManager] oauth] accessToken], [[[EYQQManager sharedEYQQManager] oauth] openId], [[[EYQQManager sharedEYQQManager] oauth] expirationDate]);
    
    if (self.block) {
        self.block(YES, @"登录成功", [EYQQManager sharedEYQQManager]);
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
    
}

- (void)tencentDidNotNetWork
{
    if (self.block) {
        self.block(NO, @"登录失败", @"tencentDidNotNetWork");
    }
    
}

@end
