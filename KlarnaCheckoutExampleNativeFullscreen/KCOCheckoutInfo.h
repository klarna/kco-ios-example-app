//
//  KCOCheckoutInfo.h
//  iOS-Klarna-Checkout-SDK
//
//  Created by Niklas Ström on 09/03/16.
//  Copyright © 2016 Johan Rydenstam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCOCheckoutInfo : NSObject

@property (nonatomic, readonly) NSString *snippet;
@property (nonatomic, readonly) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url andSnippet:(NSString *)snippet;

@end