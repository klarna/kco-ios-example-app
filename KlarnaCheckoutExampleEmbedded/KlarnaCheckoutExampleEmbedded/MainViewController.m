//
//  ViewController.m
//  KlarnaCheckoutExampleEmbedded
//
//  Created by Matthew Kiazyk on 2016-12-13.
//  Copyright © 2016 MattKiazyk. All rights reserved.
//

#import "MainViewController.h"
#import "KlarnaCheckout/KlarnaCheckout.h"
#import "KCOCheckoutInfo.h"
#import "KCOSnippetLoader.h"
#import "EmbeddedCheckoutViewController.h"

@interface MainViewController () <KCOSnippetLoaderDelegate>

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
    [self addObservers];

    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.klarnacheckout.com"]]];

    self.snippetLoader = [[KCOSnippetLoader alloc] initWithWebView:self.webview];
    self.snippetLoader.delegate = self;
}

- (void)resetInfo {
    self.snippetLoader.delegate = nil;
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
        // don't let snippet get called again
        [self resetInfo];

        NSString *uri = [data objectForKey:@"uri"];
        NSURL *url = [NSURL URLWithString:uri];
        [self.webview loadRequest:[NSURLRequest requestWithURL:url]];

        // close original popup Checkout Controller
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showHideCheckoutButton {
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

- (void)setCheckoutInfo:(KCOCheckoutInfo *)checkoutInfo {
    _checkoutInfo = checkoutInfo;
    [self showHideCheckoutButton];
}

- (IBAction)checkOut:(id)sender {

    EmbeddedCheckoutViewController *embedded = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EmbeddedView"];

    [embedded loadCheckoutSnippet:_checkoutInfo.snippet];

    UINavigationController *popupNav = [[UINavigationController alloc] initWithRootViewController:embedded];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCheckout)];

    embedded.navigationItem.leftBarButtonItem = cancelButton;

    [self.navigationController presentViewController:popupNav animated:YES completion:nil];
}

- (void)cancelCheckout {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - KCOSnippetLoaderDelegate
- (void)snippetLoader:(KCOSnippetLoader *)snippetLoader loadedCheckout:(KCOCheckoutInfo *)checkoutInfo {
    self.checkoutInfo = checkoutInfo;
}

@end
