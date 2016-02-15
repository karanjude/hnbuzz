//
//  AppDelegate.m

//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import <RKSwipeBetweenViewControllers/RKSwipeBetweenViewControllers.h>
#import "ViewsViewController.h"
#import "ActionableTableViewController.h"
#import "UIColor+FlatUI.h"
#import "CommentBuilder.h"
#import "LoginViewController.h"
#import "HackerNewsController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Doorbell/Doorbell.h"
#import "RootViewController.h"

#import <StoreKit/SKStoreProductViewController.h>




@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
    NSString* buildVersion = infoDictionary[@"CFBundleVersion"];
    NSString* appLocalVersionString = [NSString stringWithFormat:@"%@(%@)", currentVersion, buildVersion];
    NSLog(@"App Current Version: %@", appLocalVersionString);
    
    
    NSString *urlAsString = [NSString stringWithFormat:@"http://karanjude.github.io/hnbuzz/version.txt"];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSError* error;
    NSURLResponse *response;
    NSData* data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:&response error:&error];
    NSDictionary* metaDataForApp = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    NSString * appID;
    NSString* appRemoteVersionString;
    
    if(error == nil){
        appID = [NSString stringWithFormat:@"%@",[metaDataForApp valueForKey:@"appid"]];
        NSString* remoteAppVersion = [NSString stringWithFormat:@"%@",[metaDataForApp valueForKey:@"version"]];
        NSString* remoteAppBuildVersion = [NSString stringWithFormat:@"%@", [metaDataForApp valueForKey:@"buildVersion"]];
        appRemoteVersionString = [NSString stringWithFormat:@"%@(%@)", remoteAppVersion, remoteAppBuildVersion];
        
        if(![appLocalVersionString isEqualToString:appRemoteVersionString]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Required" message:@"This version is no longer supported, please Update, Redirecting to the App Store" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
            
            [alert show];
            [self openAppInAppStore:appID];
            
            return FALSE;
        }
        
    }
    
    [Fabric with:@[[Crashlytics class]]];
    
    NSString *appId = @"2580";
    NSString *appKey = @"8sVRknUq4Ax8OA4nVE5CvDvzBpHXRmqzFIYlk0JOL1C69bOUhR3hjqKji5CqgLy4";
    
    Doorbell *feedback = [Doorbell doorbellWithApiKey:appKey appId:appId];
    feedback.showEmail = NO;
    feedback.showPoweredBy = YES;

    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    
    // Override point for customization after application launch.
    UINavigationController *navigationController = [splitViewController.viewControllers firstObject];
    //navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.37 green:0.41f blue:0.48f alpha:1.0f]];
    
    self.slideoutController = [AMSlideOutNavigationController slideOutNavigation];
    
        [self.slideoutController setSlideoutOptions:
         @{
           AMOptionsAnimationShrink: @NO,
           AMOptionsAnimationDarken: @NO,
           AMOptionsAnimationSlide: @YES,
           AMOptionsCellBackground: [UIColor clearColor],
           AMOptionsAnimationSlidePercentage: @0.7f,
           AMOptionsEnableShadow : @YES,
           AMOptionsBadgeShowTotal: @YES,
           // Want inset cell widths? uncomment and set size of gap that goes on both sides
           //AMOptionsTableInsetX : @(10),
           // Want a custom cell? uncomment and use your own class that inherits from AMSlideTableCell
           //AMOptionsTableCellClass: @"CustomCell",
           AMOptionsHeaderFont : [UIFont systemFontOfSize:18],
           AMOptionsHeaderFontColor: [UIColor whiteColor],
           AMOptionsBackground: [UIColor whiteColor],
           AMOptionsSelectionBackground : [UIColor darkGrayColor],
           AMOptionsCellBackground: [UIColor whiteColor],
           AMOptionsCellSeparatorUpper: [UIColor whiteColor],
           AMOptionsCellSeparatorLower: [UIColor clearColor],
           AMOptionsHeaderSeparatorUpper : [UIColor clearColor],
           AMOptionsHeaderSeparatorLower : [UIColor whiteColor],
           AMOptionsCellFontColor: [UIColor grayColor],
           AMOptionsCellShadowColor: [UIColor clearColor],
           AMOptionsHeaderGradientUp :  [UIColor darkGrayColor],
           AMOptionsHeaderGradientDown : [UIColor darkGrayColor],
           AMOptionsHeaderHeight : @(44),
           AMOptionsNavbarTranslucent: @YES,
           }];
    
    
    // Add a first section
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    [self.slideoutController addSectionWithTitle:@"Hacker News"];
    NSArray* controllers = [navigationController viewControllers];
    MasterViewController* controller = [controllers objectAtIndex:0];
    controller.baseurl = TOP_STORIES_URL_1;
    controller.startIndexPrefix = TOP_STORIES_URL_1_PREFIX;
    controller.slideoutController = self.slideoutController;
    
    [self.slideoutController addViewControllerToLastSection:controller tagged:1 withTitle:@"HN" andIcon:@""];
    
    MasterViewController* newestController = [storyboard instantiateViewControllerWithIdentifier:@"MasterView"];
    newestController.title = @"Newest";
    newestController.baseurl = NEW_STORIES_URL_1;
    newestController.startIndexPrefix = NEW_STORIES_URL_1_PREFIX;
    newestController.slideoutController = self.slideoutController;
    
    
    [self.slideoutController addViewControllerToLastSection:newestController tagged:2 withTitle:@"Newest" andIcon:@""];

    MasterViewController* showhn = [storyboard instantiateViewControllerWithIdentifier:@"MasterView"];
    showhn.title = @"Show HN";
    showhn.baseurl = SHOW_STORIES_URL_1;
    showhn.startIndexPrefix = SHOW_STORIES_URL_1_PREFIX;
    showhn.slideoutController = self.slideoutController;
    
    [self.slideoutController addViewControllerToLastSection:showhn tagged:3 withTitle:@"Show HN" andIcon:@""];

    MasterViewController* askhn = [storyboard instantiateViewControllerWithIdentifier:@"MasterView"];
    askhn.title = @"Ask HN";
    askhn.baseurl = ASK_STORIES_URL_1;
    askhn.startIndexPrefix = ASK_STORIES_URL_1_PREFIX;
    askhn.slideoutController = self.slideoutController;
    
    [self.slideoutController addViewControllerToLastSection:askhn tagged:4 withTitle:@"Ask HN" andIcon:@""];

    MasterViewController* jobs = [storyboard instantiateViewControllerWithIdentifier:@"MasterView"];
    jobs.title = @"Jobs";
    jobs.baseurl = JOB_STORIES_URL_1;
    jobs.startIndexPrefix = JOB_STORIES_URL_1_PREFIX;
    jobs.slideoutController = self.slideoutController;
    
    [self.slideoutController addViewControllerToLastSection:jobs tagged:5 withTitle:@"Jobs" andIcon:@""];

    MasterViewController* threads = [storyboard instantiateViewControllerWithIdentifier:@"MasterView"];
    threads.title = @"My Threads";
    threads.baseurl = MY_THREADS_URL;
    threads.slideoutController = self.slideoutController;
    threads.threadedView = TRUE;
    threads.startIndexPrefix = MY_THREADS_URL_1_PREFIX;
    [self.slideoutController addViewControllerToLastSection:threads tagged:6 withTitle:@"My Threads" andIcon:@""];
    
    [self.slideoutController addSectionWithTitle:@"Actions"];
    
    ActionableTableViewController *followingViewController = [[ActionableTableViewController alloc] init];
    followingViewController.board = storyboard;
    
    [self.slideoutController addViewControllerToLastSection:followingViewController tagged:12 withTitle:@"Following" andIcon:@""];
    //[self.slideoutController addViewControllerToLastSection:controller tagged:6 withTitle:@"Commented" andIcon:@""];
    //[self.slideoutController addViewControllerToLastSection:controller tagged:7 withTitle:@"Upvoted" andIcon:@""];

    
    [self.slideoutController addSectionWithTitle:@"Account"];
    
    LoginViewController* loginController = [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    loginController.slideoutController = self.slideoutController;
    loginController.controller = controller;
    
    [self.slideoutController addViewControllerToLastSection:loginController tagged:13 withTitle:@"Login" andIcon:@""];

    
    [self.slideoutController addActionToLastSection:^{
        
        
        [feedback showFeedbackDialogInViewController:self.slideoutController completion:^(NSError *error, BOOL isCancelled) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
        
        } // Some action
                                             tagged:14
                                          withTitle:@"Send Feedback"
                                            andIcon:@""];

    
    /* To use a custom header: */
    //[self.slideoutController addSectionWithTitle:@"" andHeaderClassName:@"UITableViewCell" withHeight:5];
    
    [self.window setRootViewController:self.slideoutController];
    [self.window makeKeyAndVisible];
    
    //[self.slideoutController setBadgeTotalValue:@"1"];

    //[HackerNewsDBHelper clearTable];
    //[HackerNewsDBHelper deleteDB];
    [HackerNewsDBHelper createDB];
    //[HackerNewsDBHelper itemsBeingFollowed];
    
    if([HackerNewsDBHelper existsUser]){
        [self.slideoutController setBadgeValue:@"Logout" forTag:13];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    return YES;
}


- (void) openAppInAppStore: (NSString*) appID {
    
    if([appID length] > 0){
        NSString *iTunesLink = [NSString  stringWithFormat:@"itms-apps://itunes.apple.com/us/app/pages/id%@?mt=8&uo=4", appID];

        
        NSLog(@"%@", iTunesLink);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }

}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return TRUE;
}

-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    
    NSString* urlString = [url absoluteString];
    NSArray* parts = [urlString componentsSeparatedByString:@"hnbuzz://"];
    
    urlString = parts[1];
    
    NSRange rOriginal = [urlString rangeOfString: @"https"];
    if (NSNotFound != rOriginal.location) {
        urlString = [urlString
                    stringByReplacingCharactersInRange: rOriginal
                    withString:                         @"https:"];
    }
    
    
    NSRange rOriginal1 = [urlString rangeOfString: @"https::"];
    if (NSNotFound != rOriginal1.location) {
        urlString = [urlString
                     stringByReplacingCharactersInRange: rOriginal1
                     withString:                         @"https:"];
    }

    
    if([urlString hasPrefix:TOP_STORIES_URL_2 ] || [urlString isEqualToString:TOP_STORIES_URL_2]){
        [self.slideoutController switchToControllerTagged:1 andPerformSelector:@selector(loadStories:) withObject:nil];

    }else if([urlString hasPrefix:NEW_STORIES_URL_2 ] || [urlString isEqualToString:NEW_STORIES_URL_2]){
        [self.slideoutController switchToControllerTagged:2 andPerformSelector:@selector(loadStories:) withObject:nil];

    }else if([urlString hasPrefix:SHOW_STORIES_URL_2 ] || [urlString isEqualToString:SHOW_STORIES_URL_2]){
        [self.slideoutController switchToControllerTagged:3 andPerformSelector:@selector(loadStories:) withObject:nil];

    }else if([urlString hasPrefix:ASK_STORIES_URL_2 ] || [urlString isEqualToString:ASK_STORIES_URL_2]){
        [self.slideoutController switchToControllerTagged:4 andPerformSelector:@selector(loadStories:) withObject:nil];

    }else if([urlString hasPrefix:JOB_STORIES_URL_2 ] || [urlString isEqualToString:JOB_STORIES_URL_2]){
        [self.slideoutController switchToControllerTagged:5 andPerformSelector:@selector(loadStories:) withObject:nil];

    }else if([urlString hasPrefix:MY_THREADS_URL_2 ] || [urlString isEqualToString:MY_THREADS_URL_2]){
        [self.slideoutController switchToControllerTagged:6 andPerformSelector:@selector(loadStories:) withObject:nil];

    }else if([urlString hasPrefix:ITEM_URL_2 ] || [urlString isEqualToString:ITEM_URL_2]){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RootViewController* itemView = [[RootViewController alloc] init];
        
        NSArray* parts = [urlString componentsSeparatedByString:@"="];
        NSString* itemID = parts[1];
        
        itemView.storyID = itemID;
        itemView.board = storyboard;
        itemView.story = [CommentBuilder getItemForItemID:itemID];
        
        AMSlideOutNavigationController *splitViewController = (AMSlideOutNavigationController *)self.window.rootViewController;
        
        // Override point for customization after application launch.
        [[splitViewController contentController] pushViewController:itemView animated:YES];
        

        
        
        //[self.slideoutController showViewController:itemView sender:nil];
        
    }
    else{
        [self.slideoutController switchToControllerTagged:1 andPerformSelector:@selector(loadStories:) withObject:nil];
    }




    
    return TRUE;
}

-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    return TRUE;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    BOOL updated  = FALSE;
    NSArray* itemIds = [HackerNewsDBHelper itemsBeingFollowed];
    NSInteger updateCount = 0;
    
    for (NSString* itemId in itemIds) {
        HackerNewsComment *item = [CommentBuilder getCommentsForCommentID:itemId level:-1];
        BOOL itemUpdated = [HackerNewsDBHelper hasUpdated:item];
        updated = updated || itemUpdated;
        
        if(itemUpdated){
            updateCount++;
        }
    }
    
    if(updated){
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        localNotification.fireDate = now;
        localNotification.alertBody = [NSString stringWithFormat:@"%@ Stories Updated", @(updateCount)];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertTitle = @"Following Stories Updated";
        //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        //localNotification.repeatInterval = NSCalendarUnitHour;
        //[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
    }
    
    NSArray* updatedStories = [HackerNewsController checkForNewStories ];
    if ([updatedStories count] >= 5) {
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        localNotification.fireDate = now;
        localNotification.alertBody = [NSString stringWithFormat:@"%@ New Stories", @([updatedStories count])];
        localNotification.alertTitle = @"New Stories Available";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        //localNotification.repeatInterval = NSCalendarUnitHour;
        //[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    


    
    /*

    NSLog(@"Fetch started");

    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    MasterViewController* m = (MasterViewController*) [[splitViewController.viewControllers firstObject] topViewController];
    
    [m fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
        NSLog(@"Fetch completed");
    }];
     
     */
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString* notificationTitle = notification.alertTitle;
    if([notificationTitle isEqualToString:@"New Stories Available"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNews" object:nil];
        [self.slideoutController switchToControllerTagged:1 andPerformSelector:nil withObject:nil];

    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFollowing" object:nil];
        [self.slideoutController switchToControllerTagged:12 andPerformSelector:nil withObject:nil];
    }
    
    
    
    // Request to reload table view data
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Set icon badge number to zero
    // application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    
    //Success
    handler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s", __PRETTY_FUNCTION__);
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%s", __PRETTY_FUNCTION__);
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

@end
