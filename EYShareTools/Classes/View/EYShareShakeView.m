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

#pragma mark- Lifecycle Methods
static EYShareShakeView *sharedEYShareShakeView = nil;

+ (EYShareShakeView *)sharedEYShareShakeView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEYShareShakeView = [[EYShareShakeView alloc] init];
    });
    return sharedEYShareShakeView;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedEYShareShakeView == nil)
        {
            sharedEYShareShakeView = [super allocWithZone:zone];
            return sharedEYShareShakeView;
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
        self.backgroundColor = [UIColor lightTextColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.alpha = 0.95;
    }
    return self;
}

/**
 计算分享面板显示高度
 
 @param shareBtnCount 分享渠道个数
 @return 分享面板显示高度
 */
- (NSInteger)getShareViewHeight:(NSInteger)shareBtnCount{
    NSInteger showHeight = kEYIphone6Scale(120) + (shareBtnCount>4?kEYIphone6Scale(180):kEYIphone6Scale(90)) + kEYSafeAreaBottom;
    return showHeight;
}

- (void)removeAllSubViews{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

-(void)setUpUIWithChannelArray:(NSArray *)channelArr  showUninstallApp:(BOOL)show{
    
    [EYShareShakeView sharedEYShareShakeView].frame = CGRectMake(0, kEYSCREEN_HEIGHT, kEYSCREEN_WIDTH, [self getShareViewHeight:channelArr.count]);
    [self removeAllSubViews];
    
    //top
    UIImageView* topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kEYIphone6Scale(300), 20)];
    topView.image = [UIImage imageNamed:@"Share_Pannel_Title_Decorator"];
    [self addSubview:topView];
    topView.top = kEYYGap;
    topView.centerX = kEYSCREEN_WIDTH/2;
    
    UILabel *topLabel = [[UILabel alloc]initWithFrame:topView.frame];
    topLabel.text = @"分享到";
    topLabel.textColor = [UIColor blackColor];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.font = [UIFont systemFontOfSize:kEYCancelButtonFontSize];
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
        
        UILabel *shareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kEYShareButtonWidth, 20)];
        shareLabel.text = shareLabelText;
        shareLabel.textColor = [UIColor blackColor];
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.adjustsFontSizeToFitWidth = YES;
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
    bottomView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:bottomView];
    bottomView.centerX = kEYSCREEN_WIDTH/2;
    
    UIButton *btnCancel = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btnCancel setTitle:@"取消" forState:(UIControlStateNormal)];
    [btnCancel setFrame:CGRectMake(0, self.bounds.size.height - kEYCancelButtonHeight - kEYSafeAreaBottom, self.bounds.size.width, kEYCancelButtonHeight)];
    [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
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

-(void)cancel:(id)sender
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(shareCancel:)]) {
        [delegate_ performSelector:@selector(shareCancel:) withObject:self];
    }
}

@end
