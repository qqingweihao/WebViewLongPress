//
//  CVWebViewController+ImageHelper.h
//  WebViewLongPress
//
//  Created by guoqingwei on 16/6/14.
//  Copyright © 2016年 cvte. All rights reserved.
//

#import "CVWebViewController.h"

typedef  void(^WebViewLongTouchCb)( NSString*__nullable imgUrl, UIImage*__nonnull image, NSString*__nullable qrCodeString);
@interface UIWebView (ImageHelper)<UIWebViewDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, copy, nullable) WebViewLongTouchCb touchCB;
@end

