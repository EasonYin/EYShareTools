//
//  EYShareInfoModel.m
//  EYShareTools
//
//

#import "EYShareInfoModel.h"

@implementation EYShareInfoModel

- (id)copyWithZone:(NSZone *)zone
{
    EYShareInfoModel *model = [[[self class] allocWithZone:zone] init];
    
    model.title                 = self.title;
    model.shareUrl              = self.shareUrl;
    model.iconUrl               = self.iconUrl;
    model.iconData              = self.iconData;
    model.channel               = self.channel;
    model.content               = self.content;
    model.WeiBoContent          = self.WeiBoContent;
    model.WeiXinFriendsContent  = self.WeiXinFriendsContent;
    model.WeiXinContent         = self.WeiXinContent;
    model.isCallBack            = self.isCallBack;
    model.mpId                  = self.mpId;
    model.mpPath                = self.mpPath;
    model.mpIconUrl             = self.mpIconUrl;
    
    return model;
}

@end
