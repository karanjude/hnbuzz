//
//  ActionViewController.m
//  HNBuzz.PageHandler
//
//  Created by Karan Singh on 1/1/16.
//  Copyright © 2016 Karan Singh. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property(strong,nonatomic)  NSString *urlString;

@property(assign,nonatomic)  BOOL found;
@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *dictionary, NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        NSLog(@"URL: %@", dictionary[@"currentUrl"]);
                        
                    }];
                }];

                
            }
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    UIImageView *imageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.window.bounds.size.width/2 , self.view.window.bounds.size.height/2, 76, 76)];
    UIImage *image = [UIImage imageNamed:@"Icon-76.png"];
    imageHolder.image = image;
    [self.view addSubview:imageHolder];
    
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        
        if(self.found){
            break;
        }
        
        
        for (NSItemProvider *itemProvider in item.attachments) {
            
            if(self.found){
                break;
            }
            
            
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *dictionary, NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        NSDictionary* dict = dictionary [NSExtensionJavaScriptPreprocessingResultsKey];
                        
                        if ([dict[@"currentUrl"] length] != 0) {
                            
                            NSLog(@"URL: %@", dict[@"currentUrl"]);
                            
                            self.urlString = dict[@"currentUrl"];
                            
                            self.found = YES;
                            
                            NSString* urlS = [NSString stringWithFormat:@"hnbuzz://%@", self.urlString];
                            
                            NSURL *url = [NSURL URLWithString:urlS];
                            
                            UIResponder* responder = self;
                            NSLog(@"responder = %@", responder);
                            while ((responder = [responder nextResponder]) != nil)
                            {
                                NSLog(@"about to test if responder = %@ supports", responder);
                                if([responder respondsToSelector:@selector(openURL:)] == YES)
                                {
                                    NSLog(@"about to send msg to responder = %@ with params: %@", responder, url);
                                    
                                    [responder performSelector:@selector(openURL:) withObject:url];
                                    
                                    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
                                    
                                }
                            }
                            
                            
                        }
                        
                    }];
                }];
                
            }
        }

}
    
    
}

@end
