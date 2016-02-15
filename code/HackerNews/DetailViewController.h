//
//  DetailViewController.h
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

