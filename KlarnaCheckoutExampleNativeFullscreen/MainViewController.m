//
//  ViewController.m
//  KlarnaCheckoutExampleNativeFullscreen
//
//  Created by Andrew Erickson on 2016-12-07.
//  Copyright © 2016 Klarna. All rights reserved.
//

#import "MainViewController.h"
#import "KlarnaCheckout/KlarnaCheckout.h"
#import "KCOCheckoutInfo.h"
#import "KCOSnippetLoader.h"

@interface MainViewController () <KCOSnippetLoaderDelegate>

@property (strong, nonatomic) KCOKlarnaCheckout *checkout;
@property (strong, nonatomic) KCOCheckoutInfo *checkoutInfo;
@property (strong, nonatomic) KCOSnippetLoader *snippetLoader;

@property (weak, nonatomic) IBOutlet UIButton *checkOutButton;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkOutButtonHeighConstraint;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self resetInfo];

    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.klarnacheckout.com"]]];

    self.snippetLoader = [[KCOSnippetLoader alloc] initWithWebView:self.webview];
    self.snippetLoader.delegate = self;
}

- (void)resetInfo {
    self.snippetLoader = nil;
    self.checkoutInfo = nil;
}

#pragma mark - Notifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:KCOSignalNotification object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.userInfo[KCOSignalNameKey];
    NSDictionary *data = notification.userInfo[KCOSignalDataKey];

    NSLog(@"Signal name:%@", name);
    NSLog(@"Args: %@", data);

    if ([name isEqualToString:@"complete"]) {
        NSString *uri = [data objectForKey:@"uri"];
        NSURL *url = [NSURL URLWithString:uri];
        [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)setCheckoutInfo:(KCOCheckoutInfo *)checkoutInfo {
    _checkoutInfo = checkoutInfo;
    NSLog(@"Loaded checkout info: %@", checkoutInfo);
    [self.view layoutIfNeeded];
    self.checkOutButton.enabled = _checkoutInfo != nil;
    self.checkOutButton.hidden = _checkoutInfo == nil;
    
    self.checkOutButtonHeighConstraint.constant = _checkoutInfo == nil ? 0 : 45;
    [self.checkOutButton setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.5 animations:^{
        [self.checkOutButton updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    }];
}

- (void)loadCheckout:(KCOCheckoutInfo *)checkoutInfo {
    [self.checkout setSnippet:checkoutInfo.snippet];
    //[self.checkout setSnippet:[self exampleSnippet]];
}

- (IBAction)checkOut:(id)sender {
    self.checkout = [[KCOKlarnaCheckout alloc] initWithViewController:self redirectURI:[NSURL URLWithString:@"https://google.com"]];

    UIViewController<KCOCheckoutViewControllerProtocol> *standalone = [self.checkout checkoutViewController];
    standalone.title = @"Checkout";

    [standalone setScrollViewContentInset:UIEdgeInsetsMake(0, 0, 49, 0)];

    [self loadCheckout:self.checkoutInfo];

    UINavigationController *popupNav = [[UINavigationController alloc] initWithRootViewController:standalone];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCheckout)];

    standalone.navigationItem.leftBarButtonItem = cancelButton;
    [self.navigationController pushViewController:popupNav animated:YES];
}

- (void)cancelCheckout {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - KCOSnippetLoaderDelegate 
- (void)snippetLoader:(KCOSnippetLoader *)snippetLoader loadedCheckout:(KCOCheckoutInfo *)checkoutInfo {
    self.checkoutInfo = checkoutInfo;
    [self loadCheckout:checkoutInfo];
}

@end
