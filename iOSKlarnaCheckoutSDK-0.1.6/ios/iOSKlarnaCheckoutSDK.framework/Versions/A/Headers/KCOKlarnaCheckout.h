//
//  KCOKlarnaCheckout.h
//  Pods
//
//  Created by Johan Rydenstam on 11/11/15.
//
//

#import <Foundation/Foundation.h>

#import <iOSKlarnaCheckoutSDK/KCOCheckoutViewControllerProtocol.h>

@interface KCOKlarnaCheckout : NSObject

@property (nonatomic, strong) NSString *snippet;
@property (nonatomic, readonly) UIViewController<KCOCheckoutViewControllerProtocol> *checkoutViewController;


@end
