//
//  HackerNewsDBHelper.h
//  HackerNews
//
//  Created by Karan Singh on 10/25/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerNewsComment.h"
#import <FMDatabase.h>

@interface HackerNewsDBHelper : NSObject

+ (FMDatabase *)DB;

+ (NSInteger) createDB;

+ (NSInteger) deleteDB;

+ (NSInteger) clearTable;

+ (NSArray*) itemsBeingFollowed;

+ (BOOL) insert: (HackerNewsComment*) item;

+ (BOOL) exists: (HackerNewsComment*) item;

+ (BOOL) update: (HackerNewsComment*) story;

+ (BOOL) delete: (HackerNewsComment*) story;

+ (BOOL) deleteUser;

+ (BOOL) hasUpdated: (HackerNewsComment*) item;

+ (BOOL) insertUser: (NSString*)cfduid forUserID:(NSString*) userid withUserName: (NSString*) userName;

+ (BOOL) existsUser;

+ (NSString*) userName;

+ (NSString*) userCookieString;

+ (HackerNewsComment*) get: (NSString*) itemID;

+ (BOOL) insertOrUpdate: (HackerNewsComment*) story;

+ (BOOL )LoggedIn;

+ (BOOL )Offline;

+ (void) initUser;

+ (BOOL) visit: (NSString*) itemID;

+ (BOOL) visited: (NSString*) itemID;

+ (NSArray*) trackingItems;

+ (BOOL) trackNewItems: (NSArray*)items;

+ (NSInteger) clearTrackingItems;

@end
