//
//  EYShareShakeView.h
//  EYShareTools
//
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "UIView+Layout.h"

@protocol EYShareShakeDelegate <NSObject>

@required

-(void)shareToClient:(id)sender;
-(void)shareCancel:(UIView*)view;

@end

NS_ASSUME_NONNULL_BEGIN

@interface EYShareShakeView : UIView
@property (weak, nonatomic) id<EYShareShakeDelegate> delegate;

//通过传入进来的数组重新绘制UI
- (void)setUpUIWithChannelArray:(NSArray*)channelArr showUninstallApp:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
