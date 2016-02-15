//
//  CommentBuilder.m
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommentBuilder.h"
#import "HackerNewsDBHelper.h"
#import "TFHpple.h"

@implementation CommentBuilder

+ (HackerNewsComment*) getCommentsForCommentID:(NSString *)commentID level:(NSInteger)level{
    NSString *urlAsString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@.json", commentID];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    HackerNewsComment* comment;
    NSURLResponse* response;
    NSError* error;
    
    NSData* json = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
    
    
    if(json == nil){
        return nil;
    }
    
    if(error){
        return comment;
    }
    
    comment = [[HackerNewsComment alloc] init];
    comment.level = level + 1;
    comment.children = [CommentBuilder commentsFromJSON:json havingParentComment:comment error:&error];
    
    return comment;
}

+ (HackerNewsComment*) getItemForItemID:(NSString *)itemID {
    NSString *urlAsString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@.json", itemID];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    HackerNewsComment* item;
    NSURLResponse* response;
    NSError* error;
    
    NSData* json = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
    
    if(error){
        return item;
    }
    
    item = [[HackerNewsComment alloc] init];
    
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    
    if (error != nil) {
        return nil;
    }
    
    NSString *itemText = [parsedObject valueForKey:@"title"];
    if(itemText == nil){
        itemText = [parsedObject valueForKey:@"text"];
    }

    item.itemID = [parsedObject valueForKey:@"id"];
    item.text = itemText;
    item.updatedBy = [parsedObject valueForKey:@"by"];
    item.score = [NSString stringWithFormat:@"%@", [parsedObject valueForKey:@"score"]];
    item.url = [parsedObject valueForKey:@"url"];
    
    if([parsedObject valueForKey:@"descendants"] == nil){
        NSArray* x = [parsedObject valueForKey:@"kids"];
        if(x != nil){
            item.totalChildren = [NSString stringWithFormat:@"%@", @([x count])];
        }else{
            item.totalChildren = @"(null)";
        }
        
    }else{
        item.totalChildren = [NSString stringWithFormat:@"%@", [parsedObject valueForKey:@"descendants"]];
    }
    
    item.type = [parsedObject valueForKey:@"type"];
    item.parentId = [parsedObject valueForKey:@"parent"];
    item.children = [[NSMutableArray alloc] init];
    item.deleted = [parsedObject valueForKey:@"deleted"];
    
    NSLog(@"Item id:%@ type:%@ parent:%@", item.itemID, item.type, item.parentId);
    
    return item;
}


+ (NSArray *)commentsFromJSON:(NSData *)json havingParentComment: (HackerNewsComment* ) pcomment error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:json options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    
    pcomment.type = [parsedObject valueForKey:@"type"];

    if ([pcomment.type isEqualToString:@"story"]) {
        pcomment.text = [parsedObject valueForKey:@"title"];
        pcomment.url = [parsedObject valueForKey:@"url"];
    }else{
        pcomment.text = [parsedObject valueForKey:@"text"];
    }
    
    pcomment.itemID = [parsedObject valueForKey:@"id"];
    pcomment.updatedBy = [parsedObject valueForKey:@"by"];
    pcomment.totalChildren = [NSString stringWithFormat:@"%@", [parsedObject valueForKey:@"descendants"]];
    pcomment.score = [NSString stringWithFormat:@"%@", [parsedObject valueForKey:@"score"]];
    pcomment.deleted = [parsedObject valueForKey:@"deleted"];
    
    NSArray *results = [parsedObject valueForKey:@"kids"];
    
    if([HackerNewsDBHelper exists:pcomment]){
        HackerNewsComment* itemFromDB = [HackerNewsDBHelper get:pcomment.itemID];
        pcomment.voted = itemFromDB.voted;
        pcomment.following = itemFromDB.following;
    }
    
    
    for (NSString* commentID in results) {
        HackerNewsComment* comment = [[HackerNewsComment alloc] init];
        comment.itemID = commentID;
        
        
        //HackerNewsComment *comment = [CommentBuilder getCommentsForCommentID:commentID level:pcomment.level];
        if(comment){
            [comments addObject:comment];
            
            //comment.totalChildren += 1;
            //pcomment.totalChildren += comment.totalChildren;
        }
    }
    
    
    return comments;
}

+ (void) commentsForParent:(HackerNewsComment*)parentComment
{
    NSMutableArray *childComments = [[NSMutableArray alloc] init];
    
    for (HackerNewsComment* childComment in parentComment.children) {
        HackerNewsComment *comment = [CommentBuilder getCommentsForCommentID:childComment.itemID level:parentComment.level];
        
        if(comment != nil) {
            [childComments addObject:comment];
        }
    }
    
    parentComment.children = childComments;
}

+ (NSArray *)commentsForStoryIdByScraping:(NSString *)storyId error:(NSError **)error level:(NSInteger) level pcomment:(HackerNewsComment* )pcomment{
    
    NSString *urlAsString = [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@", storyId];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:error];

    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    NSArray * commentIndentations  = [doc searchWithXPathQuery:@"//td[@class='ind']"];
    NSArray * defaults  = [doc searchWithXPathQuery:@"//td[@class='default']"];
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    HackerNewsComment* parent;

    for (NSUInteger index = 0; index < [commentIndentations count]; index++) {
        
        TFHppleElement* spaceGifContainer = [commentIndentations objectAtIndex:index];
        NSArray* spacerGifElements = [spaceGifContainer childrenWithTagName:@"img"];
        
        if([spacerGifElements count] >= 1){
            TFHppleElement* spacerGif = spacerGifElements[0];

            if([[spacerGif objectForKey:@"width"] isEqualToString:@"0"]){
                parent = [[HackerNewsComment alloc] init];
                parent.type = @"comment";
                parent.children = [[NSMutableArray alloc] init];
                parent.level = level + 1;
                
                
                TFHppleElement * defaultObject = [defaults objectAtIndex: index];
                NSArray* childWithComments = [defaultObject childrenWithClassName:@"comment"];
                if([childWithComments count] >= 1){
                    TFHppleElement* comment = childWithComments[0];
                    
                    NSArray* childWithCommentsSpan = [comment childrenWithTagName:@"span"];
                    if([childWithCommentsSpan count] >= 1){
                        TFHppleElement* commentTextHolder = childWithCommentsSpan[0];
                        NSArray* replyChildren = [commentTextHolder childrenWithClassName:@"reply"];
                        
                        NSString* commentText = [commentTextHolder raw];
                        
                        if([replyChildren count] >= 1){
                            TFHppleElement* replyChild = replyChildren[0];
                            commentText = [commentText stringByReplacingOccurrencesOfString:[replyChild raw] withString:@""];
                        }
                        
                        
                        parent.text = commentText;
                    }else{
                        parent.deleted = YES;
                    }
                    
                }else{
                    parent.deleted = YES;
                }
                
                
                
                NSArray* itemIdsDivTags = [defaultObject childrenWithTagName:@"div"];
                if([itemIdsDivTags count] >= 1){
                    TFHppleElement* itemIdsDivTag = itemIdsDivTags[0];
                    NSArray* comHeads = [itemIdsDivTag childrenWithClassName:@"comhead"];
                    
                    if([comHeads count] >= 1){
                        TFHppleElement* comhead = comHeads[0];
                        NSArray* ageTags = [comhead childrenWithClassName:@"age"];

                        if([ageTags count] >= 1){
                            TFHppleElement* ageTag = ageTags[0];
                            
                            NSArray* aTags = [ageTag childrenWithTagName:@"a"];
                            for (TFHppleElement *aTag in aTags) {
                                NSString* hrefValue = [aTag objectForKey:@"href"];
                                if([hrefValue hasPrefix:@"item?id="] ){
                                    NSArray* parts = [hrefValue componentsSeparatedByString:@"="];
                                    parent.itemID = parts[1];
                                    
                                }
                            }

                            
                        }
                        
                        
                        
                    }
                }
                
                
                [result addObject:parent];
            }else{
                [parent.children addObject:[[HackerNewsComment alloc] init]];
            }


        }
        
        
    }
    
    if(pcomment != nil){
        pcomment.children = result;
        
        return pcomment.children;
    }
    
    return result;
}

+ (NSArray *)commentsFromJSON:(NSData *)json error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:json options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    NSArray *results = [parsedObject valueForKey:@"kids"];
    
    for (NSString* commentID in results) {
        HackerNewsComment *comment = [CommentBuilder getCommentsForCommentID:commentID level:-1];
        if(comment.deleted == YES || comment.deleted == TRUE){
            continue;
        }

        [comments addObject:comment];
    }
    
    return comments;
}

+ (NSArray *)itemsFromJSON:(NSData *)json error:(NSError **)error withStartIndex:(NSUInteger)startIndex
{
    NSError *localError = nil;
    NSArray *itemIds = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:json options:0 error:&localError];
    if([result isKindOfClass:[NSDictionary class]]){
        NSDictionary * dict = (NSDictionary* ) result;
        itemIds =  [dict valueForKey:@"submitted"];
    } else{
        itemIds = (NSArray*) result;
    }
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSUInteger start = startIndex;
    NSUInteger end = start + 15;
    
    if([itemIds count] < start){
        return items;
    }
    
    if([itemIds count] < end){
        end = [itemIds count];
    }
    
    for (NSUInteger i = start; i < end; i++) {
        NSString* itemID = [itemIds objectAtIndex:i];
        HackerNewsComment *item = [CommentBuilder getItemForItemID:itemID];
        
        if(item.deleted){
            continue;
        }
        
        if(item != nil){
            item.alreadyRead = NO;

            if ([HackerNewsDBHelper exists:item]) {
                HackerNewsComment* itemFromDB;
                if(item.itemID != nil){
                    itemFromDB = [HackerNewsDBHelper get:item.itemID];
                }

                if(itemFromDB != nil){
                    item.voted = itemFromDB.voted;
                    item.following = itemFromDB.following;
                    item.replied = itemFromDB.replied;
                }
            }
            
            [items addObject:item];
        }
        
    }
    
    return items;
}
@end