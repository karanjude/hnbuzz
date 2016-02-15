//
//  ActionableTableViewController.m
//  HackerNews
//
//  Created by Karan Singh on 10/25/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import "ActionableTableViewController.h"
#import "HackerNewsDBHelper.h"
#import "CommentBuilder.h"
#import "RATableViewCell.h"
#import "StoryTableViewCell.h"
#import "UIColor+FlatUI.h"
#import "RootViewController.h"
#import "HackerNewsController.h"
#import <Crashlytics/Crashlytics.h>

@interface ActionableTableViewController (){
    NSMutableArray* followingStories;
    NSMutableArray* followingComments;
    HackerNewsController* hackerNewsController;
}


@end

@implementation ActionableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([HackerNewsDBHelper Offline]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Offline " message:@"No Internet Connectivity, app offline" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        [alert show];
        
        
        return;
    }

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([StoryTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([StoryTableViewCell class])];


    self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height - 100);
    
    
    followingStories = [[NSMutableArray alloc] init];
    followingComments = [[NSMutableArray alloc] init];
    
    hackerNewsController = [[HackerNewsController alloc] init];
    
    NSArray* itemIds = [HackerNewsDBHelper itemsBeingFollowed];
    for (NSString* itemId in itemIds) {
        HackerNewsComment *item = [CommentBuilder getCommentsForCommentID:itemId level:-1];
        item.following = TRUE;
        
        if([item.type isEqualToString:@"story"]){
            [followingStories addObject:item];
        }else if([item.type isEqualToString:@"comment"]){
            [followingComments addObject:item];
        }
    }
    
    [Answers logCustomEventWithName:@"FollowingPageLoadComplete" customAttributes:@{@"title:":self.title
                                                                             }];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFollowing:) name:@"refreshFollowing" object:nil];

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

/*
- (void) viewDidAppear:(BOOL)animated{
    followingStories = [[NSMutableArray alloc] init];
    followingComments = [[NSMutableArray alloc] init];
    
    NSArray* itemIds = [HackerNewsDBHelper itemsBeingFollowed];
    for (NSString* itemId in itemIds) {
        HackerNewsComment *item = [CommentBuilder getCommentsForCommentID:itemId level:-1];
        
        if([item.type isEqualToString:@"story"]){
            [followingStories addObject:item];
        }else if([item.type isEqualToString:@"comment"]){
            [followingComments addObject:item];
        }
    }
    
    [super viewDidAppear:animated];
    [self.tableView reloadData];

}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0){
        return [NSString stringWithFormat:@"Stories (%@)", @(followingStories.count)];
    }else if(section == 1){
        return [NSString stringWithFormat:@"Comments (%@)", @(followingComments.count)];
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, self.tableView.frame.size.width, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:14];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.backgroundColor = [UIColor lightGrayColor];

    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    return headerView;
}

-(void)refreshFollowing:(NSNotification *) notification {
    
    followingStories = [[NSMutableArray alloc] init];
    followingComments = [[NSMutableArray alloc] init];
    
    NSArray* itemIds = [HackerNewsDBHelper itemsBeingFollowed];
    for (NSString* itemId in itemIds) {
        HackerNewsComment *item = [CommentBuilder getCommentsForCommentID:itemId level:-1];
        item.following = TRUE;
        
        if([item.type isEqualToString:@"story"]){
            [followingStories addObject:item];
        }else if([item.type isEqualToString:@"comment"]){
            [followingComments addObject:item];
        }
    }

    [self.tableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [followingStories count];
            break;
 
        case 1:
            return [followingComments count];
            break;
            
        default:
            break;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    HackerNewsComment * item;
    
    RATableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];

    
    if(indexPath.section == 0){
        item = followingStories[indexPath.row];
        

    }else if(indexPath.section == 1){
        
        item = followingComments[indexPath.row];

        

    }
    
    UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:14.0];
    NSString* commentText = item.text;
    
    commentText = [commentText stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                        font.fontName,
                                                        font.pointSize]];
    
    
    NSInteger childCount = [item.children count];
    if(item.totalChildren != nil && ![item.totalChildren isEqualToString:@"(null)"]){
        childCount = [item.totalChildren integerValue];
    }
    
    NSString * cText = item.text;
    
    if(!item.commentExpanded && [cText length] > 125){
        cText = [cText substringToIndex:125];
        cText = [cText stringByAppendingString:@"  [...]"];
    }
    
    [cell setupWithTitle:cText children:childCount level:item.level additionButtonHidden:childCount <= 0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setIndentationLevel:item.level];
    
    if([item.score isEqualToString:@"(null)"]){
        cell.childComments.text = [NSString stringWithFormat:@"Comments:%@", @(childCount)];
    }else{
        cell.childComments.text = [NSString stringWithFormat:@"Score:%@ \t Comments:%@", item.score, @(childCount) ];

    }
    
    cell.expandCommentsButton.tag = indexPath.row;
    
    
    NSString* byText = @"@";
    
    if(item.updatedBy != nil){
        byText = [byText stringByAppendingString: item.updatedBy];
    }else{
        byText = @"";
    }
    
    [cell.byButton setTitle:byText forState:UIControlStateNormal];
    [cell.byButton setTitleColor:[UIColor pumpkinColor] forState:UIControlStateNormal];
    [cell layoutSubviews];
    
    cell.followButton.tag = indexPath.row << 3 | indexPath.section;
    [cell.followButton setTitle:@" Unfollow" forState:UIControlStateNormal];
    [cell.followButton addTarget:self action:@selector(unfollow:) forControlEvents:UIControlEventTouchUpInside];
    
    //Create an animation with pulsating effect
    CABasicAnimation *theAnimation;
    
    //within the animation we will adjust the "opacity"
    //value of the layer
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    //animation lasts 0.4 seconds
    theAnimation.duration=0.4;
    //and it repeats forever
    theAnimation.repeatCount= 5;
    //we want a reverse animation
    theAnimation.autoreverses=YES;
    //justify the opacity as you like (1=fully visible, 0=unvisible)
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.1];
    
    //Assign the animation to your UIImage layer and the
    //animation will start immediately
    
    if([HackerNewsDBHelper hasUpdated:item]){
        [cell.childComments.layer addAnimation:theAnimation forKey:@"animateOpacity"];
        [cell.byButton.layer addAnimation:theAnimation forKey:@"animateOpacity"];
        [HackerNewsDBHelper update:item];
    }
    
    return cell;
}


-(void)unfollow:(UIButton*) sender{
    NSInteger section = sender.tag & 7;
    NSInteger row = (sender.tag & (~7)) >> 3 ;

    HackerNewsComment* item;
    NSMutableArray* toMutate;
    
    if(section == 0){
        item = followingStories[row];
        toMutate = followingStories;
    }else if(section == 1){
        item = followingComments[row];
        toMutate = followingComments;
    }
    
    NSLog(@"About to follow with id:%@ and text:%@", item.itemID, item.text);
    
    item.following = FALSE;
    
    [HackerNewsDBHelper delete:item];
    
    [toMutate removeObjectAtIndex:row];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RootViewController *view = [[RootViewController alloc] init];
    view.board = self.storyboard;
    
    if(indexPath.section == 0){
        HackerNewsComment * item =  [followingStories objectAtIndex:indexPath.row];
        view.storyID = item.itemID;
        view.story = item;
        
        [self.navigationController pushViewController:view animated:YES];
    }else if(indexPath.section == 1){
        
        HackerNewsComment * item =  [followingComments objectAtIndex:indexPath.row];

        HackerNewsComment * story =  [hackerNewsController getStoryForComment:item];
        view.storyID = story.itemID;
        view.story = story;
        view.commentIdtoExpand = [story.children firstObject];
        view.commentIdtoExpandTo = item;
        
        if([view.commentIdtoExpand isEqual:view.commentIdtoExpandTo]){
            view.commentIdtoExpandTo = nil;
        }
        
        NSLog(@"CommentParent:%@ Comment:%@", view.commentIdtoExpand, view.commentIdtoExpandTo);
        
        [self.navigationController pushViewController:view animated:YES];

    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
