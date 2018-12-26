//
//  EYShareManagerUtil.h
//  EYShareTools
//
//

#import <Foundation/Foundation.h>

//shareChannel
extern NSString *const Share_Wxfriends;
extern NSString *const Share_Wxmoments;
extern NSString *const Share_Sinaweibo;
extern NSString *const Share_QQfriends;
extern NSString *const Share_QQZone;
extern NSString *const Share_CopyURL;
extern NSString *const Share_QRCode;

NS_ASSUME_NONNULL_BEGIN

@interface EYShareManagerUtil : NSObject

/**
 *  验证data是否是合法的UIImage类型
 *
 *  @param data imagedata
 *
 *  @return data
 */
+ (BOOL)validateUIImageWithData:(NSData *)data;

/**
 *  截图分享字段
 *
 *  @param string 分享文案
 *  @param length length
 *
 *  @return subString
 */
+ (NSString *)subString:(NSString *)string length:(NSInteger)length;

/**
 *  分享URL引入来源统计参数
 *
 *  @param url           URL
 *  @param resourceValue resourceType   jdapp_share
 *
 *  @return URL
 */
+ (NSString *)reBuildShareURL:(NSString *)url resourceValue:(NSString *)resourceValue;

/*
 * 加载分享图片
 */
+ (NSData *)loadingImageUrl:(NSString * _Nullable)shareImageUrl imageData:(NSData* _Nullable)shareImageData length:(NSInteger)length;


/**
 * 压缩图片
 
 @param data 图片data
 @param maxLength 压缩大小
 @return 图片
 */
+ (NSData *)compressImageData:(NSData *)data toByte:(NSUInteger)maxLength;

+ (BOOL)validateString:(NSString *)str;
+ (UIColor*)colorWithHex:(NSString *)hex;

@end

NS_ASSUME_NONNULL_END
