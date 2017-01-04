//
//  CVWebViewController.h
//  WebViewLongPress
//
//  Created by guoqingwei on 16/6/14.
//  Copyright © 2016年 cvte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSActionSheet.h"

typedef NS_ENUM(NSInteger, SelectItem) {
    SelectItemSaveImage,
    SelectItemQRExtract
};

@interface CVWebViewController : UIViewController <UIWebViewDelegate, FSActionSheetDelegate>

@property (nonatomic, strong) NSURL *url;

@property (weak, nonatomic) IBOutlet UIWebView *webView;


@property(strong, nonatomic)NSString* qrCodeString;
@property(strong, nonatomic)UIImage* image;

@end
