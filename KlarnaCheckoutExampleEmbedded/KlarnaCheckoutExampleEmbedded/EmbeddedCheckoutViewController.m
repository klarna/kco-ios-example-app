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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSectionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSectionHeightConstraint;

@property (strong, nonatomic) KCOKlarnaCheckout *checkout;
@property (strong, nonatomic) UIViewController<KCOCheckoutViewControllerProtocol> *checkoutChildViewController;
@property (strong, nonatomic) NSString *snippet;

@end

@implementation EmbeddedCheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createCheckout];
}

- (void)loadCheckoutSnippet:(NSString *)snippet {
    _snippet = snippet;
    [self.checkout setSnippet:snippet];
}

- (void)createCheckout {
    self.checkout = [[KCOKlarnaCheckout alloc] initWithViewController:self redirectURI:[NSURL URLWithString:@"example:///"]];

    self.checkoutChildViewController = [self.checkout checkoutViewController];
    self.checkoutChildViewController.sizingDelegate = self;
    self.checkoutChildViewController.internalScrollDisabled = YES;
    self.checkoutChildViewController.parentScrollView = self.scrollView;
    [self addCheckoutChildViewController:self.checkoutChildViewController];
    [self loadCheckoutSnippet:self.snippet]; // reload version
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

#pragma mark - KCOEmbeddableCheckoutSizingDelegate

- (void)checkoutViewController:(id)checkout didResize:(CGSize)size {
    self.checkoutHeightConstraint.constant = size.height;
    self.contentViewHeight.constant = size.height + self.topSectionHeightConstraint.constant + self.bottomSectionHeightConstraint.constant;

    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraints];
    [self.view setNeedsLayout];
}

@end
