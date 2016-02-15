//
//  CommentBuilder.h
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerNewsComment.h"

@interface CommentBuilder : NSObject

+ (NSArray*) commentsFromJSON: (NSData *) json error: (NSError ** ) error;
+ (NSArray *)commentsForStoryIdByScraping:(NSString *)storyId error:(NSError **)error level:(NSInteger)level
                                  pcomment:(HackerNewsComment*)pcomment;
+ (NSArray*) itemsFromJSON: (NSData *) json error: (NSError ** ) error withStartIndex: (NSUInteger) startIndex;


+ (HackerNewsComment*) getCommentsForCommentID:(NSString *)commentID level:(NSInteger)level;
+ (NSArray *)commentsFromJSON:(NSData *)json havingParentComment: (HackerNewsComment* ) comment error:(NSError **)error;

+ (void) commentsForParent:(HackerNewsComment*)parentComment;


+ (HackerNewsComment*) getItemForItemID:(NSString *)itemID;
@end
