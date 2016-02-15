//
//  WebViewController.h
//  HackerNews
//
//  Created by Karan Singh on 9/26/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HackerNewsComment.h"

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) UIStoryboard* board;


@property (strong, nonatomic) HackerNewsComment* story;


@end
