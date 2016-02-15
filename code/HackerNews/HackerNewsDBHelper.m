//
//  HackerNewsDBHelper.m
//  HackerNews
//
//  Created by Karan Singh on 10/25/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import "HackerNewsDBHelper.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation HackerNewsDBHelper


static FMDatabase *_db = nil;
static BOOL  _loggedIn;

+ (FMDatabase *)DB {
    if(_db != nil){
        return _db;
    }
    
    NSArray *dir =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [dir objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"hn.sqlite"];
    
    if (_db == nil) {
        _db = [FMDatabase databaseWithPath:dbPath];
        _db.shouldCacheStatements = YES;
    }
    
    if (![_db open]) {
        return nil;
    }
    
    return _db;
}

+ (BOOL )LoggedIn {
    return _loggedIn;
}

+ (BOOL )Offline {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus == NotReachable;
}


+ (void) initUser {
    if ([self existsUser]) {
        _loggedIn = YES;
    }
}



+ (NSInteger) createDB {
    
    NSString* createSQL = @"CREATE TABLE IF NOT EXISTS items (itemid long primary key, item_text text, item_type text, total_number_of_comments integer, did_follow integer, did_reply integer, did_comment integer, score integer);";
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    if(![db open]){
        NSLog(@"DB OPEN failed");
        
        return -1;
    }
    
    BOOL success = [db executeStatements:createSQL];
    if(!success){
        NSLog(@"TABLE CREATION failed");
        
        return -1;
    }
    
    createSQL = @"CREATE TABLE IF NOT EXISTS user (username text primary key, cfduid_string text, userid_string text);";

    success = [db executeStatements:createSQL];
    if(!success){
        NSLog(@"TABLE CREATION failed");
        
        return -1;
    }

    createSQL = @"CREATE TABLE IF NOT EXISTS visited (itemid long primary key , did_visit integer);";
    
    success = [db executeStatements:createSQL];
    if(!success){
        NSLog(@"TABLE CREATION failed");
        
        return -1;
    }

    createSQL = @"CREATE TABLE IF NOT EXISTS tracking_items (itemid long primary key);";
    
    success = [db executeStatements:createSQL];
    if(!success){
        NSLog(@"TABLE CREATION failed");
        
        return -1;
    }

    NSLog(@"TABLE CREATED");
    return 0;
}

+ (NSInteger) deleteDB {
    
    NSString* deleteSQL = @"DROP TABLE items ;";
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    if(![db open]){
        NSLog(@"DB OPEN failed");
        
        return -1;
    }
    
    BOOL success = [db executeStatements:deleteSQL];
    if(!success){
        NSLog(@"TABLE DELETION failed");
        
        return -1;
    }
    
    NSLog(@"TABLE DELETED");
    return 0;
}

+ (NSInteger) clearTable {
    
    NSString* deleteSQL = @"DELETE FROM items ;";
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    if(![db open]){
        NSLog(@"DB OPEN failed");
        
        return -1;
    }
    
    BOOL success = [db executeStatements:deleteSQL];
    if(!success){
        NSLog(@"TABLE DELETE failed");
        
        return -1;
    }
    
    NSLog(@"TABLE DELET SUCCEEDED");
    return 0;
}

+ (BOOL) delete: (HackerNewsComment*) story{
    
    NSString* deleteSQL = @"DELETE FROM items WHERE itemid = ?";
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    if(![db open]){
        NSLog(@"DB OPEN failed");
        
        return -1;
    }
    
    BOOL success = [db executeUpdate:deleteSQL, [NSNumber numberWithLongLong:[story.itemID longLongValue]]
                    ];

    
    if(!success){
        NSLog(@"ITEM DELETE failed");
        
        return -1;
    }
    
    NSLog(@"ITEM DELET SUCCEEDED");
    return 0;
}



+ (BOOL) insert: (HackerNewsComment*) story{
    /*
     itemid long primary key,
     item_text text,
     item_type text,
     total_number_of_comments integer,
     did_follow integer,
     did_reply integer,
     did_comment integer
     */
    
    NSString* insertSQL = @"INSERT INTO items VALUES(?,?,?,?,?,?,?,?)";
    
    NSInteger following = 0;
    if(story.following == TRUE){
        following = 1;
    }

    NSInteger replied = 0;
    if(story.replied == TRUE){
        replied = 1;
    }

    NSInteger voted = 0;
    if(story.voted == TRUE){
        voted = 1;
    }
    
    NSInteger childCount = [story.totalChildren integerValue];
    if(childCount == 0 && story.children.count > 0){
        childCount = story.children.count;
    }
    
    NSInteger score = 0;
    if(![story.score isEqualToString:@"(null)"]){
        score = [story.score integerValue];
    }

    
    FMDatabase* db = [HackerNewsDBHelper DB];
    BOOL success = [db executeUpdate:insertSQL, [NSNumber numberWithLongLong:[story.itemID longLongValue]],
     story.text,
     story.type,
     [NSNumber numberWithInteger:childCount],
     [NSNumber numberWithInteger:following],
     [NSNumber numberWithInteger:replied],
     [NSNumber numberWithInteger:voted],
      [NSNumber numberWithInteger:score]
     ];
    
    if(!success){
        NSLog(@"TABLE insertion failed");
        
        return FALSE;
    }
    
    NSLog(@"TABLE insertion succeeded");
    
    return TRUE;
}

+ (BOOL) insertUser: (NSString*)cfduid forUserID:(NSString*) userid withUserName: (NSString*) userName{
    /*
     itemid long primary key,
     item_text text,
     item_type text,
     total_number_of_comments integer,
     did_follow integer,
     did_reply integer,
     did_comment integer
     */
    
    NSString* insertSQL = @"INSERT INTO user VALUES(?,?,?)";
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    BOOL success = [db executeUpdate:insertSQL,
                    userName,
                    cfduid,
                    userid];
    
    if(!success){
        NSLog(@"USER TABLE insertion failed");
        
        return FALSE;
    }
    
    NSLog(@"USER TABLE insertion succeeded");
    
    _loggedIn = YES;
    
    return TRUE;
}

+ (NSInteger) clearTrackingItems {

    NSArray* items = [HackerNewsDBHelper trackingItems];

    NSString* deleteSQL = @"DELETE FROM tracking_items where itemid = (?)";
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    if(![db open]){
        NSLog(@"DB OPEN failed");
        
        return -1;
    }

    
    for (NSInteger i = 0; i < MIN(5, [items count]) ; i++) {
    
        BOOL success = [db executeUpdate:deleteSQL,
                    [items objectAtIndex:i]];
        
        if(!success){
            NSLog(@"TABLE DELETE of TRACKING_ITEMS failed");
        
            return -1;
        }

    }
    NSLog(@"TRACKING_ITEMS CLEARED");
    return 0;
}



+ (BOOL) trackNewItems: (NSArray*)items{
    
    NSString* insertSQL = @"INSERT INTO tracking_items VALUES(?)";
    FMDatabase* db = [HackerNewsDBHelper DB];
    
    for (id itemid in items) {
        BOOL success = [db executeUpdate:insertSQL,
                        itemid];
        
        if(!success){
            NSLog(@"TRACKING_ITEMS TABLE insertion failed");
            
            return FALSE;
        }
        
        NSLog(@"TRACKING_ITEMS insertion succeeded");

    }
    
    return TRUE;
}

+ (NSArray*) trackingItems {
    
    NSString* followSQL = @"SELECT itemid FROM tracking_items ;";
    NSMutableArray * itemIds = [[NSMutableArray alloc] init];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    if(![db open]){
        NSLog(@"DB OPEN failed");
        
        return itemIds;
    }
    
    FMResultSet *s = [db executeQuery:followSQL];
    
    
    NSString* itemId;
    while ([s next]) {
        itemId = [s stringForColumnIndex:0];
        [itemIds addObject:itemId];
    }
    
    NSLog(@"Number of stories being tracked %@", @([itemIds count]));
    
    return itemIds;
}


+ (BOOL) update: (HackerNewsComment*) story{
    /*
     itemid long primary key,
     item_text text,
     item_type text,
     total_number_of_comments integer,
     did_follow integer,
     did_reply integer,
     did_comment integer
     */
    
    NSInteger following = 0;
    if(story.following == TRUE){
        following = 1;
    }
    
    NSInteger replied = 0;
    if(story.replied == TRUE){
        replied = 1;
    }
    
    NSInteger voted = 0;
    if(story.voted == TRUE){
        voted = 1;
    }
    
    NSInteger score = 0;
    if(![story.score isEqualToString:@"(null)"]){
        score = [story.score integerValue];
    }
    
    
    NSString* updateSQL = @"UPDATE items SET item_text=?,item_type=?,total_number_of_comments=?,did_follow=?,did_reply=?,did_comment=?,score=?  WHERE itemid=?";
    
    NSInteger childCount = [story.totalChildren integerValue];
    if(childCount == 0 && story.children.count > 0){
        childCount = story.children.count;
    }
    
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    BOOL success = [db executeUpdate:updateSQL, story.text,
                    story.type,
                    [NSNumber numberWithInteger:childCount],
                    [NSNumber numberWithInteger:following],
                    [NSNumber numberWithInteger:replied],
                    [NSNumber numberWithInteger:voted],
                    [NSNumber numberWithInteger:score],
                    [NSNumber numberWithLongLong:[story.itemID longLongValue]]
                    ];
    
    if(!success){
        NSLog(@"TABLE updation failed");
        
        return FALSE;
    }
    
    NSLog(@"TABLE updation succeeded");
    
    return TRUE;
}

+ (BOOL) hasUpdated: (HackerNewsComment*) item{
    NSString* existsSQL = [NSString stringWithFormat:@"SELECT * FROM items WHERE itemid = %@", item.itemID];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    FMResultSet *s = [db executeQuery:existsSQL];
    
    NSInteger commentCount = 0;
    NSInteger score = 0;
    if ([s next]) {
        commentCount = [s intForColumnIndex:3];
        score = [s intForColumnIndex:7];
        
        NSLog(@"Got item with %@ %@ %@ %@ %@ %@ %@",
              @([s longForColumnIndex:0]),
              [s stringForColumnIndex:1],
              [s stringForColumnIndex:2],
              @([s intForColumnIndex:3]),
              @([s boolForColumnIndex:4]),
              @([s boolForColumnIndex:5]),
              @([s boolForColumnIndex:6])
              );
    }

    BOOL changed = FALSE;
    
    NSInteger childCount = [item.children count];
    if(childCount > 0 && childCount != commentCount){
        changed = TRUE;
    }
    
    NSInteger scoreToCheck = [item.score integerValue];
    if(score > 0 && ![item.score isEqualToString:@"(null)"] && score != scoreToCheck){
        changed = TRUE;
    }
    
    if(item.totalChildren != nil && ![item.totalChildren isEqualToString:@"(null)"]){
        childCount = [item.totalChildren integerValue];
        if(childCount != commentCount){
            changed = TRUE;
        }else{
            changed = FALSE;
        }
    }

    
    return changed;
}

+ (HackerNewsComment*) get: (NSString*) itemID{
    NSString* existsSQL = [NSString stringWithFormat:@"SELECT * FROM items WHERE itemid = %@", itemID];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    FMResultSet *s = [db executeQuery:existsSQL];
    
    HackerNewsComment * comment = nil;

    if ([s next]) {
        
        /*
         itemid long primary key,
         item_text text,
         item_type text,
         total_number_of_comments integer,
         did_follow integer,
         did_reply integer,
         did_comment integer
         */

        comment = [[HackerNewsComment alloc] init];
        comment.itemID  = itemID;
        comment.text = [s stringForColumnIndex:1];
        comment.type = [s stringForColumnIndex:2];
        comment.totalChildren = [NSString stringWithFormat:@"%@", @([s intForColumnIndex:3])];
        comment.following = [s intForColumnIndex:4] == 1;
        comment.replied = [s intForColumnIndex:5] == 1;
        comment.voted = [s intForColumnIndex:6] == 1;
        
        
        NSLog(@"item: %@",
              comment
              );
    }
    
    return comment;
}

+ (BOOL) visited: (NSString*) itemID{
    NSString* existsSQL = [NSString stringWithFormat:@"SELECT * FROM visited WHERE itemid = ? and did_visit = 1"];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    FMResultSet *s = [db executeQuery:existsSQL, [NSNumber numberWithLong:[itemID longLongValue]]];
    
    if ([s next]) {

        return YES;
        
    }
    
    return NO;
}

+ (BOOL) visit: (NSString*) itemID{
    /*
     itemid long primary key,
     item_text text,
     item_type text,
     total_number_of_comments integer,
     did_follow integer,
     did_reply integer,
     did_comment integer
     */
    
    NSString* insertSQL = @"INSERT INTO visited VALUES(?,?)";
    
    NSInteger did_visit = 1;
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    BOOL success = [db executeUpdate:insertSQL, [NSNumber numberWithLongLong:[itemID longLongValue]],
                      [NSNumber numberWithInteger:did_visit]
                    ];
    
    if(!success){
        NSLog(@"TABLE insertion failed");
        
        return FALSE;
    }
    
    NSLog(@"TABLE insertion succeeded");
    
    return TRUE;

}



+ (BOOL) insertOrUpdate: (HackerNewsComment*) story {
    if([self exists:story]){
        return [self update:story];
    }
    
    return [self insert:story];
}

+ (BOOL) existsUser {
    
    NSString* existsSQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM user "];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    FMResultSet *s = [db executeQuery:existsSQL];
    
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    
    NSLog(@"User Exists: %@", @(count));
    
    if(count >= 1){
        _loggedIn = YES;
    }
    
    return count >= 1;
}

+ (BOOL) deleteUser {
    
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM user "];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    BOOL s = [db executeUpdate:deleteSQL];
    
    NSLog(@"Deleted users : %@", @(s));
    
    _loggedIn = NO;
    
    return s;
    
}

+ (NSString*) userName {
    
    NSString* userSQL = [NSString stringWithFormat:@"SELECT * FROM user "];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    FMResultSet *s = [db executeQuery:userSQL];

    NSString* userName;
    
    if ([s next]) {
        
        userName = [s stringForColumnIndex:0];
        
        NSLog(@"Got item with %@ %@ %@",
              [s stringForColumnIndex:0],
              [s stringForColumnIndex:1],
              [s stringForColumnIndex:2]
              );

    }
    
    return userName;
    
}


+ (NSString*) userCookieString {
    
    NSString* existsSQL = [NSString stringWithFormat:@"SELECT * FROM user "];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    FMResultSet *s = [db executeQuery:existsSQL];
    
    NSString* cfduid = nil;
    NSString* userid = nil;
    
    if ([s next]) {
        cfduid = [s stringForColumnIndex:1];
        userid = [s stringForColumnIndex:2];
        
        NSLog(@"Got item with %@ %@ %@",
              [s stringForColumnIndex:0],
              [s stringForColumnIndex:1],
              [s stringForColumnIndex:2]
              );
    }

    NSString * cookieString = [NSString stringWithFormat:@"%@;%@", cfduid, userid];
    
    NSLog(@"User cookie: %@", cookieString);
    
    return cookieString;
}



+ (BOOL) exists: (HackerNewsComment*) item {
    
    NSString* existsSQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM items WHERE itemid = %@",item.itemID];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    FMResultSet *s = [db executeQuery:existsSQL];
    
    NSInteger count = 0;
    if ([s next]) {
        count = [s intForColumnIndex:0];
    }
    
    NSLog(@"Item Exists: %@", @(count));
    
    return count == 1;
}




+ (NSArray*) itemsBeingFollowed {
    
    NSString* followSQL = @"SELECT itemid FROM items WHERE did_follow = 1 ;";
    NSMutableArray * itemIds = [[NSMutableArray alloc] init];
    
    FMDatabase* db = [HackerNewsDBHelper DB];
    if(![db open]){
        NSLog(@"DB OPEN failed");
        
        return itemIds;
    }
    
    FMResultSet *s = [db executeQuery:followSQL];
    
    
    NSString* itemId;
    while ([s next]) {
        itemId = [s stringForColumnIndex:0];
        [itemIds addObject:itemId];
    }
    
    NSLog(@"Number of stories being followed %@", @([itemIds count]));
    
    return itemIds;
}


@end
