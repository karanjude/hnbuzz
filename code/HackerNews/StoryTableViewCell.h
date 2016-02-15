//
//  StoryTableViewCell.h
//  HackerNews
//
//  Created by Karan Singh on 10/29/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *byLabel;


@end
