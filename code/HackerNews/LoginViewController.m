//
//  LoginViewController.m
//  HackerNews
//
//  Created by Karan Singh on 11/1/15.
//  Copyright (c) 2015 Karan Singh. All rights reserved.
//

#import "LoginViewController.h"
#import "FUIButton.h"
#import "FUITextField.h"
#import "UIFont+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "HackerNewsDBHelper.h"
#import "LMAlertView.h"
#import <Crashlytics/Crashlytics.h>

@interface LoginViewController () <UITextFieldDelegate>

- (IBAction)cancelButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet FUITextField *loginTextField;
@property (weak, nonatomic) IBOutlet FUITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet FUIButton *loginButton;

@property (strong, nonatomic) FUITextField *lField;
@property (strong, nonatomic) FUITextField *pField;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    self.loginTextField.font = [UIFont flatFontOfSize:16];
    self.loginTextField.backgroundColor = [UIColor clearColor];
    self.loginTextField.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.loginTextField.textFieldColor = [UIColor whiteColor];
    self.loginTextField.borderColor = [UIColor orangeColor];
    self.loginTextField.borderWidth = 2.0f;
    self.loginTextField.cornerRadius = 3.0f;
    self.loginTextField.textColor = [UIColor pumpkinColor];
    self.loginTextField.delegate = self;
    self.loginTextField.hidden = YES;

    self.passwordTextField.font = [UIFont flatFontOfSize:16];
    self.passwordTextField.backgroundColor = [UIColor clearColor];
    self.passwordTextField.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.passwordTextField.textFieldColor = [UIColor whiteColor];
    self.passwordTextField.borderColor = [UIColor orangeColor];
    self.passwordTextField.borderWidth = 2.0f;
    self.passwordTextField.cornerRadius = 3.0f;
    self.passwordTextField.textColor = [UIColor pumpkinColor];
    self.passwordTextField.delegate = self;
    self.passwordTextField.hidden = YES;

    self.loginButton.buttonColor = [UIColor whiteColor];
    self.loginButton.shadowColor = [UIColor lightGrayColor];
    self.loginButton.shadowHeight = 3.0f;
    self.loginButton.cornerRadius = 6.0f;
    self.loginButton.backgroundColor = [UIColor pumpkinColor];
    self.loginButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.loginButton setTitleColor:[UIColor pumpkinColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor pumpkinColor] forState:UIControlStateHighlighted];
    self.loginButton.hidden = YES;


    /*
    FUIButton *lbutton = [[FUIButton alloc] init];
    lbutton.frame = CGRectMake(contentView.frame.origin.x + 10, yOffset + 100, 51.0, 32.0);
    lbutton.buttonColor = [UIColor whiteColor];
    lbutton.shadowColor = [UIColor lightGrayColor];
    lbutton.shadowHeight = 3.0f;
    lbutton.cornerRadius = 6.0f;
    lbutton.backgroundColor = [UIColor pumpkinColor];
    lbutton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [lbutton setTitleColor:[UIColor pumpkinColor] forState:UIControlStateNormal];
    [lbutton setTitleColor:[UIColor pumpkinColor] forState:UIControlStateHighlighted];
    [lbutton setTitle:@"Login" forState:UIControlStateNormal];;
    [lbutton setTitle:@"Login" forState:UIControlStateHighlighted];
     */

    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@: Clicked button at index: %li", [alertView class] , (long)buttonIndex);
    
    if(buttonIndex == 1){
        if([HackerNewsDBHelper existsUser]){
            [HackerNewsDBHelper deleteUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNews" object:nil];
            [self.slideoutController switchToControllerTagged:1 andPerformSelector:@selector(loadStories:) withObject:nil];
            [self.slideoutController setBadgeValue:@"" forTag:13];
            

        }else{
            self.loginButtonClicked;
        }
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNews" object:nil];
        [self.slideoutController switchToControllerTagged:1 andPerformSelector:@selector(loadStories:) withObject:nil];
    }
    

}


- (BOOL)textFieldShouldReturn:(FUITextField *)textField {
    //if (textField == self.loginTextField || textField == self.passwordTextField) {
        [textField resignFirstResponder];
        //return NO;
   // }
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([HackerNewsDBHelper Offline]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Offline " message:@"No Internet Connectivity, app offline" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        [alert show];
        
        
        return;
    }

    
    
    NSString* loginString = @"Login";
    
    BOOL userLoggedIn = [HackerNewsDBHelper existsUser];
    NSString* userName;
    NSString* passwd = @"********";
    
    if(userLoggedIn){
        loginString = @"Logout";
        userName = [HackerNewsDBHelper userName];
    }
    
    
    LMAlertView *alertView = [[LMAlertView alloc] initWithTitle:@"HN"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:loginString , nil];
    [alertView setSize:CGSizeMake(270.0, 270.0)];
    
    // Add your subviews here to customise
    UIView *contentView = alertView.contentView;
    contentView.backgroundColor = [UIColor pumpkinColor];
    
    UILabel* titleLabel =  [contentView.subviews objectAtIndex:0];
    titleLabel.textColor = [UIColor whiteColor];
    
    CGFloat yOffset = 50.0;
    
    self.lField = [[FUITextField alloc] init];
    self.lField.frame = CGRectMake(contentView.frame.origin.x + 10, yOffset, contentView.frame.size.width - 20, 50.0);
    self.lField.font = [UIFont flatFontOfSize:16];
    self.lField.backgroundColor = [UIColor orangeColor];
    self.lField.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.lField.textFieldColor = [UIColor whiteColor];
    self.lField.borderColor = [UIColor orangeColor];
    self.lField.borderWidth = 2.0f;
    self.lField.cornerRadius = 3.0f;
    self.lField.textColor = [UIColor pumpkinColor];
    self.lField.delegate = self;
    self.lField.placeholder = @"Username";
    
    
    self.pField = [[FUITextField alloc] init];
    self.pField.frame = CGRectMake(contentView.frame.origin.x + 10, yOffset + 80, contentView.frame.size.width - 20, 50.0);
    
    self.pField.font = [UIFont flatFontOfSize:16];
    self.pField.backgroundColor = [UIColor orangeColor];
    self.pField.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.pField.textFieldColor = [UIColor whiteColor];
    self.pField.borderColor = [UIColor orangeColor];
    self.pField.borderWidth = 2.0f;
    self.pField.cornerRadius = 3.0f;
    self.pField.textColor = [UIColor pumpkinColor];
    self.pField.delegate = self;
    self.pField.placeholder = @"Password";
    self.pField.secureTextEntry = YES;
    
    if(userLoggedIn){
        self.lField.text = userName;
        self.pField.text = passwd;
    }


    [contentView addSubview:self.lField];
    [contentView addSubview:self.pField];
    
    LMModalItemTableViewCell * cell =  [alertView buttonCellForIndex:0];
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor pumpkinColor];
    
    LMModalItemTableViewCell * cell1 =  [alertView buttonCellForIndex:1];
    cell1.backgroundColor = [UIColor whiteColor];
    cell1.textLabel.textColor = [UIColor pumpkinColor];

    [alertView show];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
#define DegreesToRadians(degrees) (degrees * M_PI / 180)
        CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [alertView.superview setTransform:transform];
        
    }


    
}



- (void)loginButtonClicked {
    /*
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://news.ycombinator.com/login?goto=news"];
    
    NSURLQueryItem *acct = [NSURLQueryItem queryItemWithName:@"acct" value:self.loginTextField.text];
    NSURLQueryItem *pw = [NSURLQueryItem queryItemWithName:@"pw" value:self.passwordTextField.text];
    NSURLQueryItem *submit = [NSURLQueryItem queryItemWithName:@"submite" value:@"login"];
 
    components.queryItems = @[ acct, pw, submit ];
    NSURL *url = components.URL;
    
    NSError* error;
    NSURLResponse *response;

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    */
    
    [Answers logCustomEventWithName:@"LoginStarted" customAttributes:@{@"title:":@"Login"}];

    
    NSString *post = [NSString stringWithFormat:@"acct=%@&pw=%@",self.lField.text, self.pField.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",postData.length];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://news.ycombinator.com/login?goto=news"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:YES];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    
    NSArray *cookies =[[NSArray alloc]init];
    cookies = [NSHTTPCookie
               cookiesWithResponseHeaderFields:[HTTPResponse allHeaderFields]
               forURL:[NSURL URLWithString:@"https://news.ycombinator.com/login?goto=news"]];
    
    NSString *cookie = [fields valueForKey:@"Set-Cookie"]; // It is your cookie
    
    NSString* cfduid = nil;
    NSString* user = nil;
    
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"https://news.ycombinator.com/login?goto=news"]])
    {
        
        NSLog(@"name: '%@'\n",   [cookie name]);
        NSLog(@"value: '%@'\n",  [cookie value]);
        NSLog(@"domain: '%@'\n", [cookie domain]);
        NSLog(@"path: '%@'\n",   [cookie path]);
        NSLog(@"version: '%@'\n",   @([cookie version]));
        NSLog(@"expirydate: '%@'\n",   [cookie expiresDate]);

        
        if([[cookie name] isEqualToString:@"__cfduid"]){
            cfduid = [NSString stringWithFormat:@"%@=%@",@"__cfduid",[cookie value]] ;
            
        }else if([[cookie name] isEqualToString:@"user"]){
            user = [NSString stringWithFormat:@"%@=%@",@"user",[cookie value]] ;
        }
        
    }
    
    if(cfduid != nil && user != nil){
        [HackerNewsDBHelper insertUser:cfduid forUserID:user withUserName:self.lField.text];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNews" object:nil];
        [self.slideoutController switchToControllerTagged:1 andPerformSelector:@selector(loadStories:) withObject:nil];
        [self.slideoutController setBadgeValue:@"Logout" forTag:13];
        
        [Answers logCustomEventWithName:@"LoginComplete" customAttributes:@{@"title:":@"Login"}];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Logging In" message:@"Try Logging  Again" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        
        [alert show];

    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButtonClicked:(id)sender {
    [self.slideoutController switchToControllerTagged:1 andPerformSelector:nil withObject:nil];
}
@end
