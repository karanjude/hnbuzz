//
//  WebViewController.m
//  HackerNews
//
//  Created by Karan Singh on 9/26/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import "WebViewController.h"
#import <MMMaterialDesignSpinner.h>
#import "UIColor+FlatUI.h"
#import "RootViewController.h"
#import "HackerNewsDBHelper.h"
#import "HackerNewsController.h"



@interface WebViewController () <UIWebViewDelegate>{
    HackerNewsController* _hackerNewsController;

}



@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;
@property (strong, nonatomic) UIBarButtonItem *upvoteButton;
@property (strong, nonatomic) UIBarButtonItem *replyButton;
@property (strong, nonatomic) UIBarButtonItem *followButton;
@property (strong, nonatomic) UIBarButtonItem *flexibleSpace;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _hackerNewsController = [[HackerNewsController alloc] init];
    _hackerNewsController.delegate = self;
        
    NSString *urlString = self.url;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareAction:)];
    shareButton.tintColor = [UIColor whiteColor];
    
    
    NSArray *actionButtonItems = @[shareButton];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    self.navigationController.toolbarHidden = NO;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.upvoteButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"upvoteNav.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(upvote:)];
    
    UIButton *barBt =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 44)];
    [barBt setImage:[UIImage imageNamed:@"ResponseNav.png"] forState:UIControlStateNormal];
    
    NSString * childCount = self.story.totalChildren;
    if(childCount == nil || [childCount isEqualToString:@"(null)"]){
        childCount = @"0";
    }
    
    [barBt setTitle:[NSString stringWithFormat:@" %ld", (long)[childCount integerValue]] forState:UIControlStateNormal];
    
    [barBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [barBt addTarget:self action: @selector(comments:) forControlEvents:UIControlEventTouchUpInside];
    self.replyButton =  [[UIBarButtonItem alloc]init];
    [self.replyButton setCustomView:barBt];
    
    //UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ResponseNav.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:nil];
    
    self.followButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"followNav.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(followStory:)];
    
     self.flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIBarButtonItem *flexibleSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSMutableArray *buttonItems = [[NSMutableArray alloc] init];
    
    if([HackerNewsDBHelper LoggedIn] && !self.story.voted){
        [buttonItems addObject:self.upvoteButton];
    }
    
    [buttonItems addObject:self.flexibleSpace];
    [buttonItems addObject:self.replyButton];

    if(!self.story.following){
        [buttonItems addObject:self.followButton];
    }
    
    
    [self setToolbarItems:buttonItems];
    
    
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.spinnerView.lineWidth = 3.0f;
    self.spinnerView.tintColor = [UIColor pumpkinColor];
    self.spinnerView.center = self.view.center;
    
    [self.view addSubview:self.spinnerView];
    
    self.webView.delegate = self;
    
    [self.spinnerView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [self.webView loadRequest:urlRequest];

        dispatch_async(dispatch_get_main_queue(), ^{
            

        });
    });


    //[self.webView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString* pageReady = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    if ([pageReady isEqualToString:@"complete"] || [pageReady isEqualToString:@"interactive"]) {
        [self.spinnerView stopAnimating];
        self.spinnerView.hidden = YES;
    }
}

- (void)comments:(id)sender {
 
    RootViewController *view = [[RootViewController alloc] init];
    view.storyID = self.story.itemID;
    view.board = self.storyboard;
    view.story = self.story;
    
    [self.navigationController pushViewController:view animated:YES];

}

- (void)upvote:(id)sender {

    [_hackerNewsController upvote:self.story];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNews" object:nil];
    
    NSArray *buttonItems;
    
    if(!self.story.following){
        buttonItems = @[self.flexibleSpace, self.replyButton,   self.followButton];
    }else{
        buttonItems = @[self.flexibleSpace, self.replyButton];
    }
    
    [self setToolbarItems:buttonItems];
    [self.view setNeedsDisplay];
    
}

-(void)followStory:(UIBarButtonItem*) sender{
    NSLog(@"About to follow with id:%@ and text:%@", self.story.itemID, self.story.text);
    
    self.story.type = @"story";
    self.story.following = TRUE;
    
    BOOL exists = [HackerNewsDBHelper exists:self.story];
    if(!exists){
        [HackerNewsDBHelper insert:self.story];
    }else{
        [HackerNewsDBHelper update:self.story];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFollowing" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNews" object:nil];
    
    NSArray *buttonItems;
    buttonItems = @[self.upvoteButton, self.flexibleSpace, self.replyButton];
    
    [self setToolbarItems:buttonItems];
    [self.view setNeedsDisplay];
}


- (void)shareAction:(id)sender {
    NSString *textToShare = @"My HN Save";
    
    if(self.url == nil){
        self.url = self.story.url;
    }
    
    NSURL *myWebsite = [NSURL URLWithString:self.url];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
}


- (void)viewDidLayoutSubviews {
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
