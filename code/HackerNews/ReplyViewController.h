//
//  ReplyViewController.h
//  
//
//  Created by Karan Singh on 10/30/15.
//
//

#import <UIKit/UIKit.h>
#import "HackerNewsComment.h"

#import <AMSlideOutNavigationController.h>

@interface ReplyViewController : UIViewController
- (IBAction)cancelReply:(UIButton *)sender;

@property (assign, nonatomic ) BOOL isStory;
@property (strong, nonatomic ) HackerNewsComment* item;
@property (strong, nonatomic ) HackerNewsComment* story;

@property (strong, nonatomic) AMSlideOutNavigationController*	slideoutController;

@end
