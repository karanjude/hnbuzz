//
//  MasterViewController.h
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMSlideOutNavigationController.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController 

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *baseurl;
@property (strong, nonatomic) AMSlideOutNavigationController*	slideoutController;
@property (assign, nonatomic) NSInteger startIndex;
@property (strong, nonatomic) NSString* startIndexPrefix;

@property (assign, nonatomic) BOOL threadedView;

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;


@end

