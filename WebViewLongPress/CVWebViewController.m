//
//  CVWebViewController.m
//  WebViewLongPress
//
//  Created by guoqingwei on 16/6/14.
//  Copyright © 2016年 cvte. All rights reserved.
//

#import "CVWebViewController.h"
#import "CVWebViewController+ImageHelper.h"

@implementation CVWebViewController


#pragma mark - Save image callback
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"Succeed";
    
    if (error) {
        message = @"Fail";
    }
    NSLog(@"save result :%@", message);
}
#pragma mark - FSActionSheetDelegate
- (void)FSActionSheet:(FSActionSheet *)actionSheet selectedIndex:(NSInteger)selectedIndex
{
//    [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='text';"];
    
    switch (selectedIndex) {
        case SelectItemSaveImage:
        {
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        case SelectItemQRExtract:
        {
            NSURL *qrUrl = [NSURL URLWithString:self.qrCodeString];
            //open with safari
            if ([[UIApplication sharedApplication] canOpenURL:qrUrl]) {
                [[UIApplication sharedApplication] openURL:qrUrl];
            }
            // open in inner webview
            //[self.webView loadRequest:[NSURLRequest requestWithURL:qrUrl]];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *urlString = @"mp.weixin.qq.com/s?__biz=MzI2ODAzODAzMw==&mid=2650057120&idx=2&sn=c875f7d03ea3823e8dcb3dc4d0cff51d&scene=0#wechat_redirect";

    self.url = [self cleanURL:[NSURL URLWithString:urlString]];
    
    self.webView.delegate = self;
    
    
    self.webView.touchCB = ^( NSString*__nullable imgUrl, UIImage*__nonnull image, NSString*__nullable qrCodeString){
        
        self.qrCodeString = qrCodeString;
        self.image = image;
        
                FSActionSheet *actionSheet = nil;
        
                if (qrCodeString) {
        
                    actionSheet = [[FSActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                highlightedButtonTitle:nil
                                                     otherButtonTitles:@[@"Save Image", @"Extract QR code"]];
        
                } else {
        
                    actionSheet = [[FSActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                highlightedButtonTitle:nil
                                                     otherButtonTitles:@[@"Save Image"]];
                }
                [actionSheet show];
        
    };
    
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:self.url]];
}


#pragma mark - private methods
- (NSURL *)cleanURL:(NSURL *)url
{
    //If no URL scheme was supplied, defer back to HTTP.
    if (url.scheme.length == 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [url absoluteString]]];
    }
    
    return url;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"start load");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"finish load");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"load fail");
  
}

@end
