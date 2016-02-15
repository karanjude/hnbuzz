//
//  SwipeableTableCell.m
//  HackerNews
//
//  Created by Karan Singh on 9/28/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import "SwipeableTableCell.h"

@implementation SwipeableTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 10;
    //frame.size.width -= 2 * 10;
    [super setFrame:frame];
}

@end
