//
//  EmbeddedCheckoutViewController.h
//  KlarnaCheckoutExampleEmbedded
//
//  Created by Matthew Kiazyk on 2016-12-13.
//  Copyright © 2016 MattKiazyk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KCOCheckoutInfo;

@interface EmbeddedCheckoutViewController : UIViewController
- (void)loadCheckoutSnippet:(NSString *)snippet;
@end
