//
//  ViewController.m
//  KlarnaCheckoutExampleNativeFullscreen
//
//  Created by Andrew Erickson on 2016-12-07.
//  Copyright © 2016 Klarna. All rights reserved.
//

#import "ViewController.h"
#import "KlarnaCheckout/KlarnaCheckout.h"

@interface ViewController ()

@property (strong, nonatomic) KCOKlarnaCheckout *checkout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.checkout = [[KCOKlarnaCheckout alloc] initWithViewController:self redirectURI:[NSURL URLWithString:@"http://www.google.ca"]];
    
    UIViewController<KCOCheckoutViewControllerProtocol> *viewController = [self.checkout checkoutViewController];
    [self.navigationController pushViewController:viewController animated:NO];
    [self.checkout setSnippet:@""];
}

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.userInfo[KCOSignalNameKey];
    NSDictionary *data = notification.userInfo[KCOSignalDataKey];
    
    if ([name isEqualToString:@"complete"]) {
        NSString *uri = [data objectForKey:@"uri"];
        if (uri && [uri isKindOfClass:[NSString class]] && uri.length > 0) {
            NSURL *confirmationURL = [NSURL URLWithString:uri];
            
        }
    }
}

@end
