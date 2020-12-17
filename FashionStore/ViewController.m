//
//  ViewController.m
//  FashionStore
//
//  Copyright © 2016 Klarna. All rights reserved.
//

#import "ViewController.h"
#import <KlarnaCheckoutSDK/KlarnaCheckout.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) KCOKlarnaCheckout *checkout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addObservers];
    self.title = @"iOS SDK Sample App";
    self.webView.keyboardDisplayRequiresUserAction = NO;
    self.checkout = [[KCOKlarnaCheckout alloc] initWithViewController:self returnURL:[NSURL URLWithString:@"fashionstore://"]];
    [self.checkout setWebView:self.webView];
    [self.checkout notifyViewDidLoad];

    NSURL *url = [NSURL URLWithString:@"https://www.klarna.com/demo/"];
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
    NSDictionary *data = notification.userInfo[KCOSignalDataKey];

    if ([name isEqualToString:@"complete"]) {
        [self handleCompletionUri:[data objectForKey:@"uri"]];
    }
}

- (void)handleCompletionUri:(NSString *)uri{
    if (uri && [uri isKindOfClass:[NSString class]] && uri.length > 0) {
        NSURL *url = [NSURL URLWithString:uri];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

@end
