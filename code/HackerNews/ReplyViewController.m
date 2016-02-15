//
//  ReplyViewController.m
//  
//
//  Created by Karan Singh on 10/30/15.
//
//

#import "ReplyViewController.h"
#import "FUIButton.h"
#import "FUITextField.h"
#import "UIFont+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "HackerNewsDBHelper.h"
#import "LMAlertView.h"
#import "IQKeyboardManager.h"
#import "HackerNewsController.h"

@interface ReplyViewController ()<UITextViewDelegate,UIAlertViewDelegate>{
    HackerNewsController* _hackerNewsController;
    NSString* _postString;
}

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) UITextView * lField;
@property (strong, nonatomic) LMModalItemTableViewCell * cancel;
@property (strong, nonatomic) LMModalItemTableViewCell * done;
@property (strong, nonatomic) LMAlertView * alertView;
@property (strong, nonatomic) LMAlertView * alertView1;


@end

@implementation ReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _hackerNewsController = [[HackerNewsController alloc] init];
    
    if(self.isStory){
        _postString = [_hackerNewsController getCommentUrlForStory:self.item.itemID];
    }else{
        _postString = [_hackerNewsController getCommentUrlForCommentId:self.item.itemID withStory:self.story];
    }
    
    NSLog(@"postString: %@", _postString);
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarByPosition];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tap: (id) sender {
        [[self lField] endEditing: YES];
    
}


-(void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    self.alertView.transform =  CGAffineTransformMakeTranslation(0, 0);
    [UIView commitAnimations];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self.lField resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([HackerNewsDBHelper Offline]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Offline " message:@"No Internet Connectivity, app offline" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        [alert show];
        
        
        return;
    }

    if(![HackerNewsDBHelper LoggedIn]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Logged Into Hacker News" message:@"Please Login To Leave Comments" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        [alert show];
        
        //[self.slideoutController switchToControllerTagged:13 andPerformSelector:nil withObject:nil];
        
        return ;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.alertView = [[LMAlertView alloc] initWithTitle:@"Comments"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Done" , nil];

    [self.alertView setSize:CGSizeMake(300.0, 350.0)];
    
    
    
    // Add your subviews here to customise
    UIView *contentView = self.alertView.contentView;
    contentView.backgroundColor = [UIColor darkGrayColor];
    
    CGFloat yOffset = 50.0;
    
    self.lField = [[UITextView alloc] init];
    self.lField.scrollEnabled = YES;
    
    self.lField.frame = CGRectMake(contentView.frame.origin.x + 10, yOffset, contentView.frame.size.width - 20, 250.0);
    self.lField.font = [UIFont flatFontOfSize:16];
    self.lField.backgroundColor = [UIColor whiteColor];
    self.lField.textColor = [UIColor darkGrayColor];
    self.lField.delegate = self;
    
    
    [contentView addSubview:self.lField];
    
    self.cancel =  [self.alertView buttonCellForIndex:0];
    self.cancel.backgroundColor = [UIColor whiteColor];
    self.cancel.textLabel.textColor = [UIColor lightGrayColor];
    self.cancel.tag = 0;
    
    self.done =  [self.alertView buttonCellForIndex:1];
    self.done.backgroundColor = [UIColor whiteColor];
    self.done.textLabel.textColor = [UIColor lightGrayColor];
    self.done.tag = 1;
    
    UILabel* titleLabel =  [contentView.subviews objectAtIndex:0];
    titleLabel.textColor = [UIColor whiteColor];
    
    //UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
    //                                  initWithTarget:self action:@selector(tap:)];
    //[contentView addGestureRecognizer: tapRec];

    //[self.lField becomeFirstResponder];
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    numberToolbar.barStyle = UIBarStyleBlack;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(tap:)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(tap:)],
                           nil];
    [numberToolbar sizeToFit];
    self.lField.inputAccessoryView = numberToolbar;
    
    CGRect frame = self.alertView.frame;
    frame.origin.y = 5;
    
    self.alertView.frame = frame;
    
    
    [self.alertView show];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        #define DegreesToRadians(degrees) (degrees * M_PI / 180)
        CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [self.alertView.superview setTransform:transform];
        
    }
    
 
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@: Clicked button at index: %li", [alertView class] , (long)buttonIndex);
    
    if(buttonIndex == 1){
        
        
        self.alertView1 = [[LMAlertView alloc] initWithTitle:@"Commenting ..."
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil , nil];
        [self.alertView1 setSize:CGSizeMake(270.0, 60.0)];
        
        // Add your subviews here to customise
        UIView *contentView = self.alertView1.contentView;
        contentView.backgroundColor = [UIColor darkGrayColor];
        
        UILabel* titleLabel =  [contentView.subviews objectAtIndex:0];
        titleLabel.textColor = [UIColor whiteColor];
        
        [self.alertView1 show];
        
        UIViewController* parent = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            NSString* text = self.lField.text;
            
            // TODO: fix comment error
            if([_postString isEqualToString:@"(null)"]){
                return;
            }
            
            _postString = [NSString stringWithFormat:@"%@text=%@ - |via http://bit.ly/hnbuzz01 |", _postString, text ];
            
            NSLog(@"%@", _postString);
            
            NSData *postData = [_postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            
            //NSLog(@"POST Data: %@", postData);
            
            NSString *postLength = [NSString stringWithFormat:@"%d",postData.length];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            NSURL* url;
            NSString* itemUrl = [NSString stringWithFormat:@"https://news.ycombinator.com/comment"];
            url = [NSURL URLWithString:itemUrl];
            
            NSString* cookie = [HackerNewsDBHelper userCookieString];
            
            [request addValue:cookie forHTTPHeaderField:@"Cookie"];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            [request setHTTPShouldHandleCookies:YES];
            
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&response
                                                              error:&error];
            
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.alertView removeFromSuperview];
                    [self.alertView1 removeFromSuperview];
                    [parent dismissViewControllerAnimated:YES completion:nil];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Posting Comment" message:@"Try Commenting Again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
                    
                    [alert show];
                    
                });
            }
            
        });

    }else{
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    
    NSLog(@"Response Code: %@", @([HTTPResponse statusCode]));
    [self.alertView1 removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)cancelReply:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
