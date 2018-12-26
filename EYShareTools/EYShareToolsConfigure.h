//
//  EYShareToolsConfigure.h
//  EYShareTools
//
//

#ifndef EYShareToolsConfigure_h
#define EYShareToolsConfigure_h

#define kEYShareDefaultTitle              @"分享默认标题";
#define kEYShareDefaultMesasage           @"分享默认内容"
#define kEYShareDefaultShareUrl           @"https://github.com/EasonYin/EYShareTools"
#define kEYShareDefaultImage              @"share_default_icon"

#define kEYWXShareMaxImageBytes           (32 * 1024)
#define kEYWXMiniShareMaxImageBytes       (128 * 1024)
#define kEYWBShareMaxImageBytes           (10 * 1024 * 1024)
#define kEYQQShareMaxImageBytes           (1024 * 1024)

#define kEYSCREEN_WIDTH                   CGRectGetWidth([[UIScreen mainScreen] bounds])
#define kEYSCREEN_HEIGHT                  CGRectGetHeight([[UIScreen mainScreen] bounds])
#define kEYIphone6Scale(x)                ((x)*kEYSCREEN_WIDTH/375.0f) //以iphone6设计稿来计算适配其他屏幕的高度
#define kEYSafeAreaBottom                 (([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896 ) ? 34.0f:0)

#define kEYXGap                           kEYIphone6Scale(40.0)
#define kEYYGap                           kEYIphone6Scale(20.0)
#define kEYShareButtonFontSize            kEYIphone6Scale(14.0)
#define kEYCancelButtonFontSize           kEYIphone6Scale(16.0)
#define kEYShareButtonWidth               kEYIphone6Scale(50.0)
#define kEYCancelButtonHeight             kEYIphone6Scale(50.0)
#define kEYShareButtonImageTopSpace       kEYIphone6Scale(20.0)
#define kEYShareButtonImageSecondTopSpace kEYIphone6Scale(120.0)

#define SWITCH(s)                         for (NSString *__s__ = (s); ; )
#define CASE(str)                         if ([__s__ isEqualToString:(str)])
#define DEFAULT

#endif /* EYShareToolsConfigure_h */
