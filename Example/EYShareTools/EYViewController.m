//
//  EYViewController.m
//  EYShareTools
//
//  Created by huadong2593@163.com on 12/13/2018.
//  Copyright (c) 2018 huadong2593@163.com. All rights reserved.
//

#import "EYViewController.h"
#import <EYShareTools/EYShareTools-umbrella.h>

@interface EYViewController ()<EYShareManagerDelegate>
{
    __weak IBOutlet UIButton *_weChatFriends;
    __weak IBOutlet UIButton *_weChatMoments;
    __weak IBOutlet UIButton *_qqFriends;
    __weak IBOutlet UIButton *_qqZone;
    __weak IBOutlet UIButton *_sinaWeibo;
    
}
@property (weak, nonatomic) IBOutlet UITextField *defaultTitle;
@property (weak, nonatomic) IBOutlet UITextField *defaultContent;
@property (weak, nonatomic) IBOutlet UITextField *defaultImage;


@end

@implementation EYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"分享测试";
    
}

- (IBAction)doCheck:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
}


- (IBAction)doShare:(id)sender {
    
    NSDictionary *shareDic = @{
                               @"title":self.defaultTitle.text,
                               @"shareUrl":self.defaultImage.text,
                               @"iconUrl":self.defaultImage.text,
                               @"content":self.defaultContent.text,
                               @"isCallBack":@"Y",
                               };
    EYShareInfoModel *shareModel = [EYShareInfoModel yy_modelWithDictionary:shareDic];
    
    NSMutableArray *shareChannel = [NSMutableArray array];
    _weChatFriends.selected?[shareChannel addObject:Share_Wxfriends]:nil;
    _weChatMoments.selected?[shareChannel addObject:Share_Wxmoments]:nil;
    _qqFriends.selected?[shareChannel addObject:Share_QQfriends]:nil;
    _qqZone.selected?[shareChannel addObject:Share_QQZone]:nil;
    _sinaWeibo.selected?[shareChannel addObject:Share_Sinaweibo]:nil;
    
    [[EYShareManager sharedEYShareManager]shareWithTarget:self channel:shareChannel shareModel:shareModel begin:^(BOOL state) {
        NSLog(@"block share begin");
    } selectClient:^(NSString *selectClient) {
        NSLog(@"block share to:%@",selectClient);
    } cancel:^{
        NSLog(@"block share cancel");
    } completion:^(BOOL state, NSDictionary *resultInfo, NSString *isCallBack) {
        
        NSLog(@"block shareChannel:%@",resultInfo[@"shareChannel"]);
        
        if ([resultInfo[@"shareResult"] intValue] == 0){
            NSLog(@"成功");
        }else if ([resultInfo[@"shareResult"] intValue] == 1){
            NSLog(@"失败");
        }else if ([resultInfo[@"shareResult"] intValue] == 2){
            NSLog(@"取消");
        }
        
        NSLog(@"isCallBack:%@",isCallBack);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EYShareManagerDelegate
#warning 按需选择代理和block方式回调
- (void)shareBeginWithShareModel:(EYShareInfoModel *)model {
    NSLog(@"delegate share begin");

}

- (void)shareCancelWithShareModel:(EYShareInfoModel *)model {
    NSLog(@"delegate share cancel");

}

- (void)shareFinishedWithState:(BOOL)state resultInfo:(NSDictionary *)resultInfo shareModel:(EYShareInfoModel *)model {
    NSLog(@"delegate shareChannel:%@",resultInfo[@"shareChannel"]);
    
    if ([resultInfo[@"shareResult"] intValue] == 0){
        NSLog(@"成功");
    }else if ([resultInfo[@"shareResult"] intValue] == 1){
        NSLog(@"失败");
    }else if ([resultInfo[@"shareResult"] intValue] == 2){
        NSLog(@"取消");
    }
    
    NSLog(@"isCallBack:%@",model.isCallBack);
}

- (void)shareToClient:(NSString *)client shareModel:(EYShareInfoModel *)model {
    NSLog(@"delegate share to:%@",client);

}


@end
