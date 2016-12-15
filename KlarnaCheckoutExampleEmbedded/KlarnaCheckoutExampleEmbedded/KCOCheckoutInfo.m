//
//  KCOCheckoutInfo.m
//  iOS-Klarna-Checkout-SDK
//
//  Created by Niklas Ström on 09/03/16.
//  Copyright © 2016 Johan Rydenstam. All rights reserved.
//

#import "KCOCheckoutInfo.h"

@interface KCOCheckoutInfo ()

@property (nonatomic, strong) NSString *snippet;
@property (nonatomic, strong) NSURL *url;

@end

@implementation KCOCheckoutInfo

- (instancetype)initWithURL:(NSURL *)url andSnippet:(NSString *)snippet {
    self = [super init];
    if (self) {
        self.url = url;
        self.snippet = snippet;
    }
    return self;
}

@end