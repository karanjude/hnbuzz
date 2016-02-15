//
//  HackerNewsController.m
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerNewsController.h"
#import "CommentBuilder.h"
#import "TFHpple.h"
#import "HackerNewsDBHelper.h"

NSString * const TOP_STORIES_URL = @"https://hacker-news.firebaseio.com/v0/topstories.json";
NSString * const NEW_STORIES_URL = @"https://hacker-news.firebaseio.com/v0/newstories.json";
NSString * const ASK_STORIES_URL = @"https://hacker-news.firebaseio.com/v0/askstories.json";
NSString * const SHOW_STORIES_URL = @"https://hacker-news.firebaseio.com/v0/showstories.json";
NSString * const JOB_STORIES_URL = @"https://hacker-news.firebaseio.com/v0/jobstories.json";
NSString * const MY_THREADS_URL = @"https://hacker-news.firebaseio.com/v0/user/%@.json";

NSString * const TOP_STORIES_URL_1 = @"https://news.ycombinator.com/news?";
NSString * const TOP_STORIES_URL_1_PREFIX = @"news?";
NSString * const TOP_STORIES_URL_2 = @"https://news.ycombinator.com/news";


NSString * const NEW_STORIES_URL_1 = @"https://news.ycombinator.com/newest?";
NSString * const NEW_STORIES_URL_1_PREFIX = @"newest?";
NSString * const NEW_STORIES_URL_2 = @"https://news.ycombinator.com/newest";


NSString * const ASK_STORIES_URL_1 = @"https://news.ycombinator.com/ask?";
NSString * const ASK_STORIES_URL_1_PREFIX = @"ask?";
NSString * const ASK_STORIES_URL_2 = @"https://news.ycombinator.com/ask";


NSString * const SHOW_STORIES_URL_1 = @"https://news.ycombinator.com/show?";
NSString * const SHOW_STORIES_URL_1_PREFIX = @"show?";
NSString * const SHOW_STORIES_URL_2 = @"https://news.ycombinator.com/show";


NSString * const JOB_STORIES_URL_1 = @"https://news.ycombinator.com/jobs?";
NSString * const JOB_STORIES_URL_1_PREFIX = @"jobs?";
NSString * const JOB_STORIES_URL_2 = @"https://news.ycombinator.com/jobs";


NSString * const MY_THREADS_URL_1 = @"https://news.ycombinator.com/threads?id=";
NSString * const MY_THREADS_URL_1_PREFIX = @"threads?id=";
NSString * const MY_THREADS_URL_2 = @"https://news.ycombinator.com/threads";

NSString * const ITEM_URL_2 = @"https://news.ycombinator.com/item";



@implementation HackerNewsController

+ (NSArray*) checkForNewStories {
    
    NSString *urlAsString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/topstories.json"];
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    NSMutableArray* newItems = [[NSMutableArray alloc] init];
    
    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
    
    if(!error){
        NSArray* topItems = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSInteger c = 0;
        
        NSArray* trackingItems =  [HackerNewsDBHelper trackingItems];
        
        for (id itemId in topItems) {
            if(c >= 30){
                break;
            }
            c += 1;
            
            NSString* stringItemId = [NSString stringWithFormat:@"%@", itemId];
            
            if(![trackingItems containsObject:stringItemId]){
                [newItems addObject:itemId];
            }
        }
        
        if([newItems count] >= 5){
            //[HackerNewsDBHelper clearTrackingItems];
            [HackerNewsDBHelper trackNewItems:newItems];
        }
        
    }

    return newItems;
}

- (void) getTopStoriesByScraping {
    
    [self.delegate receivedJSON:nil];
}

- (NSArray*) getTopStoriesByScrapingHN: (NSError ** ) error withStartIndex: (NSString**) startIndexPrefix basePrefix:(NSString *)basePrefix {
    NSString *urlAsString = [NSString stringWithFormat:@"https://news.ycombinator.com/news?p=%@", *startIndexPrefix];
    
    if(self.baseurl != nil){
        urlAsString = [NSString stringWithFormat:@"https://news.ycombinator.com/%@", *startIndexPrefix];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:error];
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    NSArray * titles  = [doc searchWithXPathQuery:@"//td[@class='title']"];
    NSArray * subtexts  = [doc searchWithXPathQuery:@"//td[@class='subtext']"];
    NSArray * allLinks = [doc searchWithXPathQuery:@"//a"];
    
    for (TFHppleElement * link in allLinks) {
        if([ [link objectForKey:@"href"] hasPrefix:basePrefix]){
            *startIndexPrefix = [link objectForKey:@"href"];
            break;
        }
    }
    
    NSUInteger subTextCounter = 0;
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    
    
    for (NSUInteger i = 0; i < [titles count]; i++) {
        TFHppleElement * title = [titles objectAtIndex:i];
        NSArray * children = [title childrenWithTagName:@"a"];
        if([children count] == 1){
            
            if(subTextCounter >= 30){
                continue;
            }
            
            HackerNewsComment* item = [[HackerNewsComment alloc] init];
            item.type = @"story";
            
            TFHppleElement * urlChild = [children objectAtIndex:0];
            NSLog(@"Story Title: %@ URL: %@", [urlChild text],[urlChild objectForKey:@"href"]);
            item.text = [urlChild text];
            item.url = [urlChild objectForKey:@"href"];
            
            TFHppleElement * subtext = [subtexts objectAtIndex:subTextCounter];
            
            NSArray * scoreChildren = [subtext childrenWithClassName:@"score"];
            
            if([scoreChildren count] == 1){
                TFHppleElement* scoreChild = [scoreChildren objectAtIndex:0];
                NSLog(@"Story Score: %@", [scoreChild text]);
                item.score = [[[scoreChild text] componentsSeparatedByString:@" "] objectAtIndex:0];
            }
            
            NSArray * children = [subtext childrenWithTagName:@"a"];
            
            for (TFHppleElement *object in children) {
                NSLog(@"%@ %@", [object text], [object objectForKey:@"href"]);

                NSString * info = [object objectForKey:@"href"];
                if([info hasPrefix:@"user?id="]){
                    NSArray* parts = [info componentsSeparatedByString:@"="];
                    NSString* updatedby = [parts objectAtIndex:1];
                    item.updatedBy = updatedby;
                    
                }else if([info hasPrefix:@"item?id="]){
                    NSString* text = [object text];
                    
                    if(([text rangeOfString:@"comments"].location != NSNotFound) || ([text rangeOfString:@"comment"].location != NSNotFound)){
                        NSArray* parts = [info componentsSeparatedByString:@"="];
                        item.itemID = [parts objectAtIndex:1];

                        parts = [text componentsSeparatedByString:@" "];
                        item.totalChildren = [parts objectAtIndex:0];
                    }else if([text rangeOfString:@"discuss"].location != NSNotFound){
                        NSArray* parts = [info componentsSeparatedByString:@"="];
                        item.itemID = [parts objectAtIndex:1];
                        
                        item.totalChildren = @"0";

                    }
                    
                }
                
            }
            
            
            subTextCounter++;
            [result addObject:item];
        }
        

    }
    
    
    return result;
}

- (void) getTopStories {
    NSString *urlAsString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/topstories.json"];
    
    if(self.baseurl != nil){
        urlAsString = self.baseurl;
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
    
    if (error) {
        [self.delegate fetchingJSONFailedWithError:error];
    } else {
        [self.delegate receivedJSON:data];
    }
    
    
    /*
     [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
     
     if (error) {
     [self.delegate fetchingJSONFailedWithError:error];
     } else {
     [self.delegate receivedJSON:data];
     }
     }];*/
}

- (void) getCommentsForParentCommentID:(HackerNewsComment*)parentComment {
    NSString *urlAsString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@.json", parentComment.itemID];
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    NSError* error;
    NSURLResponse *response;
    NSData* json = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];

    NSArray* comments = [CommentBuilder commentsFromJSON:json error:&error];
    parentComment.children = comments;

}


-(NSString *) getCommentUrlForStory:(NSString*) storyID {
    NSString* c = nil;
    
    if ([HackerNewsDBHelper LoggedIn]) {
        c = [HackerNewsDBHelper userCookieString];
    }
    
    if (c == nil) {
        return c;
    }
    
    NSString* itemUrl = [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@", storyID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:itemUrl]];
    [request addValue:c forHTTPHeaderField:@"Cookie"];
    
    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    NSArray* inputs = [doc searchWithXPathQuery:@"//input"];
    
    NSString* parent = nil;
    NSString* gotoUrl = nil;
    NSString* hmac = nil;
    
    for (TFHppleElement* e in inputs) {
        NSString * elementID = [e objectForKey:@"type"];
        
        if(elementID == nil)
            continue;
        
        if([elementID isEqualToString:@"hidden"]){
            NSLog(@"%@ = %@", [e objectForKey:@"name"], [e objectForKey:@"value"]);
            
            if ([[e objectForKey:@"name"] isEqualToString:@"parent"]) {
                parent = [e objectForKey:@"value"];
            }else if ([[e objectForKey:@"name"] isEqualToString:@"goto"]) {
                gotoUrl = [e objectForKey:@"value"];
            }else if ([[e objectForKey:@"name"] isEqualToString:@"hmac"]) {
                hmac = [e objectForKey:@"value"];
            }
            
            
        }
    }
    
    if (gotoUrl == nil) {
        gotoUrl = [NSString stringWithFormat:@"item?id=%@", storyID];
        

    }
    
    gotoUrl = [gotoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
;
    
    if(parent != nil && gotoUrl != nil && hmac != nil){
        NSString *post = [NSString stringWithFormat:@"action=comment&parent=%@&goto=%@&hmac=%@&",parent, gotoUrl, hmac];

        return post;
    }
    
    return nil;
}


-(NSString *) getCommentUrlForCommentId:(NSString*) commentID withStory:(HackerNewsComment*) story {
    NSString* c = nil;
    
    if ([HackerNewsDBHelper LoggedIn]) {
        c = [HackerNewsDBHelper userCookieString];
    }
    
    if (c == nil) {
        return c;
    }
    
    NSString* gotoUrl = [NSString stringWithFormat:@"item?id=%@", story.itemID];
    gotoUrl = [gotoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    ;
    
     NSString* itemUrl = [NSString stringWithFormat:@"https://news.ycombinator.com/reply?id=%@&goto=%@", commentID,gotoUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:itemUrl]];
    [request addValue:c forHTTPHeaderField:@"Cookie"];
 
    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    NSArray* inputs = [doc searchWithXPathQuery:@"//input"];
    
    NSString* parent = nil;
    NSString* hmac = nil;

    
    for (TFHppleElement* e in inputs) {
        NSString * elementID = [e objectForKey:@"type"];
        
        if(elementID == nil)
            continue;
        
        if([elementID isEqualToString:@"hidden"]){
            NSLog(@"%@ = %@", [e objectForKey:@"name"], [e objectForKey:@"value"]);
            
            if ([[e objectForKey:@"name"] isEqualToString:@"parent"]) {
                parent = [e objectForKey:@"value"];
            }else if ([[e objectForKey:@"name"] isEqualToString:@"goto"]) {
                gotoUrl = [e objectForKey:@"value"];
            }else if ([[e objectForKey:@"name"] isEqualToString:@"hmac"]) {
                hmac = [e objectForKey:@"value"];
            }

        }
    }
    
    
    
    
    
    gotoUrl = [gotoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    ;
    
    if(parent != nil && gotoUrl != nil && hmac != nil){
        NSString *post = [NSString stringWithFormat:@"action=comment&parent=%@&goto=%@&hmac=%@&",parent, gotoUrl, hmac];
        
        return post;
    }


    return nil;
}

-(NSString*) getUpvoteUrlForItemId:(NSString*)itemID withUserCookie:(NSString*) userCookie {
    
    NSString* cookie = @"__cfduid=d983a124c861acd6ec54abba5c0fa8a4e1416373664;user=kadder&2htGKcow5rVdVke1FgQ0AaUKI9lAdKOb";
    
    if(userCookie != nil){
        cookie = userCookie;
    }
    
    NSString* itemUrl = [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@", itemID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:itemUrl]];
    [request addValue:cookie forHTTPHeaderField:@"Cookie"];

    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    NSString* nodeID = [NSString stringWithFormat:@"up_%@", itemID];
    NSString* xpath = [NSString stringWithFormat:@"//a[@id='%@']", nodeID];
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    NSArray* links = [doc searchWithXPathQuery:@"//a"];
    NSString* voteUrl;

    for (TFHppleElement* e in links) {
        NSString * elementID = [e objectForKey:@"id"];
        
        if(elementID == nil)
            continue;
        
        if([elementID isEqualToString:nodeID]){
            voteUrl = [e objectForKey:@"href"];
            break;
        }
    }
    
    return voteUrl;
}

-(BOOL) upvote:(HackerNewsComment*) item{
    
    if([HackerNewsDBHelper existsUser]){
        NSString* c = [HackerNewsDBHelper userCookieString];
        
        NSString* url = [self getUpvoteUrlForItemId:item.itemID withUserCookie:c];
        NSLog(@"UPVOTE url %@", url);
        
        if(url == nil){
            item.voted = YES;
            
            [HackerNewsDBHelper insertOrUpdate:item];
            return YES;
        }else{
            if ([url containsString:@"auth="]) {
                NSError* error = [self upvoteUrl:url withUserCookie:c];
                if(error == nil){
                    item.voted = YES;
                    
                    [HackerNewsDBHelper insertOrUpdate:item];
                    return YES;
                }
            }
        }
     
        return NO;
    }

    
    return NO;
}

-(NSError*) upvoteUrl:(NSString*)itemUrl withUserCookie:(NSString*) userCookie {
    
    NSString* cookie = @"__cfduid=d983a124c861acd6ec54abba5c0fa8a4e1416373664;user=kadder&2htGKcow5rVdVke1FgQ0AaUKI9lAdKOb";
    
    if(userCookie != nil){
        cookie = userCookie;
    }
    
    NSString *url = [@"https://news.ycombinator.com/" stringByAppendingString:itemUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:cookie forHTTPHeaderField:@"Cookie"];
    
    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return error;
}

- (HackerNewsComment*) getStoryForComment: (HackerNewsComment*) item {
    
    HackerNewsComment* child = [CommentBuilder getItemForItemID:item.itemID];
    HackerNewsComment* parent = [CommentBuilder getItemForItemID:child.parentId];
    [parent.children addObject:child];

    while(![parent.type isEqualToString:@"story"]){
        child = parent;
        parent = [CommentBuilder getItemForItemID:child.parentId];
        [parent.children addObject:child];
    }

    
    return parent;
}

- (void) getCommentsForStoryIDByScraping:(NSString *)storyID {
    [self.delegate receivedJSON:nil];
}

- (void) getCommentsForStoryID:(NSString *)storyID {
    NSString *urlAsString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@.json", storyID];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
    
    if (error) {
        [self.delegate fetchingJSONFailedWithError:error];
    } else {
        [self.delegate receivedJSON:data];
    }

    
    /*
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate fetchingJSONFailedWithError:error];
        } else {
            [self.delegate receivedJSON:data];
        }
    }];*/
}

@end