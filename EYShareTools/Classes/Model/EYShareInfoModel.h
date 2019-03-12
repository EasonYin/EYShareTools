//
//  EYShareInfoModel.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EYShareInfoModel : NSObject<NSCopying>

/*
 * 普通分享相关参数
 */
//标题
@property (nonatomic,strong) NSString *title;

//分享链接
@property (nonatomic,strong) NSString *shareUrl;

//分享图片地址
@property (nonatomic,strong) NSString *iconUrl;

//分享图片数据 注：与iconUrl共存时则优先使用iconData
@property (nonatomic,strong) NSData   *iconData;

//分享渠道
@property (nonatomic,strong) id channel;

//分享内容
@property (nonatomic,strong) NSString *content;

//微博内容 微博渠道优先展示，不设置则为content
@property (nonatomic,strong) NSString *WeiBoContent;

//微信朋友内容 微信朋友圈分享渠道优先展示，不设置则为content
@property (nonatomic,strong) NSString *WeiXinFriendsContent;

//微信好友内容 微信好友分享渠道优先展示，不设置则为content
@property (nonatomic,strong) NSString *WeiXinContent;

//是否调用H5回调
@property (nonatomic,strong) NSString *isCallBack;

//分享后的url后面拼接字符串
@property (nonatomic,strong) NSString *appendString;

/*
 * 小程序分享相关参数
 */
//小程序id
@property (nonatomic,strong) NSString *mpId;

//小程序路径
@property (nonatomic,strong) NSString *mpPath;

//小程序图片url
@property (nonatomic,strong) NSString *mpIconUrl;

//小程序分享类型 0：正式    1：开发   2：体验
@property (nonatomic,strong) NSString *miniProgramType;


@end

NS_ASSUME_NONNULL_END
