//
//  HackerNewsDelegate.h
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HackerNewsDelegate

- (void) receivedJSON: (NSData* ) object;
- (void) fetchingJSONFailedWithError: (NSError* ) error;

@end
