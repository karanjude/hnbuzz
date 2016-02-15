//
//  MasterViewController.m
//  HackerNews
//
//  Created by Karan Singh on 8/31/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "HackerNewsDelegate.h"
#import "HackerNewsController.h"

#import "HackerNewsComment.h"
#import "CommentBuilder.h"

#import "WebViewController.h"

#import "UIColor+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "NSString+Icons.h"

#import "SwipeableTableCell.h"
#import "RootViewController.h"

#import <MMMaterialDesignSpinner.h>
#import <Crashlytics/Crashlytics.h>

#import "LMAlertView.h"


static NSString * const FUITableViewControllerCellReuseIdentifier = @"Cell";

#define NEXT 30;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface MasterViewController () <HackerNewsDelegate, SWTableViewCellDelegate> {
    NSMutableArray* _items;
    HackerNewsController* _hackerNewsController;
    NSString * _selectedItemID;
    NSString * _oldIndexPrefix;
}

@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshTable;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (strong, nonatomic) MMMaterialDesignSpinner *spinnerView;


@property NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //[self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor pumpkinColor]];

    [self.navigationController.navigationBar setBackgroundColor:[UIColor pumpkinColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor pumpkinColor]];

    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];

    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]
     
                                                forState:UIControlStateNormal];
    
 
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"refresh.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(reset:)];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    
    NSArray *actionButtonItems = @[refreshButton];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    //[self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [self initFooterView];
    

    
    
    _items = [[NSMutableArray alloc] init];
    
    //[UIBarButtonItem configureFlatButtonsWithColor:[UIColor midnightBlueColor]
    //                              highlightedColor:[UIColor belizeHoleColor]
    //                                  cornerRadius:3];

    //self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    _hackerNewsController = [[HackerNewsController alloc] init];
    _hackerNewsController.delegate = self;
    _hackerNewsController.baseurl = self.baseurl;
    
    _oldIndexPrefix = self.startIndexPrefix;
    
    if(self.title != nil){
        [self.navigationController setTitle:self.title];
    }
    
    self.navigationController.toolbarHidden = YES;
    
    [self reset:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNews:) name:@"refreshNews" object:nil];
    
    //self.tableView.layoutMargins = UIEdgeInsetsZero; //or UIEdgeInsetsMake(top, left, bottom, right)
    //self.tableView.separatorInset = UIEdgeInsetsZero; //if you also want to adjust separatorInset
    
    
    
}


-(void)refreshNews:(NSNotification *) notification {
    
    [self reset:nil];
    
}


- (void) receivedJSON:(NSData *)json {
    
    NSError *error = nil;
    NSArray* comments;

    if(json != nil){
        comments = [CommentBuilder itemsFromJSON:json error:&error withStartIndex:self.startIndex];
        
    }else{
        NSUInteger index = 1 + self.startIndex / NEXT;
        NSString * p = self.startIndexPrefix;
        comments = [_hackerNewsController getTopStoriesByScrapingHN:&error withStartIndex: &p basePrefix:_oldIndexPrefix];
        self.startIndexPrefix = p;
    }
    
    for (HackerNewsComment* hn in comments) {
        if(![_items containsObject:hn]){
            [_items addObject:hn];
        }
    }
    
    if(self.title == nil){
        self.title = @"";
    }

    [Answers logCustomEventWithName:@"HNPageLoadComplete" customAttributes:@{@"title:":self.title,
                                                                             @"PageIndex":@(self.startIndex + 1)}];

    
    
}

- (void) fetchingJSONFailedWithError:(NSError *)error {
    NSLog(@"Error %@: %@", error, [error localizedDescription]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)refresh:(UIRefreshControl*) sender{
    self.startIndex += NEXT;
    if(self.startIndex >= 455){
        self.startIndex = 455;
    }

    [_hackerNewsController getTopStories];
}


- (void)loadStories{
    
    if([HackerNewsDBHelper Offline]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Offline " message:@"No Internet Connectivity, app offline" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        [alert show];

        
        return;
    }

    
    if(self.threadedView){
        if([HackerNewsDBHelper existsUser]){
            _hackerNewsController.baseurl = [NSString stringWithFormat:self.baseurl, [HackerNewsDBHelper userName]];
            _oldIndexPrefix = [_oldIndexPrefix stringByAppendingString:[HackerNewsDBHelper userName]];
            self.startIndexPrefix = _oldIndexPrefix;
        }else{
            [self.slideoutController switchToControllerTagged:13 andPerformSelector:nil withObject:nil];
            return;
        }
    }

    
    if(self.spinnerView == nil){
        self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.spinnerView.lineWidth = 3.0f;
        self.spinnerView.tintColor = [UIColor pumpkinColor];
        self.spinnerView.center = self.view.center;

        [self.view addSubview:self.spinnerView];

    }
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.superview.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.alpha = .4;
    
    if(self.spinnerView != nil){
        [self.view.superview insertSubview:blurEffectView aboveSubview:self.view];
        [self.view.superview insertSubview:self.spinnerView aboveSubview:self.view];

        [self.spinnerView startAnimating];
        self.spinnerView.hidden = NO;
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        if(self.threadedView){
            [_hackerNewsController getTopStories];
        }else{
            [_hackerNewsController getTopStoriesByScraping];
        }
        
        
        if(self.title == nil){
            self.title = @"";
        }
        
        
        [Answers logCustomEventWithName:@"HNPageLoadStart" customAttributes:@{@"title:":self.title,
                                                                           @"PageIndex":@(self.startIndex + 1)}];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.spinnerView != nil){
                [self.spinnerView stopAnimating];
                self.spinnerView.hidden = YES;
                [self.spinnerView removeFromSuperview];
            }
            
            if(blurEffectView != nil){
                [blurEffectView removeFromSuperview];
            }

            if(self.tableView != nil){
                [self.tableView reloadData];
            }
            
            
            NSInteger i = self.startIndex - 1;
            
            if(i > [self.tableView numberOfSections] - 1){
                i = [self.tableView numberOfSections] - 1;
            }
            
            BOOL zeroEntries = i < 0;
            
            if( zeroEntries){
                i = 0;
            }
            
            if(!zeroEntries){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                            inSection:i];
                
                [self.tableView scrollToRowAtIndexPath:indexPath
                                      atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
            }

        });
    });

}

- (void)reset:(id)sender {
    self.startIndex = 0;
    self.startIndexPrefix = _oldIndexPrefix;
    [_items removeAllObjects];
    
    [self loadStories];
}


- (void)prevStories:(id)sender {
    self.startIndex -= NEXT;
    if(self.startIndex < 0){
        self.startIndex = 0;
    }
    
    [_hackerNewsController getTopStories];
}


- (void)nextStories:(id)sender {
    self.startIndex += NEXT;
    if(self.startIndex <= 455){
        
        //[_hackerNewsController getTopStories];
        [self loadStories];
    }
    
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (segue != nil && [[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if(indexPath != nil){
            NSDate *object = self.objects[indexPath.row];
            
            if(object != nil){
                DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
                [controller setDetailItem:object];
                controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
                controller.navigationItem.leftItemsSupplementBackButton = YES;

            }
            
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSLog(@"Number of Sections: %@", @(_items.count));
    return _items.count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
    if([HackerNewsDBHelper Offline]){
        return;
    }
    
    
    if(self.threadedView){
        if([HackerNewsDBHelper existsUser]){
            _hackerNewsController.baseurl = [NSString stringWithFormat:self.baseurl, [HackerNewsDBHelper userName]];
        }else{
            [self.slideoutController switchToControllerTagged:13 andPerformSelector:nil withObject:nil];
            return;
        }
    }

    
    if([self.title isEqualToString:@"HN"]){
        [HackerNewsDBHelper clearTrackingItems];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    //NSDate *object = self.objects[indexPath.row];
    //cell.textLabel.text = [object description];
    
    if(indexPath != nil){
        NSLog(@"Section:%@ Row:%@", @(indexPath.section), @(indexPath.row));
    }
    
    // HackerNewsComment* pcomment = _comments[indexPath.section];
    
    /*
    if(pcomment.children == nil || pcomment.children.count == 0 || indexPath.row > pcomment.children.count){
        cell.textLabel.text = pcomment.text;
    }else{
        HackerNewsComment* comment = pcomment.children[indexPath.row];
        cell.textLabel.text = comment.text;
    }*/
    
    /*
    HackerNewsComment* comment = pcomment.children[indexPath.row];
    cell.textLabel.text = comment.text;
    */
    HackerNewsComment* item = _items[indexPath.section];

    SwipeableTableCell *cell = (SwipeableTableCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if ([HackerNewsDBHelper LoggedIn]) {
        if(item.voted){
            cell.rightUtilityButtons = [self rightButtonsWithVotingDisabled];
        }else{
            cell.rightUtilityButtons = [self rightButtons];
        }
        
    }else{
        cell.rightUtilityButtons = [self rightButtonsWithVotingDisabled];
    }
    
    cell.delegate = self;

    if(indexPath.section >= _items.count){
        NSLog(@"LOADING>>>>>>>>>>");
    }
    
    cell.textView = (UILabel *)[cell.contentView viewWithTag:100];
    
    cell.itemScoreAndUpdatedByLabel = (UILabel *)[cell.contentView viewWithTag:101];
    cell.commentCountLabel = (UILabel *)[cell.contentView viewWithTag:102];

    cell.itemScoreAndUpdatedByLabel.numberOfLines = 0;
    cell.itemScoreAndUpdatedByLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.textView.text = item.text;
    
    NSString* itemScoreString = @"";
    if(item.score != nil && ![item.score isEqualToString:@"(null)"]){
        itemScoreString = [NSString stringWithFormat:@"%@ points \n\n", item.score];
    }
    
    NSString* updatedByString = item.updatedBy;
    if(updatedByString == nil || [updatedByString isEqualToString:@"(null)"]){
        updatedByString = @"";
    }
    
    
    cell.itemScoreAndUpdatedByLabel.text = [NSString stringWithFormat:@" %@ %@ ", itemScoreString, updatedByString];
    
    NSString* numberOfCommentsString = item.totalChildren;
    if(numberOfCommentsString == nil || numberOfCommentsString == NULL || [numberOfCommentsString isEqualToString:@"(null)"]){
        numberOfCommentsString = @"0";
    }
    
    cell.commentCountLabel.text = [NSString stringWithFormat:@" %@ comments", numberOfCommentsString];
    
    //[cell.itemScoreAndUpdatedByLabel setBackgroundColor:[MasterViewController colorFromHexString:@"#fde3a7"]];
    
    CALayer* layer = [cell.itemScoreAndUpdatedByLabel layer];
    CALayer *bottomBorder = [CALayer layer];
    [bottomBorder setCornerRadius:2.0];
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(layer.frame.size.width, 5, 5, layer.frame.size.height - 5);
    //[bottomBorder setShadowOffset:CGSizeMake(-1, -1)];
    //[bottomBorder setShadowOpacity:0.5];
    
    NSInteger row = indexPath.section;
    BOOL isEven = (row % 2) == 0;
    if(isEven){
            [bottomBorder setBorderColor:[UIColor pumpkinColor].CGColor];
            [bottomBorder setBackgroundColor:[UIColor pumpkinColor].CGColor];
            [cell.itemScoreAndUpdatedByLabel setTextColor:[UIColor pumpkinColor]];
    }else{
            [bottomBorder setBorderColor:[UIColor lightGrayColor].CGColor];
            [bottomBorder setBackgroundColor:[UIColor lightGrayColor].CGColor];
            [cell.itemScoreAndUpdatedByLabel setTextColor:[UIColor blackColor]];
    }


    [layer addSublayer:bottomBorder];
    
    
    if(item.itemID != nil && [HackerNewsDBHelper visited:item
        .itemID]){
        
        cell.itemScoreAndUpdatedByLabel.alpha = .4;
        cell.textView.alpha = .4;
        cell.commentCountLabel.alpha = .4;
    }else{
        cell.itemScoreAndUpdatedByLabel.alpha = 1;
        cell.textView.alpha = 1;
        cell.commentCountLabel.alpha = 1;

    }
    
    /*
    CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    fade.fromValue = (id)[UIColor pumpkinColor].CGColor;
    fade.toValue = (id)[UIColor clearColor].CGColor;
    [fade setDuration:1];
    [layer addAnimation:fade forKey:@"fadeAnimation"];
    */
    
    return cell;
}


-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    localNotification.fireDate = now;
    localNotification.alertBody = [NSString stringWithFormat:@"New Content"];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    localNotification.repeatInterval = NSCalendarUnitHour;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    completionHandler(UIBackgroundFetchResultNewData);


}

-(void)initFooterView
{
    self.spinner = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width / 2, 40.0)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    actInd.tag = 10;
    
    actInd.frame = CGRectMake(self.view.frame.size.width/2 - 10.0, 5.0, 20.0, 20.0);
    
    actInd.hidesWhenStopped = YES;
    
    [self.spinner addSubview:actInd];
    
    actInd = nil;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (endScrolling >= scrollView.contentSize.height){
        //self.tableView.tableFooterView = self.spinnerView;
        
        //[(UIActivityIndicatorView *)[self.spinner viewWithTag:10] startAnimating];
        //[self.spinnerView startAnimating];
        [self nextStories:nil];
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //if (section == 0)
        return CGFLOAT_MIN;
    //return 2;
    //return tableView.sectionHeaderHeight + 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}



- (void)textViewDidChangeSelection:(UITextView *)textView{
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
    [messageAlert show];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Value Selected by user
    //NSString *selectedValue = [displayValues objectAtIndex:indexPath.row];

    
    NSLog(@"Row Selected: %@", @(indexPath.row));
    HackerNewsComment* item = _items[indexPath.section];
    _selectedItemID = item.itemID;
    
    if(![HackerNewsDBHelper visited:item.itemID]){
        [HackerNewsDBHelper visit:item.itemID];
        [self.tableView reloadData];
    }
    
    if(item.url == nil || ( item.url != nil &&  [ item.url hasPrefix:@"item?id=" ] ) ){
        RootViewController *view = [[RootViewController alloc] init];
        view.slideoutController = self.slideoutController;
        view.storyID = item.itemID;
        view.board = self.storyboard;
        view.story = item;
        
        [self.navigationController pushViewController:view animated:YES];
    }else{
        WebViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
        
        view.url = item.url;
        view.story = item;
        view.board = self.storyboard;
        
        //[self presentModalViewController:web animated:YES];
        [self.navigationController pushViewController:view animated:YES];
    }
    
}

- (NSArray *)rightButtonsWithVotingDisabled
{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor grayColor]
                                                 icon:[UIImage imageNamed:@"comments.png"]];
    
    /*
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor turquoiseColor]
                                                 icon:[UIImage imageNamed:@"chat.png"]];
    */
    
    return rightUtilityButtons;
}


- (NSArray *)rightButtons
{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor carrotColor]
    icon:[UIImage imageNamed:@"upvote.png"] ];

    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor grayColor]
                                                icon:[UIImage imageNamed:@"comments.png"]];

    /*
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor turquoiseColor]
                                                 icon:[UIImage imageNamed:@"chat.png"]];
     */
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    HackerNewsComment* item = _items[indexPath.section];

    if(!item.voted){
        
        if(![HackerNewsDBHelper LoggedIn]){
            index = 1;
        }
        
        switch (index) {
            case 0:{

                LMAlertView *alertView = [[LMAlertView alloc] initWithTitle:@"Upvoting ..."
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:nil , nil];
                [alertView setSize:CGSizeMake(270.0, 60.0)];
                
                // Add your subviews here to customise
                UIView *contentView = alertView.contentView;
                contentView.backgroundColor = [UIColor pumpkinColor];
                
                UILabel* titleLabel =  [contentView.subviews objectAtIndex:0];
                titleLabel.textColor = [UIColor whiteColor];
                [alertView show];

                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    
                    [_hackerNewsController upvote:item];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.tableView reloadData];
                        [alertView removeFromSuperview];
                        
                    });
                });


            }
                break;
            case 1:{
                
                RootViewController *view = [[RootViewController alloc] init];
                view.slideoutController = self.slideoutController;
                view.storyID = item.itemID;
                view.board = self.storyboard;
                view.story = item;
                
                [self.navigationController pushViewController:view animated:YES];
            }
                
                break;
            default:
                break;
        }
        

    }else{
        
        switch (index) {
            case 0:{
                
                RootViewController *view = [[RootViewController alloc] init];
                view.slideoutController = self.slideoutController;
                view.storyID = item.itemID;
                view.board = self.storyboard;
                view.story = item;
                
                [self.navigationController pushViewController:view animated:YES];
            }
                
                break;
            default:
                break;
        }

    }
    
    
    
}

@end
