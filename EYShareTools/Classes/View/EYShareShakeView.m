//
//  EYShareShakeView.m
//  EYShareTools
//
//

#import "EYShareShakeView.h"
#import "EYShareManagerUtil.h"
#import "EYShareToolsConfigure.h"
#import "EYQQManager.h"
#import "EYWXManager.h"
#import "EYSinaManager.h"

/**
 * 标示分享渠道tag
 */
typedef NS_ENUM(NSUInteger, _EYShareChanelType) {
    Channel_Wxfriends,  //微信
    Channel_Wxmoments,  //朋友圈
    Channel_QQfriends,  //QQ
    Channel_QQzone,     //QQ空间
    Channel_Sinaweibo,  //新浪
    Channel_CopyURL,    //复制链接
    Channel_QRCode,     //二维码
};

@implementation EYShareShakeView
@synthesize delegate = delegate_;

- (void)removeAllSubViews{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [EYShareManagerUtil colorWithHex:@"#f1f1f1"];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.alpha = 0.95;
        [self setUpUIWithChannelArray:@[Share_Wxfriends,Share_Wxmoments,Share_QQfriends,Share_QQZone,Share_Sinaweibo,Share_CopyURL] showUninstallApp:YES];
    }
    return self;
}

-(void)setUpUIWithChannelArray:(NSArray *)channelArr  showUninstallApp:(BOOL)show{
    [self removeAllSubViews];
    
    //top
    UIImageView* topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kEYIphone6Scale(300), 20)];
    topView.image = [UIImage imageNamed:@"Share_Pannel_Title_Decorator"];
    [self addSubview:topView];
    topView.top = kEYYGap;
    topView.centerX = kEYSCREEN_WIDTH/2;
    
    UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    topLabel.text = @"分享到";
    topLabel.textColor = [EYShareManagerUtil colorWithHex:@"#000000"];
    topLabel.font = [UIFont systemFontOfSize:kEYShareButtonFontSize];
    [self addSubview:topLabel];
    topLabel.top = kEYYGap;
    topLabel.centerX = kEYSCREEN_WIDTH/2;
    
    NSMutableArray *btnArr = [NSMutableArray array];
    NSMutableArray *labelArr = [NSMutableArray array];
    
    for (int i = 0; i < channelArr.count; i ++) {
        NSString *imageName = @"";
        NSString *shareLabelText = @"";
        int channelTag = 0;
        SWITCH(channelArr[i]){
            CASE(Share_Wxfriends){
                imageName       = @"Button_Wechat_Share";
                shareLabelText  = @"微信好友";
                channelTag      = Channel_Wxfriends;
                break;
            }
            CASE(Share_Wxmoments){
                imageName       = @"Button_WechatTimeline_Share";
                shareLabelText  = @"朋友圈";
                channelTag      = Channel_Wxmoments;
                break;
            }
            CASE(Share_QQfriends){
                imageName       = @"Button_QQ_Share";
                shareLabelText  = @"QQ好友";
                channelTag      = Channel_QQfriends;
                break;
            }
            CASE(Share_QQZone){
                imageName       = @"Button_QQZone_Share";
                shareLabelText  = @"QQ空间";
                channelTag      = Channel_QQzone;
                break;
            }
            CASE(Share_Sinaweibo){
                imageName       = @"Button_Sina_Weibo_Share";
                shareLabelText  = @"新浪微博";
                channelTag      = Channel_Sinaweibo;
                break;
            }
            CASE(Share_CopyURL){
                imageName       = @"Button_Copy_URL";
                shareLabelText  = @"复制链接";
                channelTag      = Channel_CopyURL;
                break;
            }
            CASE(Share_QRCode){
                imageName       = @"Button_QR_Share";
                shareLabelText  = @"二维码分享";
                channelTag      = Channel_QRCode;
                break;
            }
            DEFAULT{
                break;
            }
        };
        
        /*
         * 默认显示全部，若关闭全部显示，则只显示手机上安装的渠道
         */
#if !(TARGET_IPHONE_SIMULATOR)
        if (!show) {
            if ((![EYWXManager isWXAppInstalled] && [channelArr[i] isEqualToString:Share_Wxfriends]) || (![EYWXManager isWXAppInstalled] && [channelArr[i] isEqualToString:Share_Wxmoments])|| (![EYQQManager isQQorTIMInstalled] && [channelArr[i] isEqualToString:Share_QQfriends]) || (![EYQQManager isQQorTIMInstalled] && [channelArr[i] isEqualToString:Share_QQZone]) || (![EYSinaManager isWeiboAppInstalled] && [channelArr[i] isEqualToString:Share_Sinaweibo])){
                continue;
            }
        }
#else
#endif
        
        UIButton *shareBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [shareBtn setFrame:CGRectMake(0.0, 0.0,
                                      kEYShareButtonWidth, kEYShareButtonWidth)];
        [shareBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [shareBtn addTarget:self action:@selector(shareToClient:) forControlEvents:(UIControlEventTouchUpInside)];
        [shareBtn setTag:channelTag];
        [self addSubview:shareBtn];
        [btnArr addObject:shareBtn];
        
        UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        shareLabel.text = shareLabelText;
        shareLabel.textColor = [EYShareManagerUtil colorWithHex:@"#000000"];
        shareLabel.font = [UIFont systemFontOfSize:kEYShareButtonFontSize];
        [self addSubview:shareLabel];
        [labelArr addObject:shareLabel];
    }
    
    //页面布局
    //    CGFloat btnGap = ((kEYSCREEN_WIDTH-(btnArr.count<4?btnArr.count:4)*kEYShareButtonWith-(kEYXGap+kEYXGap)*2)/((btnArr.count<4?btnArr.count:4)+1))?:0.0;
    for (int i = 0; i < btnArr.count; i ++) {
        UIButton *btn = (UIButton*)btnArr[i];
        btn.top = topView.bottom + (i>3?kEYShareButtonImageSecondTopSpace:kEYShareButtonImageTopSpace);
        //        btn.left = btnArr.count<4?(kEYXGap+kEYXGap*(btnArr.count==2?1:(i+1>4?i-4:i))+kEYShareButtonWith*(i+1>4?i-4:i) + btnGap*((i+1>4?i-4:i)+1)):(kEYXGap*((i>3?i-4:i)+1) + kEYXGap * (i>3?i-4:i));
        btn.left = kEYXGap*((i>3?i-4:i)+1) + kEYXGap * (i>3?i-4:i);
        
        UILabel *label = (UILabel*)labelArr[i];
        label.top = btn.bottom + kEYIphone6Scale(6.0);
        label.centerX = btn.centerX;
    }
    
    UIImageView* bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-kEYCancelButtonHeight-(1.5/2) - kEYSafeAreaBottom, kEYIphone6Scale(300), 1.5/2)];
    bottomView.backgroundColor = [EYShareManagerUtil colorWithHex:@"#bababa"];
    [self addSubview:bottomView];
    bottomView.centerX = kEYSCREEN_WIDTH/2;
    
    UIButton *btnCancel = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btnCancel setTitle:@"取消" forState:(UIControlStateNormal)];
    [btnCancel setFrame:CGRectMake(0, self.bounds.size.height - kEYCancelButtonHeight - kEYSafeAreaBottom, self.bounds.size.width, kEYCancelButtonHeight)];
    [btnCancel setTitleColor:[EYShareManagerUtil colorWithHex:@"#000000"] forState:UIControlStateNormal];
    [btnCancel setTitleColor:[EYShareManagerUtil colorWithHex:@"#000000"] forState:UIControlStateHighlighted];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:kEYCancelButtonFontSize];
    [btnCancel addTarget:self action:@selector(cancel:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:btnCancel];
    
}

- (void)shareToClient:(UIButton*)sender{
    switch (sender.tag) {
        case Channel_Wxfriends:
            [self shareToWeChat];
            break;
        case Channel_Wxmoments:
            [self shareToWeChatFriend];
            break;
        case Channel_QQfriends:
            [self shareToQQ];
            break;
        case Channel_QQzone:
            [self shareToQQZone];
            break;
        case Channel_Sinaweibo:
            [self shareToWeibo];
            break;
        case Channel_CopyURL:
            [self copyURL];
            break;
        case Channel_QRCode:
            [self shareToQRCode];
            break;
            
        default:
            break;
    }
}

-(void)shareToWeibo
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareToClient:)]) {
        [delegate_ performSelector:@selector(shareToClient:) withObject:Share_Sinaweibo];
    }
}

-(void)shareToWeChat
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareToClient:)]) {
        [delegate_ performSelector:@selector(shareToClient:) withObject:Share_Wxfriends];
    }
}

-(void)shareToWeChatFriend
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareToClient:)]) {
        [delegate_ performSelector:@selector(shareToClient:) withObject:Share_Wxmoments];
    }
}

-(void)shareToQQ
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareToClient:)]) {
        [delegate_ performSelector:@selector(shareToClient:) withObject:Share_QQfriends];
    }
}

-(void)shareToQQZone
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareToClient:)]) {
        [delegate_ performSelector:@selector(shareToClient:) withObject:Share_QQZone];
    }
}

- (void)copyURL{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareToClient:)]) {
        [delegate_ performSelector:@selector(shareToClient:) withObject:Share_CopyURL];
    }
}

- (void)shareToQRCode{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareToClient:)]) {
        [delegate_ performSelector:@selector(shareToClient:) withObject:Share_QRCode];
    }
}

-(void)cancel:(id)sender
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareCancel:)]) {
        [delegate_ performSelector:@selector(shareCancel:) withObject:self];
    }
}

@end
