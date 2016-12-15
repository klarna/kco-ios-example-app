//
//  HybridCheckoutViewController.m
//  KlarnaCheckoutExampleHybrid
//
//  Created by Matthew Kiazyk on 2016-12-13.
//  Copyright © 2016 MattKiazyk. All rights reserved.
//

#import "HybridCheckoutViewController.h"
#import <WebKit/WebKit.h>
#import <KlarnaCheckout/KlarnaCheckout.h>

@interface HybridCheckoutViewController ()
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) KCOKlarnaCheckout *checkout;
@property (nonatomic, strong) NSURL *checkoutURL;
@end

@implementation HybridCheckoutViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.webView];
    [self setupConstraints];
    [self loadCheckout];
    [self.checkout notifyViewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setup {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.checkoutURL];
    NSDictionary<NSString *, NSString *> *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];

    WKUserContentController* userContentController = WKUserContentController.new;
    WKUserScript * cookieScript = [[WKUserScript alloc]
                                   initWithSource: [NSString stringWithFormat:@"document.cookie = '%@';", headers[@"Cookie"]]
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;
    webViewConfig.userContentController = userContentController;

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    self.webView.isAccessibilityElement = YES;
    self.webView.accessibilityLabel = @"checkout";

    _checkout = [[KCOKlarnaCheckout alloc] initWithViewController:self redirectURI:[NSURL URLWithString:@"example:///"]];
    [_checkout setWebView:self.webView];
}

- (void)setupConstraints {
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webView" : self.webView}]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webView" : self.webView}]];
}

- (void)loadCheckoutURL:(NSURL *)url {
    self.checkoutURL = url;
    if (!self.webView) {
        [self setup];
    }
}

- (void)loadCheckout {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.checkoutURL];
    NSDictionary<NSString *, NSString *> *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.checkoutURL];
    for (NSString *name in headers.allKeys){
        [request addValue:headers[name] forHTTPHeaderField:name];
    }

    [self.webView loadRequest:request];
}
@end
