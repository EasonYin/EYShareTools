//
//  EYViewController.m
//  EYShareTools
//
//  Created by huadong2593@163.com on 12/13/2018.
//  Copyright (c) 2018 huadong2593@163.com. All rights reserved.
//

#import "EYViewController.h"
#import <EYShareTools/EYShareTools-umbrella.h>

@interface EYViewController ()
{
    __weak IBOutlet UIButton *_weChatFriends;
    __weak IBOutlet UIButton *_weChatMoments;
    __weak IBOutlet UIButton *_qqFriends;
    __weak IBOutlet UIButton *_qqSpace;
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
    _weChatFriends.selected?[shareChannel addObject:Share_Wxfriends]:@"";
    _weChatMoments.selected?[shareChannel addObject:Share_Wxmoments]:@"";
    _qqFriends.selected?[shareChannel addObject:Share_QQfriends]:@"";
    _qqSpace.selected?[shareChannel addObject:Share_QQZone]:@"";
    _sinaWeibo.selected?[shareChannel addObject:Share_Sinaweibo]:@"";
    
    [[EYShareManager sharedEYShareManager]shareWithTarget:self channel:shareChannel shareModel:shareModel begin:^(BOOL state) {
        NSLog(@"share begin");
    } selectClient:^(NSString *selectClient) {
        NSLog(@"share to :%@",selectClient);
    } cancel:^{
        NSLog(@"share cancel");
    } completion:^(BOOL state, NSDictionary *resultInfo, NSString *isCallBack) {
        
        NSLog(@"shareChannel:%@",resultInfo[@"shareChannel"]);
        
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

@end
