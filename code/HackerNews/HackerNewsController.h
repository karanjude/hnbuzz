//
//  HackerNewsController.h
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerNewsDelegate.h"
#import "HackerNewsComment.h"

extern NSString * const TOP_STORIES_URL;
extern NSString * const NEW_STORIES_URL;
extern NSString * const ASK_STORIES_URL;
extern NSString * const SHOW_STORIES_URL;
extern NSString * const JOB_STORIES_URL;
extern NSString * const MY_THREADS_URL;

extern NSString * const TOP_STORIES_URL_1;
extern NSString * const TOP_STORIES_URL_1_PREFIX;
extern NSString * const TOP_STORIES_URL_2;


extern NSString * const NEW_STORIES_URL_1;
extern NSString * const NEW_STORIES_URL_1_PREFIX ;
extern NSString * const NEW_STORIES_URL_2;


extern NSString * const ASK_STORIES_URL_1;
extern NSString * const ASK_STORIES_URL_1_PREFIX ;
extern NSString * const ASK_STORIES_URL_2;


extern NSString * const SHOW_STORIES_URL_1 ;
extern NSString * const SHOW_STORIES_URL_1_PREFIX ;
extern NSString * const SHOW_STORIES_URL_2 ;


extern NSString * const JOB_STORIES_URL_1 ;
extern NSString * const JOB_STORIES_URL_1_PREFIX ;
extern NSString * const JOB_STORIES_URL_2 ;


extern NSString * const MY_THREADS_URL_1 ;
extern NSString * const MY_THREADS_URL_1_PREFIX ;
extern NSString * const MY_THREADS_URL_2 ;

extern NSString * const ITEM_URL_2 ;



@interface HackerNewsController : NSObject


@property (weak, nonatomic) id<HackerNewsDelegate> delegate;

@property (strong, atomic) NSString* baseurl;

- (void) getCommentsForStoryID:(NSString*) storyID;
- (void) getCommentsForStoryIDByScraping:(NSString*) storyID;

- (void) getTopStories;
- (void) getTopStoriesByScraping;
- (NSArray*) getTopStoriesByScrapingHN: (NSError ** ) error withStartIndex: (NSString**) startIndexPrefix basePrefix:(NSString*) basePrefix;

- (void) getCommentsForParentCommentID:(HackerNewsComment*)parentComment;

-(NSString*) getUpvoteUrlForItemId:(NSString*)itemID withUserCookie:(NSString*) userCookie;
-(NSError*) upvoteUrl:(NSString*)itemUrl withUserCookie:(NSString*) userCookie;
-(BOOL) upvote:(HackerNewsComment*) item;
- (HackerNewsComment*) getStoryForComment: (HackerNewsComment*) item;

-(NSString *) getCommentUrlForCommentId:(NSString*) commentID withStory:(HackerNewsComment*) story;
-(NSString *) getCommentUrlForStory:(NSString*) storyID;

+ (NSArray*) checkForNewStories;

@end
