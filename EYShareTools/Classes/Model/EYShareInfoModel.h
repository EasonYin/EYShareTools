//
//  EYShareInfoModel.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface EYShareInfoModel : NSObject<NSCopying>

@property (nonatomic,strong) NSString *title;                   //标题
@property (nonatomic,strong) NSString *shareUrl;                //分享链接
@property (nonatomic,strong) NSString *iconUrl;                 //分享图片地址
@property (nonatomic,strong) NSData   *iconData;                //分享图片数据 二者都传则此数据优先展示
@property (nonatomic,strong) id        channel;                 //分享渠道
@property (nonatomic,strong) NSString *content;                 //分享内容
@property (nonatomic,strong) NSString *WeiBoContent;            //微博内容
@property (nonatomic,strong) NSString *WeiXinFriendsContent;    //微信朋友内容
@property (nonatomic,strong) NSString *WeiXinContent;           //微信好友内容
@property (nonatomic,strong) NSString *isCallBack;              //是否调用H5回调
@property (nonatomic,strong) NSString *mpId;                    //小程序id
@property (nonatomic,strong) NSString *mpPath;                  //小程序路径
@property (nonatomic,strong) NSString *mpIconUrl;               //小程序图片url


@end

NS_ASSUME_NONNULL_END
