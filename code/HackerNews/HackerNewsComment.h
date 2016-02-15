//
//  HackerNewsComment.h
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HackerNewsComment : NSObject

@property (strong, nonatomic) NSString* itemID;
@property (strong, nonatomic) NSString* parentId;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSMutableArray* children;
@property (strong, nonatomic) NSDate* updateTime;
@property (strong, nonatomic) NSString* totalChildren;
@property (assign, nonatomic) NSInteger level;

@property (strong, nonatomic) NSString* score;
@property (strong, nonatomic) NSString* updatedBy;
@property (strong, nonatomic) NSString* url;

@property (assign, nonatomic) BOOL commentExpanded;
@property (assign, nonatomic) BOOL alreadyRead;

@property (assign, nonatomic) BOOL following;
@property (assign, nonatomic) BOOL voted;
@property (assign, nonatomic) BOOL replied;
@property (assign, nonatomic) BOOL deleted;

@property (strong, nonatomic) NSString* type;



@end