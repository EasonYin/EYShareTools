//
//  EYShareManager.m
//  EYShareTools
//
//

#import "EYShareManager.h"
#import "EYShareToolsConfigure.h"
#import "EYShareShakeView.h"
#import "EYShareManagerUtil.h"
#import "EYQQManager.h"
#import "EYWXManager.h"
#import "EYSinaManager.h"

typedef NS_ENUM(NSInteger , InstantType) {
    kInstantTypeFinish,
    kInstantTypeFail,
    kInstantTypeOnlyMessage,
};

@interface EYShareManager()<EYWXManagerDelegate,EYQQManagerDelegate,EYSinaManagerDelegate,EYShareShakeDelegate>
{
    EYShareInfoModel  *_shareModel;
    EYShareShakeView  *_shareView;        //分享view
    UIButton          *_maskView;         //
    BOOL               _isShowing;        //标识分享面板是否在显示中
    BOOL               _showUninstallApp; //是否显示未安装应用
}
@property (nonatomic,copy) NSString *clientString;
@property (nonatomic,copy) EYShareCompletionBlock completionBlock;
@property (nonatomic,copy) EYShareBeginBlock beginBlock;
@property (nonatomic,copy) EYShareSelectClientBlock selectClientBlock;
@property (nonatomic,copy) EYShareCancelBlock cancelBlock;
@end

@implementation EYShareManager

#pragma mark- Lifecycle Methods
static EYShareManager *sharedEYShareManager = nil;

+ (EYShareManager *)sharedEYShareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEYShareManager = [[EYShareManager alloc] init];
    });
    return sharedEYShareManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedEYShareManager == nil)
        {
            sharedEYShareManager = [super allocWithZone:zone];
            return sharedEYShareManager;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(id)init
{
    if (self = [super init])
    {
        _showUninstallApp = YES;
        
        [self initShareView];
    }
    return self;
}

#pragma mark- Public Methods
- (BOOL)isShowing
{
    return _isShowing;
}

-(void)cancel
{
    UIViewController *currentCtrler = [[[UIApplication sharedApplication]keyWindow]rootViewController];
    
    _maskView.hidden = YES;
    [_maskView removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        if (self->_shareView ) {
            self->_shareView.center = CGPointMake(currentCtrler.view.size.width / 2, currentCtrler.view.size.height + self->_shareView.size.height / 2) ;
        }
    } completion:^(BOOL finished) {
        [self->_shareView removeFromSuperview];
        self->_isShowing = NO;
    }];
}

-(void)disableUnInstallApp{
    _showUninstallApp = NO;
    [_shareView setUpUIWithChannelArray:@[Share_Wxfriends,Share_Wxmoments,Share_QQfriends,Share_QQZone,Share_Sinaweibo,Share_CopyURL] showUninstallApp:_showUninstallApp];
}

- (void)shareWithTarget:(id)target channel:(NSArray *)channelArr shareModel:(EYShareInfoModel *)model begin:(EYShareBeginBlock)beginBlock selectClient:(EYShareSelectClientBlock)selectClientBlock cancel:(EYShareCancelBlock)cancelBlock completion:(EYShareCompletionBlock)completion{
    
    self.delegate = target;
    self.beginBlock = beginBlock;
    self.selectClientBlock = selectClientBlock;
    self.cancelBlock = cancelBlock;
    self.completionBlock = completion;
    
    if (_shareModel != model) {
        _shareModel = model;
    }
    
    [self checkShareModelInfo];
    
    if (!channelArr || channelArr.count == 0) {
        channelArr = @[Share_Wxfriends,Share_Wxmoments,Share_QQfriends,Share_QQZone,Share_Sinaweibo,Share_CopyURL];
    }
    
    NSInteger shareBtnCount = channelArr.count;
    
#if !(TARGET_IPHONE_SIMULATOR)
    if (!_showUninstallApp) {
        NSMutableArray *tempChannelArr = channelArr.mutableCopy;
        for (NSInteger i = channelArr.count-1; i >= 0; i --) {
            if ((![EYWXManager isWXAppInstalled] && [channelArr[i] isEqualToString:Share_Wxfriends]) || (![EYWXManager isWXAppInstalled] && [channelArr[i] isEqualToString:Share_Wxmoments])|| (![EYQQManager isQQorTIMInstalled] && [channelArr[i] isEqualToString:Share_QQfriends]) || (![EYQQManager isQQorTIMInstalled] && [channelArr[i] isEqualToString:Share_QQZone]) || (![EYSinaManager isWeiboAppInstalled] && [channelArr[i] isEqualToString:Share_Sinaweibo])){
                [tempChannelArr removeObjectAtIndex:i];
                shareBtnCount --;
            }
        }
        channelArr = tempChannelArr;
    }
#else
#endif
    
    if (_shareView.superview) {
        [_shareView removeFromSuperview];
    }
    
    if (_maskView.superview) {
        [_maskView removeFromSuperview];
    }
    
    if (shareBtnCount == 0) {
        
        self.beginBlock(NO);
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，您尚未安装相应软件！"];
        
    }
    else{
        
        self.beginBlock(YES);
        
        if ([self.delegate respondsToSelector:@selector(shareBeginWithShareModel:)]) {
            [self.delegate shareBeginWithShareModel:_shareModel];
        }
        
        if (shareBtnCount == 1){
            [self shareToClient:channelArr[0]];
        }
        else{
            
            [_shareView setUpUIWithChannelArray:channelArr showUninstallApp:_showUninstallApp];
            
            _isShowing = YES;
            _maskView.hidden = NO;
            if (!_maskView.superview) {
                [[UIApplication sharedApplication].keyWindow addSubview:_maskView];
            }
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_maskView];
            
            if (!_shareView.superview) {
                [[UIApplication sharedApplication].keyWindow addSubview:_shareView];
            }
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_shareView];
            
            [UIView animateWithDuration:0.2 animations:^{
                if (self->_shareView ) {
                    CGRect rect  = self->_shareView.frame;
                    rect.origin.y = CGRectGetHeight([UIApplication sharedApplication].keyWindow.frame) - self->_shareView.height;
                    self->_shareView.frame = rect;
                }
            } completion:^(BOOL finished) {
                
            }];
            
        }
    }
    
}

#pragma mark- Private Methods
- (void)initShareView{

    _shareView = [EYShareShakeView sharedEYShareShakeView];
    _shareView.delegate = self;
    
    _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
    _maskView.frame = (CGRect){0,0,kEYSCREEN_WIDTH,kEYSCREEN_HEIGHT};
    _maskView.backgroundColor = [UIColor clearColor];
    _maskView.alpha = 1.0;
    [_maskView addTarget:self action:@selector(shareCancel:) forControlEvents:UIControlEventTouchUpInside];

}


/**
 *   分享到新浪微博
 *   新版本sdk微博分享
 */
-(void)shareToSina
{
    
    if (![EYSinaManager isWeiboAppInstalled] || ![EYSinaManager isWeiboSupportApi]) {
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，您没有安装微博或您的微博版本过低"];
        return;
    }
    
    if ([EYSinaManager getSianAppKey].length <= 0) {
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，此应用未授权！"];
        return;
    }
    
    //分享内容到微博
    WBMessageObject *message = [WBMessageObject message];
    message.text = [NSString stringWithFormat:@"%@",_shareModel.WeiBoContent];//[ShareManagerUtil subString:_shareModel.WeiBoContent length:139];
    WBImageObject *imagedata = [WBImageObject object];
    imagedata.imageData = [EYShareManagerUtil loadingImageUrl:_shareModel.iconUrl imageData:_shareModel.iconData length:kEYWBShareMaxImageBytes];
    message.imageObject = imagedata;
    
    //    WBWebpageObject *webObj = [WBWebpageObject object];
    //    webObj.objectID = @"EYShareWeibo";
    //    webObj.webpageUrl = _shareModel.shareUrl;
    //    webObj.title = _shareModel.title;
    //    webObj.description = _shareModel.WeiBoContent;
    //    webObj.thumbnailData = [EYShareManagerUtil loadingImageUrl:_shareModel.iconUrl imageData:_shareModel.iconData length:kEYWXShareMaxImageBytes];
    //    message.mediaObject = webObj;
    
    [EYSinaManager sendShareReq:message target:self completion:nil];
}

/**
 *   分享到微信相关
 */
- (void) shareToWeChat
{
    
    // 是否安装微信
    if (![EYWXManager isWXAppInstalled] || ![EYWXManager isWXAppInstalled]) {
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，您没有安装微信或您的微信版本过低"];
        return;
    }
    
    if ([EYWXManager getWXAppId].length <= 0) {
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，此应用未授权！"];
        return;
    }
    
    //微信类分享URL 不能为空
    if (!_shareModel.shareUrl || [_shareModel.shareUrl isEqual:@""]) {
        [self showDialogWithState:(kInstantTypeFail) Msg:@"分享url不能为空。"];
        return;
    }
    
    //mediaObject
    WXWebpageObject *mediaObject = [WXWebpageObject object];
    mediaObject.webpageUrl = [EYShareManagerUtil reBuildShareURL:_shareModel.shareUrl resourceValue:Share_Wxfriends];
    
    NSString *msg = _shareModel.WeiXinContent;//[ShareManagerUtil subString:_shareModel.WeiXinContent length:300];
    //朋友圈定制
    if ([self.clientString isEqualToString:Share_Wxmoments] &&
        [EYShareManagerUtil validateString:_shareModel.WeiXinFriendsContent])
    {
        mediaObject.webpageUrl = [EYShareManagerUtil reBuildShareURL:_shareModel.shareUrl resourceValue:Share_Wxmoments];
        msg = _shareModel.WeiXinFriendsContent;
        
    }
    
    //message
    WXMediaMessage *message = [WXMediaMessage message];
    //1.标题150 2.description 300
    message.title = _shareModel.title;//[ShareManagerUtil subString:_shareModel.title length:150];
    message.description = msg;
    message.thumbData = [EYShareManagerUtil loadingImageUrl:_shareModel.iconUrl imageData:_shareModel.iconData length:kEYWXShareMaxImageBytes];
    
    //小程序
    if ([self.clientString isEqualToString:Share_Wxfriends] && _shareModel.mpId.length > 0 && _shareModel.mpPath.length > 0 && _shareModel.mpIconUrl.length > 0) {
        WXMiniProgramObject *wxMiniObject = [WXMiniProgramObject object];
        wxMiniObject.webpageUrl = [EYShareManagerUtil reBuildShareURL:_shareModel.shareUrl resourceValue:Share_Wxfriends];//兼容低版本网页链接
        wxMiniObject.userName = _shareModel.mpId;//小程序原始ID gh_59e78e4833f7
        wxMiniObject.path = _shareModel.mpPath;//小程序页面路径
        wxMiniObject.hdImageData = [EYShareManagerUtil loadingImageUrl:_shareModel.mpIconUrl imageData:nil length:kEYWXMiniShareMaxImageBytes];//小程序节点高清大图，128k
        wxMiniObject.withShareTicket = YES;
        wxMiniObject.miniProgramType = WXMiniProgramTypeRelease;
        
        message.mediaObject = wxMiniObject;
    }else{
        message.mediaObject = mediaObject;
    }
    
    //req
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    //mta
    if([self.clientString isEqualToString:Share_Wxfriends])
    {
        req.scene = WXSceneSession;
    }
    else if ([self.clientString isEqualToString:Share_Wxmoments])
    {
        req.scene = WXSceneTimeline;
    }
    
    [EYWXManager sendReq:req target:self completion:nil];
}

/*
 *  微信中打开小程序
 */
-(void)openMiniProgramInWeChat{
    
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName = _shareModel.mpId;  //拉起的小程序的username
    launchMiniProgramReq.path = _shareModel.mpPath;    //拉起小程序页面的可带参路径，不填默认拉起小程序首页
    launchMiniProgramReq.miniProgramType = WXMiniProgramTypeRelease; //拉起小程序的类型
    
    [EYWXManager sendReq:launchMiniProgramReq target:self completion:nil];
}

/**
 *   分享到QQ相关
 *   标题，url不能为空
 */
-(void)shareToQQ
{
    if (![EYQQManager isQQorTIMInstalled]){
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，您尚未安装QQ或TIM"];
        return;
    }
    
    if (![EYQQManager isQQorTIMSupportApi]){
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，您的QQ或TIM版本过低"];
        return;
    }
    
    if ([EYQQManager getQQAppId].length <= 0) {
        [self showDialogWithState:(kInstantTypeFail) Msg:@"抱歉，此应用未授权！"];
        return;
    }
    
    //qq类分享URL 不能为空
    if (!_shareModel.shareUrl || [_shareModel.shareUrl isEqual:@""]) {
        [self showDialogWithState:(kInstantTypeFail) Msg:@"分享url不能为空。"];
        return;
    }
    
    //1.标题最长128个字符   2.简要描述最长512个字符
    /*
     * 不需要截取，多出字符...显示
     */
    NSString *urlStr = _shareModel.shareUrl?_shareModel.shareUrl:@"";
    NSString *title = _shareModel.title;//[ShareManagerUtil subString:_shareModel.title length:60];
    NSString *description = _shareModel.WeiXinContent;//[ShareManagerUtil subString:_shareModel.WeiXinContent length:200];
    NSData *imageData = [EYShareManagerUtil loadingImageUrl:_shareModel.iconUrl imageData:_shareModel.iconData length:kEYQQShareMaxImageBytes];
    
    QQApiNewsObject* sendObj= [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlStr]
                                                       title:title
                                                 description:description
                                            previewImageData:imageData];
    NSURL *URL = [NSURL URLWithString:[EYShareManagerUtil reBuildShareURL:urlStr resourceValue:Share_QQfriends]];
    sendObj.url = URL;
    
    if ([self.clientString isEqualToString:Share_QQfriends])
    {
        NSURL *URL = [NSURL URLWithString:[EYShareManagerUtil reBuildShareURL:urlStr resourceValue:Share_QQfriends]];
        sendObj.url = URL;
        [EYQQManager sendReqQQ:sendObj target:self completion:nil];
    }
    else if([self.clientString isEqualToString:Share_QQZone])
    {
        NSURL *URL = [NSURL URLWithString:[EYShareManagerUtil reBuildShareURL:urlStr resourceValue:Share_QQZone]];
        sendObj.url = URL;
        [EYQQManager sendReqQQZone:sendObj target:self completion:nil];
    }
}

//复制链接
- (void)copyURL{
    
    [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@",[EYShareManagerUtil reBuildShareURL:_shareModel.shareUrl?_shareModel.shareUrl:@"" resourceValue:Share_CopyURL]];
    [self didReceiveShareResaultMessageFinishedState:YES Message:@"复制成功" ResultInfo:nil];
}

//增加对数据判空处理
- (void)checkShareModelInfo
{
    if (![EYShareManagerUtil validateString:_shareModel.shareUrl]) {
        _shareModel.shareUrl = self.defaultShareUrl?:kEYShareDefaultShareUrl;
    }
    if(![EYShareManagerUtil validateString:_shareModel.title]){
        _shareModel.title = self.defaultShareTitle?:kEYShareDefaultTitle;
    }
    if (![EYShareManagerUtil validateString:_shareModel.WeiXinContent]){
        _shareModel.WeiXinContent = self.defaultShareMessage?:[EYShareManagerUtil validateString:_shareModel.content]?_shareModel.content:kEYShareDefaultMesasage;
    }
    if (![EYShareManagerUtil validateString:_shareModel.WeiXinFriendsContent]){
        _shareModel.WeiXinFriendsContent = self.defaultShareMessage?:[EYShareManagerUtil validateString:_shareModel.content]?_shareModel.content:kEYShareDefaultMesasage;
    }
    if (![EYShareManagerUtil validateString:_shareModel.WeiBoContent]){
        _shareModel.WeiBoContent = self.defaultShareMessage?:[EYShareManagerUtil validateString:_shareModel.content]?_shareModel.content:kEYShareDefaultMesasage;
    }
}

- (void)showDialogWithState:(InstantType)state Msg:(NSString *)msg{
    
    NSString *title = @"";
    switch (state) {
        case kInstantTypeOnlyMessage:
        {
            title = @"";
        }
            break;
        case kInstantTypeFail:
        {
            title = @"失败";
        }
            break;
        case kInstantTypeFinish:
        {
            title = @"成功";
        }
            break;

        default:
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    [[[[UIApplication sharedApplication]keyWindow]rootViewController] presentViewController:alert animated:YES completion:nil];
    
}

-(void)shareToClient:(NSString *)client
{
    self.clientString = client;
    [self cancel];
    self.selectClientBlock(client);
    
    if ([self.delegate respondsToSelector:@selector(shareToClient:shareModel:)]) {
        [self.delegate shareToClient:self.clientString shareModel:_shareModel];
    }
    
    SWITCH(self.clientString){
        CASE(Share_Sinaweibo){
            [self shareToSina];
            break;
        }
        CASE(Share_QQfriends){
            [self shareToQQ];
            break;
        }
        CASE(Share_QQZone){
            [self shareToQQ];
            break;
        }
        CASE(Share_Wxfriends){
            [self shareToWeChat];
            break;
        }
        CASE(Share_Wxmoments){
            [self shareToWeChat];
            break;
        }
        CASE(Share_CopyURL){
            [self copyURL];
            break;
        }
    }
}

-(void)shareCancel:(UIView*)view
{
    if ([self.delegate respondsToSelector:@selector(shareCancelWithShareModel:)]) {
        [self.delegate shareCancelWithShareModel:_shareModel];
    }
    self.cancelBlock();
    [self cancel];
}

#pragma mark - EYManagerDelegate
-(void)WXMessageFinishedState:(BOOL)state Message:(NSString *)message ResultInfo:(id)resultInfo{
    [self didReceiveShareResaultMessageFinishedState:state Message:message ResultInfo:resultInfo];
}
-(void)SinaMessageFinishedState:(BOOL)state Message:(NSString *)message ResultInfo:(id)resultInfo{
    [self didReceiveShareResaultMessageFinishedState:state Message:message ResultInfo:resultInfo];
}
-(void)QQMessageFinishedState:(BOOL)state Message:(NSString *)message ResultInfo:(id)resultInfo{
    [self didReceiveShareResaultMessageFinishedState:state Message:message ResultInfo:resultInfo];
}

-(void)didReceiveShareResaultMessageFinishedState:(BOOL)state Message:(NSString *)message ResultInfo:(id)resultInfo
{
    NSMutableDictionary *dicInfo = @{@"shareResult":[NSNumber numberWithInteger:EY_share_resault_type_none],
                                     @"shareChannel":self.clientString
                                     }.mutableCopy;
    
    if ([message isEqualToString:@"分享成功"] || [message isEqualToString:@"复制成功"]) {
        //成功
        [dicInfo setObject:[NSNumber numberWithInteger:EY_share_resault_type_success] forKey:@"shareResult"];
        
    }else if ([message isEqualToString:@"分享取消"]){
        //取消
        [dicInfo setObject:[NSNumber numberWithInteger:EY_share_resault_type_cancel] forKey:@"shareResult"];
        
    }else{
        //失败
        [dicInfo setObject:[NSNumber numberWithInteger:EY_share_resault_type_fail] forKey:@"shareResult"];
        
    }
    
    [self showDialogWithState:!state Msg:message];
    
    if (self.completionBlock)
    {
        self.completionBlock(state,dicInfo,_shareModel.isCallBack);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareFinishedWithState:resultInfo:shareModel:)])
    {
        [self.delegate shareFinishedWithState:state resultInfo:dicInfo shareModel:_shareModel];
    }
}
@end
