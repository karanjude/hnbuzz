//
//  HackerNewsComment.m
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerNewsComment.h"

@implementation HackerNewsComment


- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    
    HackerNewsComment* o = (HackerNewsComment*)other;
    return [self.itemID isEqual:o.itemID];
}

@end