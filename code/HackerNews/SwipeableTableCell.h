//
//  SwipeableTableCell.h
//  HackerNews
//
//  Created by Karan Singh on 9/28/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@interface SwipeableTableCell : SWTableViewCell

@property (weak, nonatomic) UILabel *textView;
@property (weak, nonatomic) UILabel *itemScoreAndUpdatedByLabel;
@property (weak, nonatomic) UILabel *commentCountLabel;


@end
