//
//  EmbeddedCheckoutViewController.m
//  KlarnaCheckoutExampleEmbedded
//
//  Created by Matthew Kiazyk on 2016-12-13.
//  Copyright © 2016 MattKiazyk. All rights reserved.
//

#import "EmbeddedCheckoutViewController.h"
#import <KlarnaCheckout/KlarnaCheckout.h>
#import "KCOCheckoutInfo.h"

@interface EmbeddedCheckoutViewController ()<KCOCheckoutSizingDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkoutHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkoutPlaceholderView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) KCOKlarnaCheckout *checkout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (nonatomic, strong) UIViewController<KCOCheckoutViewControllerProtocol> *checkoutChildViewController;
@property (nonatomic, strong) KCOCheckoutInfo *checkoutInfo;
@end

@implementation EmbeddedCheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createCheckout];
}

- (void)loadCheckout:(KCOCheckoutInfo *)checkoutInfo {
    self.checkoutInfo = checkoutInfo;
    [self.checkout setSnippet:checkoutInfo.snippet];
}

- (void)createCheckout{
    self.checkout = [[KCOKlarnaCheckout alloc] initWithViewController:self redirectURI:[NSURL URLWithString:@"example:///"]];

    self.checkoutChildViewController = [self.checkout checkoutViewController];
    self.checkoutChildViewController.sizingDelegate = self;
    self.checkoutChildViewController.internalScrollDisabled = YES;
    self.checkoutChildViewController.parentScrollView = self.scrollView;
    [self addCheckoutChildViewController:self.checkoutChildViewController];
    [self loadCheckout:self.checkoutInfo]; // reload version
}

- (void)loadCompletionSnippet:(NSString *)snippet {
    [self.checkout setSnippet:snippet];
}

- (void)addCheckoutChildViewController:(UIViewController<KCOCheckoutViewControllerProtocol> *)checkoutViewController {
    [self addChildViewController:checkoutViewController];
    [self.checkoutPlaceholderView addSubview:checkoutViewController.view];
    [checkoutViewController didMoveToParentViewController:self];

    checkoutViewController.view.translatesAutoresizingMaskIntoConstraints = NO;


    NSDictionary *views = @{@"checkoutChildVCView": checkoutViewController.view};

    [self.checkoutPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[checkoutChildVCView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

    [self.checkoutPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[checkoutChildVCView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

#pragma mark - suspend resume

- (void)suspend {
    [self.checkoutChildViewController suspend];
}

- (void)resume {
    [self.checkoutChildViewController resume];
}

#pragma mark - KCOEmbeddableCheckoutSizingDelegate

- (void)checkoutViewController:(id)checkout didResize:(CGSize)size
{
    NSLog(@"resize - %@", @(size.height));
    self.checkoutHeightConstraint.constant = size.height;
    self.contentViewHeight.constant = size.height + 100 +125;

    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraints];
    [self.view setNeedsLayout];
}

#pragma mark - Internals

@end
