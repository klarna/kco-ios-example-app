//
//  ViewController.m
//  FashionStore
//
//  Created by Niklas Ström on 20/01/16.
//  Copyright © 2016 Klarna. All rights reserved.
//

#import "ViewController.h"
#import <iOSKlarnaCheckoutSDK/KCOCheckoutController.h>
#import <iOSKlarnaCheckoutSDK/KCOConstants.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) KCOCheckoutController *checkout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObservers];
    self.title = @"iOS SDK Sample App";
    self.webView.keyboardDisplayRequiresUserAction = NO;
    self.checkout = [[KCOCheckoutController alloc] initWithViewController:self];
    [self.checkout attachWebView:self.webView];
    [self.checkout notifyViewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://www.klarnacheckout.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - Internals

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:KCOSignalNotification object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification
{
    NSString *name = notification.userInfo[KCOSignalNameKey];
    NSArray *args = notification.userInfo[KCOSignalArgsKey];
    
    if ([name isEqualToString:@"complete"]) {
        NSDictionary *argsDict = [args objectAtIndex:0];
        if (argsDict && [argsDict isKindOfClass:[NSDictionary class]]) {
            [self handleCompletionUri:[argsDict objectForKey:@"uri"]];
        }
    }
}

- (void)handleCompletionUri:(NSString *)uri{
    if (uri && [uri isKindOfClass:[NSString class]] && uri.length > 0) {
        NSURL *url = [NSURL URLWithString:uri];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}


@end
