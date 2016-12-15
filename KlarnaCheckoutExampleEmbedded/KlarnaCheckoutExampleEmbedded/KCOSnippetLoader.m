//
//  KCOSnippetLoader.m
//  iOS-Klarna-Checkout-SDK
//
//  Created by Niklas Ström on 17/03/16.
//  Copyright © 2016 Johan Rydenstam. All rights reserved.
//

#import "KCOSnippetLoader.h"
#import "KCOCheckoutInfo.h"

#import <JavascriptCore/JavascriptCore.h>

@protocol JavascriptProtocol <JSExport>
- (void)postMessage:(NSString *)parameters;
@end

@interface KCOSnippetLoader () <JavascriptProtocol>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) JSContext *webviewContext;

@end

@implementation KCOSnippetLoader

- (instancetype)initWithWebView:(UIWebView *)webView {
    self = [super init];
    if (self) {
        self.webView = webView;
        // listen to internal KlarnaCheckout notification for when a webview context is created
        // cannot have more than one of these implementations so this is the best we can do.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateContext:) name:@"KCOJavaScriptContextCreateNotification" object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

// Again - We are using internal keys and internal notifications to know that a context has been created
// Because we cannot add webView:didCreateContext:inFrame: on NSObject more than once.
// This is a potential issue for merchants if they are doing this i their project, or in another framework.
- (void)didCreateContext:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    id context = [userInfo objectForKey:@"KCOJavaScriptContextKey"];
    
    if (context && [context isKindOfClass:[JSContext class]]) {
        
        JSContext *jsContext = (JSContext *)context;
        
        NSString* cookie = [NSString stringWithFormat: @"kco_snippet_webview_%lud", (unsigned long)self.webView.hash ];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView stringByEvaluatingJavaScriptFromString: [NSString stringWithFormat: @"var %@ = '%@'", cookie, cookie ]];
            
            if ( [jsContext[cookie].toString isEqualToString: cookie] ) {
                [self configureJSContext:jsContext];
            }
        });
    }
}

#pragma mark - Internals

- (void)configureJSContext:(JSContext *)context
{
    context[@"KCO_HANDSHAKE"] = self;
    context[@"KCO_NATIVE"] = self;
}

#pragma mark - KCONative
- (void)postMessage:(NSString *)message {
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *handshake = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([handshake[@"action"] isEqualToString:@"handshake"]){
        NSString *currentURL = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
        KCOCheckoutInfo *checkoutInfo = [[KCOCheckoutInfo alloc] initWithURL:[NSURL URLWithString:currentURL] andSnippet:handshake[@"snippet"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate snippetLoader:self loadedCheckout:checkoutInfo];
        });
    }
}

@end
