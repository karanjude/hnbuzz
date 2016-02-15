//
//  LoginViewController.h
//  HackerNews
//
//  Created by Karan Singh on 11/1/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMSlideOutNavigationController.h>


@interface LoginViewController : UIViewController

@property (strong, nonatomic) AMSlideOutNavigationController*	slideoutController;
@property (strong, nonatomic) UIViewController*	controller;

- (void)loginButtonClicked ;

@end
