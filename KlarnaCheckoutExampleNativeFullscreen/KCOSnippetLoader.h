//
//  KCOSnippetLoader.h
//  iOS-Klarna-Checkout-SDK
//
//  Created by Niklas Ström on 17/03/16.
//  Copyright © 2016 Johan Rydenstam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KCOSnippetLoader, KCOCheckoutInfo;
@protocol KCOSnippetLoaderDelegate <NSObject>

- (void)snippetLoader:(KCOSnippetLoader *)snippetLoader loadedCheckout:(KCOCheckoutInfo *)version;

@end

@interface KCOSnippetLoader : NSObject

@property (nonatomic, weak) id<KCOSnippetLoaderDelegate> delegate;
- (instancetype)initWithWebView:(UIWebView *)webView;

@end
