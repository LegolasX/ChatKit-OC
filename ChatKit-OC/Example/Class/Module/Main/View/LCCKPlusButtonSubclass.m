//
//  LCCKPlusButtonSubclass.m
//  DWCustomTabBarDemo
//
//  Created by 微博@iOS程序犭袁 (http://weibo.com/luohanchenyilong/) on 15/10/24.
//  Copyright (c) 2015年 https://github.com/ChenYilong . All rights reserved.
//

#import "LCCKPlusButtonSubclass.h"
#import "LCChatKitExample.h"
#import <AipOcrSdk/AipOcrSdk.h>
@interface LCCKPlusButtonSubclass () {
    CGFloat _buttonImageHeight;
}
@end
@implementation LCCKPlusButtonSubclass
// 默认的识别成功的回调
void (^_successHandler)(id);
// 默认的识别失败的回调
void (^_failHandler)(NSError *);
#pragma mark -
#pragma mark - Life Cycle

+ (void)load {
    [super registerPlusButton];
}

#pragma mark -
#pragma mark - Life Cycle

-(instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
//        self.titleLabel.textAlignment = NSTextAlignmentCenter;
//        self.adjustsImageWhenHighlighted = NO;
    }
    
    return self;
}

#pragma mark -
#pragma mark - Public Methods

/*
 *
 Create a custom UIButton without title and add it to the center of our tab bar
 *
 */
+ (instancetype)plusButton {

    UIImage *buttonImage = [UIImage imageNamed:@"tabbar_compose_button"];
    UIImage *highlightImage = [UIImage imageNamed:@"tabbar_compose_button_highlighted"];
    UIImage *iconImage = [UIImage imageNamed:@"tabbar_compose_icon_add"];
    UIImage *highlightIconImage = [UIImage imageNamed:@"tabbar_compose_icon_add"];

    LCCKPlusButtonSubclass *button = [LCCKPlusButtonSubclass buttonWithType:UIButtonTypeCustom];
    
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setImage:iconImage forState:UIControlStateNormal];
    [button setImage:highlightIconImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark -
#pragma mark - Event Response

- (void)clickPublish {
    //如果提示群已满，可以换一个id
    //普通群人数上限是500，暂态聊天室无人数限制
//    [LCChatKitExample exampleOpenConversationViewControllerWithConversaionId:@"sadfasdfasdfasdfbf892" fromNavigationController:nil];
    [LCChatKitExample createGroupFromOCR];
    [self configCallback];
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextBasicFromImage:image
                                                   withOptions:options
                                                successHandler:_successHandler
                                                   failHandler:_failHandler];
    }];
    [self.window.rootViewController presentViewController:vc animated:true completion:nil];
}

+ (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
    return 2;
}

//+ (NSUInteger)indexOfPlusButtonInTabBar {
//    return 1;
//}
- (void)configCallback {
    __weak typeof(self) weakSelf = self;
    
    // 这是默认的识别成功的回调
    _successHandler = ^(id result){
        NSLog(@"%@", result);
        NSString *title = @"识别结果";
        NSMutableString *message = [NSMutableString string];
        
        if(result[@"words_result"]){
            if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
                [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@: %@\n", key, obj];
                    }
                    
                }];
            }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
                for(NSDictionary *obj in result[@"words_result"]){
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@\n", obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@\n", obj];
                    }
                    
                }
            }
            
        }else{
            [message appendFormat:@"%@", result];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }];
    };
    
    _failHandler = ^(NSError *error){
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"识别失败" message:msg delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }];
    };
}




@end
