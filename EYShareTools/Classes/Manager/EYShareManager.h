//
//  EYShareManager.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>
#import "EYShareInfoModel.h"

//分享结果，与jdshare组件结果对应，方便给js回调参数
typedef NS_ENUM(NSUInteger, EYShareResaultType) {
    EY_share_resault_type_success = 0,   //成功
    EY_share_resault_type_fail,          //失败
    EY_share_resault_type_cancel,        //取消
    EY_share_resault_type_none
};

/**
 *  回调参数
 *
 *  @state               bool               是否成功
 *  @resultInfo          NSDictionary       回调结果，方便给js回调参数
 *      @"shareResult"   NSString           分享结果 0:成功 1:失败 2:取消
 *      @"shareChannel"  NSString           分享渠道 see EYShareManagerUtil
 *  @isCallBack          NSString           是否调用H5回调方法
 */
typedef void(^EYShareCompletionBlock)(BOOL state, NSDictionary *resultInfo, NSString *isCallBack);
typedef void(^EYShareBeginBlock)(BOOL state);
typedef void(^EYShareSelectClientBlock)(NSString *selectClient);
typedef void(^EYShareCancelBlock)(void);

@protocol EYShareManagerDelegate;
@interface EYShareManager : NSObject
@property (weak,nonatomic) id<EYShareManagerDelegate> delegate;
@property (nonatomic,copy) NSString *defaultShareUrl;
@property (nonatomic,copy) NSString *defaultShareTitle;
@property (nonatomic,copy) NSString *defaultShareMessage;

+ (EYShareManager *)sharedEYShareManager;

//分享面板是否在显示中
- (BOOL)isShowing;
//取消分享
- (void)cancel;
//隐藏未安装应用
- (void)disableUnInstallApp;

/**
 自定义分享平台定制的显示，可自定义排序

 @param target self
 @param channelArr 分享渠道展示数组
 @param model 分享model
 @param beginBlock 展示分享面板调用block
 @param selectClientBlock 选取分享渠道调用block
 @param cancelBlock 取消分享调用block
 @param completion 完成分享调用block，参数中包含成功和失败等信息
 */
-(void)shareWithTarget:(id)target
               channel:(NSArray *)channelArr
            shareModel:(EYShareInfoModel *)model
                 begin:(EYShareBeginBlock)beginBlock
          selectClient:(EYShareSelectClientBlock)selectClientBlock
                cancel:(EYShareCancelBlock)cancelBlock
            completion:(EYShareCompletionBlock)completion;

@end

@protocol EYShareManagerDelegate <NSObject>

/**
 * 唤起分享面板代理，用于自定义埋点
 
 @param model 分享数据
 */
- (void)shareBeginWithShareModel:(EYShareInfoModel*)model;

/**
 * 点击渠道代理，用于自定义埋点
 
 @param client 分享渠道 see EYShareManagerUtil
 @param model  分享数据 用于自定义埋点
 */
- (void)shareToClient:(NSString *)client shareModel:(EYShareInfoModel*)model;

/**
 * 取消操作，用于自定义埋点
 
 @param model 分享数据 用于自定义埋点
 */
- (void)shareCancelWithShareModel:(EYShareInfoModel *)model;

/**
 *  回调参数
 *
 *  @state               bool               是否成功
 *  @resultInfo          NSDictionary       回调结果，方便给js回调参数
 *      @"shareResult"   NSString           分享结果 0:成功 1:失败 2:取消
 *      @"shareChannel"  NSString           分享渠道 see ShareManagerUtil
 *  @param model 分享数据 用于自定义埋点
 */
- (void)shareFinishedWithState:(BOOL)state resultInfo:(NSDictionary *)resultInfo shareModel:(EYShareInfoModel *)model;

@end
