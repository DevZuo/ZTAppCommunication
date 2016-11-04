//
//  TableViewController.m
//  Demo
//
//  Created by zuoteng on 2016/11/3.
//  Copyright © 2016年 zuoteng. All rights reserved.
//

#import "TableViewController.h"

#import "AppCommunication.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Private

- (void)shareWithRow:(NSInteger)row {
    
    AppMessage *message = [[AppMessage alloc] init];
    
    switch (row) {
        case 0: // 文字
        {
            message.messageType = AppMessageTypeText;
            message.title = @"中华文化，亦称华夏文化、汉文化，是指以春秋战国诸子百家为基础不断演化、发展而成的中国特有文化。其特征是以中华文化的诸子百家文化尤其是儒家文化与天朝思想为其骨干而发展。";
        }
            break;
        case 1: // 图片
        {
            message.messageType = AppMessageTypeImage;
            message.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"rabbit"]);
            message.imgData = UIImagePNGRepresentation([UIImage imageNamed:@"rabbit"]);
        }
            break;
        case 2: // URL
        {
            message.messageType = AppMessageTypeURL;
            message.title = @"中华文化";
            message.content = @"中华文化，亦称华夏文化、汉文化，是指以春秋战国诸子百家为基础不断演化、发展而成的中国特有文化。其特征是以中华文化的诸子百家文化尤其是儒家文化与天朝思想为其骨干而发展。";
            message.url = [NSURL URLWithString:@"https://www.baidu.com"];
            message.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"logo"]);
        }
            break;
        case 3: // 音频
        {
            message.messageType = AppMessageTypeAudio;
            message.title = @"中华文化";
            message.content = @"中华文化，亦称华夏文化、汉文化，是指以春秋战国诸子百家为基础不断演化、发展而成的中国特有文化。其特征是以中华文化的诸子百家文化尤其是儒家文化与天朝思想为其骨干而发展。";
            message.url = [NSURL URLWithString:@"https://www.baidu.com"];
            message.audioURL = [NSURL URLWithString:@"http://stream20.qqmusic.qq.com/32464723.mp3"];
            message.url = [NSURL URLWithString:@"https://www.baidu.com"];
            message.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"logo"]);
        }
            break;
        case 4: // 视频
        {
            message.messageType = AppMessageTypeVideo;
            message.title = @"中华文化";
            message.content = @"中华文化，亦称华夏文化、汉文化，是指以春秋战国诸子百家为基础不断演化、发展而成的中国特有文化。其特征是以中华文化的诸子百家文化尤其是儒家文化与天朝思想为其骨干而发展。";
            message.videoURL = [NSURL URLWithString:@"http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html"];
            message.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"logo"]);
        }
            break;
        case 5: // 文件
        {
            
        }
            break;
            
        default:
            break;
    }
    
    [AppCommunication shareMessage:message forShareMessageType:ShareMessageTypeWeChatFriend completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"分享成功");
        } else {
            NSLog(@"分享失败");
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger const section = indexPath.section;
    NSInteger const row = indexPath.row;
    
    switch (section) {
        case 0: // 授权登录
        {
            
        }
            break;
        case 1: // 分享
        {
            [self shareWithRow:row];
        }
            break;
        case 2: // 支付
        {
            
        }
            break;
            
        default:
            break;
    }
}

@end
