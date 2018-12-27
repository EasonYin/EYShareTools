//
//  EYShareManagerUtil.m
//  EYShareTools
//
//

#import "EYShareManagerUtil.h"
#import "EYShareToolsConfigure.h"

NSString *const Share_Wxfriends = @"Wxfriends";
NSString *const Share_Wxmoments = @"Wxmoments";
NSString *const Share_Sinaweibo = @"Sinaweibo";
NSString *const Share_QQfriends = @"QQfriends";
NSString *const Share_QQZone    = @"QQzone";
NSString *const Share_CopyURL   = @"CopyURL";

@implementation EYShareManagerUtil

+ (BOOL)validateUIImageWithData:(NSData *)data
{
    UIImage *adImage = [UIImage imageWithData:data];
    if (adImage)
    {
        return YES;
    }
    return NO;
}

+ (NSString *)subString:(NSString *)string length:(NSInteger)length
{
    NSInteger strLength = [string length];
    if (strLength > length)
    {
        return [string substringToIndex:length];
    }
    return string;
}

+ (NSString *)reBuildShareURL:(NSString *)url resourceValue:(NSString *)resourceValue
{
    NSString *urlStr = url;
    if(![url hasPrefix:@"http"] || !url)
        return nil;
    
    if (![urlStr rangeOfString:@"?"].length)
    {
        urlStr = [urlStr stringByAppendingString:@"?"];
        if (![urlStr rangeOfString:@"resourceValue"].length)
        {
            urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"resourceValue=%@",resourceValue]];
        }
    }
    if (![urlStr rangeOfString:@"resourceValue"].length)
    {
        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&resourceValue=%@",resourceValue]];
    }
    if (![urlStr rangeOfString:@"ad_od"].length)
    {
        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&ad_od=0"]];
    }
    
    return urlStr;
    
    //    if (![urlStr rangeOfString:@"resourceType"].length)
    //    {
    //        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&resourceType=%@",resourceType]];
    //    }
    //    if (![urlStr rangeOfString:@"utm_source"].length)
    //    {
    //        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&utm_source=%@",utm_source]];
    //    }
    //    if (![urlStr rangeOfString:@"utm_medium"].length)
    //    {
    //        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&utm_medium=%@",utm_medium]];
    //    }
    //    if (![urlStr rangeOfString:@"utm_campaign"].length)
    //    {
    //        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&utm_campaign=%@",utm_campaign]];
    //    }
    //    if (![urlStr rangeOfString:@"utm_term"].length)
    //    {
    //        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&utm_term=%@",resourceValue]];
    //    }
    //
    //    return urlStr;
}

+ (NSData *)loadingImageUrl:(NSString * _Nullable)shareImageUrl imageData:(NSData* _Nullable)shareImageData length:(NSInteger)length
{
    
    NSData *imageData = nil;
    UIImage *defaultImage = [UIImage imageNamed:kEYShareDefaultImage];//默认分享图片
    
    if ([EYShareManagerUtil validateUIImageWithData:shareImageData]){
        imageData = shareImageData;
    }else if ([EYShareManagerUtil validateString:shareImageUrl]){
        if (![EYShareManagerUtil validateURL:shareImageUrl]) {
            shareImageUrl = [@"https:" stringByAppendingString:shareImageUrl];
        }
        NSURL *url = [NSURL URLWithString:shareImageUrl];
        NSURLRequest *request=[NSURLRequest requestWithURL:url
                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                           timeoutInterval:5];
        
        NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if ([EYShareManagerUtil validateUIImageWithData:data])
        {
            imageData = data;
        }
    }
    
    if (!imageData)
    {
        imageData = UIImagePNGRepresentation(defaultImage);
    }
    
    //图片压缩
    if ([imageData length] > length) {
        imageData = [EYShareManagerUtil compressImageData:imageData toByte:length];
    }
    
    return imageData;
}

+ (NSData *)compressImageData:(NSData *)data toByte:(NSUInteger)maxLength{
    
    if (data.length < maxLength) return data;
    
    UIImage *image = [UIImage imageWithData:data];
    CGFloat compression = 1;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    if (data.length < maxLength) return data;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(image.size.width * sqrtf(ratio)),
                                 (NSUInteger)(image.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(image, compression);
    }
    
    return data;
}

+ (BOOL)validateURL:(NSString *)urlStr
{
//    NSString *urlRegex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&#=]*)?";
    NSString *urlRegex = @"^(((ht|f)tps?)|file):.*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:urlStr];
}

+ (BOOL)validateString:(NSString *)str{
    if ([str isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

@end
