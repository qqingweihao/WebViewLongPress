//
//  CVWebViewController+ImageHelper.m
//  WebViewLongPress
//
//  Created by guoqingwei on 16/6/14.
//  Copyright © 2016年 cvte. All rights reserved.
//

#import "UIWebView+TouchImage.h"
//#import "SwizzeMethod.h"
#import "RNCachingURLProtocol.h"
#import <objc/runtime.h>
#import "NSObject+Hook.h"





#pragma mark 使用这个宏的时候名字一定要大写

#define DYNAMIC_PROPERTY_INT(TYPE, NAME)            \
DYNAMIC_PROPERTY_INT_GET(TYPE, NAME)                \
DYNAMIC_PROPERTY_INT_SET(TYPE, NAME)

#define DYNAMIC_PROPERTY_INT_GET(TYPE, NAME)            \
static char const * const K_##NAME = #NAME;            \
-(TYPE)NAME{                                           \
NSNumber * num = objc_getAssociatedObject(self,  K_##NAME);      \
return (TYPE)num.intValue;        \
}
#define DYNAMIC_PROPERTY_INT_SET(TYPE, NAME)            \
- (void)set##NAME:(TYPE)NAME{                            \
objc_setAssociatedObject(self,K_##NAME, @(NAME), OBJC_ASSOCIATION_COPY_NONATOMIC);  \
}

#define DYNAMIC_PROPERTY_INT(TYPE, NAME)            \
static char const * const K_##NAME = #NAME;            \
-(TYPE)NAME{                                           \
NSNumber * num = objc_getAssociatedObject(self,  K_##NAME);      \
return (TYPE)num.intValue;        \
}                                                      \
- (void)set##NAME:(TYPE)NAME{                            \
objc_setAssociatedObject(self,K_##NAME, @(NAME), OBJC_ASSOCIATION_COPY_NONATOMIC);  \
}



#define DYNAMIC_PROPERTY(TYPE, NAME, ASSOCIATION)      \
static char const * const K_##NAME = #NAME;            \
-(TYPE)NAME{                                           \
return objc_getAssociatedObject(self,  K_##NAME);      \
}                                                      \
- (void)set##NAME:(TYPE)NAME{                          \
objc_setAssociatedObject(self,K_##NAME, NAME, ASSOCIATION);  \
}

#define DYNAMIC_PROPERTY_STRONG(TYPE, NAME)                         \
DYNAMIC_PROPERTY(TYPE, NAME, OBJC_ASSOCIATION_RETAIN_NONATOMIC)

#define DYNAMIC_PROPERTY_COPY(TYPE, NAME)                           \
DYNAMIC_PROPERTY(TYPE, NAME, OBJC_ASSOCIATION_COPY_NONATOMIC)

#define DYNAMIC_PROPERTY_ASSIGN(TYPE, NAME)                           \
DYNAMIC_PROPERTY(TYPE, NAME, OBJC_ASSOCIATION_ASSIGN)





//typedef NS_ENUM(NSInteger, SelectItem) {
//    SelectItemSaveImage,
//    SelectItemQRExtract
//};

#define iOS7_OR_EARLY ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)

//injected javascript
static NSString *const kTouchJavaScriptString =
        @"document.ontouchstart=function(event){\
            x=event.targetTouches[0].clientX;\
            y=event.targetTouches[0].clientY;\
            document.location=\"myweb:touch:start:\"+x+\":\"+y;};\
        document.ontouchmove=function(event){\
            x=event.targetTouches[0].clientX;\
            y=event.targetTouches[0].clientY;\
            document.location=\"myweb:touch:move:\"+x+\":\"+y;};\
        document.ontouchcancel=function(event){\
            document.location=\"myweb:touch:cancel\";};\
            document.ontouchend=function(event){\
            document.location=\"myweb:touch:end\";};";

static NSString *const kImageJS               = @"keyForImageJS";
static NSString *const kImage                 = @"keyForImage";
static NSString *const kImageQRString         = @"keyForQR";

static const NSTimeInterval KLongGestureInterval = 0.8f;


//@implementation CVWebViewController (ImageHelper)
//-(void)startTouch{
//    
//}
//@end



#import <objc/runtime.h>


//这个是用来记录回调指针的
@interface NSObject (WebViewSelf)
@property(nonatomic, weak)UIWebView* WebViewSelf;
@end
@implementation NSObject (WebViewSelf)
DYNAMIC_PROPERTY_ASSIGN(UIWebView*, WebViewSelf)
@end



static char const * const K_WebViewLongTouchCb;
@implementation UIWebView (ImageHelper)

//+(void)load
//{
//    [super load];
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self hookWebView];
//    });
//}
//
//+ (void)hookWebView
//{
//    SwizzlingMethod([self class], @selector(webViewDidStartLoad:), @selector(sl_webViewDidStartLoad:));
//    SwizzlingMethod([self class], @selector(webView:shouldStartLoadWithRequest:navigationType:), @selector(sl_webView:shouldStartLoadWithRequest:navigationType:));
//    SwizzlingMethod([self class], @selector(webViewDidFinishLoad:), @selector(sl_webViewDidFinishLoad:));
//}

#pragma mark - seter and getter

- (void)setImageJS:(NSString *)imageJS
{
    objc_setAssociatedObject(self, &kImageJS, imageJS, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)imageJS
{
    return objc_getAssociatedObject(self, &kImageJS);
}

- (void)setQrCodeString:(NSString *)qrCodeString
{
    objc_setAssociatedObject(self, &kImageQRString, qrCodeString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)qrCodeString
{
    return objc_getAssociatedObject(self, &kImageQRString);
}

- (void)setImage:(UIImage *)image
{
    objc_setAssociatedObject(self, &kImage, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)image
{
    return objc_getAssociatedObject(self, &kImage);
}

#pragma mark - Save image callback
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"Succeed";
    
    if (error) {
        message = @"Fail";
    }
    NSLog(@"save result :%@", message);
}
//
//#pragma mark - FSActionSheetDelegate
//- (void)FSActionSheet:(FSActionSheet *)actionSheet selectedIndex:(NSInteger)selectedIndex
//{
//    [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='text';"];
//    
//    switch (selectedIndex) {
//        case SelectItemSaveImage:
//        {
//            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        }
//            break;
//        case SelectItemQRExtract:
//        {
//            NSURL *qrUrl = [NSURL URLWithString:self.qrCodeString];
//            //open with safari
//            if ([[UIApplication sharedApplication] canOpenURL:qrUrl]) {
//                [[UIApplication sharedApplication] openURL:qrUrl];
//            }
//            // open in inner webview
//            //[self.webView loadRequest:[NSURLRequest requestWithURL:qrUrl]];
//        }
//            break;
//            
//        default:
//            break;
//    }
//}

#pragma mark - swizing

- (BOOL)sl_webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"myweb"]) {
        
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"touch"]) {
            
            if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"start"]) {
                
                NSLog(@"touch start!");
                
                float pointX = [[components objectAtIndex:3] floatValue];
                float pointY = [[components objectAtIndex:4] floatValue];
                
                NSLog(@"touch point (%f, %f)", pointX, pointY);
                
                NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pointX, pointY];
                
                NSString * tagName = [self stringByEvaluatingJavaScriptFromString:js];
                
                self.imageJS = nil;
                if ([tagName isEqualToString:@"IMG"]) {
                    
                    self.imageJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pointX, pointY];
                    
                }
                
            } else {
                
                if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"move"]) {
                    NSLog(@"you are move");
                } else {
                    if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"end"]) {
                        NSLog(@"touch end");
                    }
                }
            }
        }
        
        if (self.imageJS) {
            NSLog(@"touching image");
        }
        
        return NO;
    }
    
    return YES;
  //  return [self sl_webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)sl_webViewDidStartLoad:(UIWebView *)webView
{
    //Add long press gresture for web view
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = KLongGestureInterval;
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    
//    [self sl_webViewDidStartLoad:webView];
}

- (void)sl_webViewDidFinishLoad:(UIWebView *)webView
{
    //cache manager
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    
    //inject js
    [webView stringByEvaluatingJavaScriptFromString:kTouchJavaScriptString];
    
 //   [self sl_webViewDidFinishLoad:webView];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (![gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    if ([self isTouchingImage]) {
        if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            otherGestureRecognizer.enabled = NO;
            otherGestureRecognizer.enabled = YES;
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - private Method
- (BOOL)isTouchingImage
{
    if (self.imageJS) {
        return YES;
    }
    return NO;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    NSString *imageUrl = [self stringByEvaluatingJavaScriptFromString:self.imageJS];
    
    if (imageUrl) {
        
        NSData *data = nil;
        NSString *fileName = [RNCachingURLProtocol cachePathForURLString:imageUrl];
        
        RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        
        if (cache) {
            NSLog(@"read from cache");
            data = cache.data;
        } else{
            NSLog(@"read from url");
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        }
        
        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            NSLog(@"read fail");
            return;
        }
        self.image = image;
        
        self.touchCB(imageUrl, image, [self isAvailableQRcodeIn:image]);
        
        
        
//        FSActionSheet *actionSheet = nil;
//        
//        if ([self isAvailableQRcodeIn:image]) {
//            
//            actionSheet = [[FSActionSheet alloc] initWithTitle:nil
//                                                      delegate:self
//                                             cancelButtonTitle:@"Cancel"
//                                        highlightedButtonTitle:nil
//                                             otherButtonTitles:@[@"Save Image", @"Extract QR code"]];
//            
//        } else {
//            
//            actionSheet = [[FSActionSheet alloc] initWithTitle:nil
//                                                      delegate:self
//                                             cancelButtonTitle:@"Cancel"
//                                        highlightedButtonTitle:nil
//                                             otherButtonTitles:@[@"Save Image"]];
//        }
//        [actionSheet show];
        
    }
    
}

- (NSString*)isAvailableQRcodeIn:(UIImage *)img
{
    if (iOS7_OR_EARLY) {
        return nil;
    }
    
    //Extract QR code by screenshot
    //UIImage *image = [self snapshot:self.view];
    
    UIImage *image = [self imageByInsetEdge:UIEdgeInsetsMake(-20, -20, -20, -20) withColor:[UIColor lightGrayColor] withImage:img];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{}];
    
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        
        self.qrCodeString = [feature.messageString copy];
        
        NSLog(@"QR result :%@", self.qrCodeString);
        
        return  self.qrCodeString;
    } else {
        NSLog(@"No QR");
        return nil;
    }
}

// you can also implement by UIView category
- (UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.window.screen.scale);
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

// you can also implement by UIImage category
- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color withImage:(UIImage *)image
{
    CGSize size = image.size;
    size.width -= insets.left + insets.right;
    size.height -= insets.top + insets.bottom;
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    CGRect rect = CGRectMake(-insets.left, -insets.top, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (color) {
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CGPathAddRect(path, NULL, rect);
        CGContextAddPath(context, path);
        CGContextEOFillPath(context);
        CGPathRelease(path);
    }
    [image drawInRect:rect];
    UIImage *insetEdgedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return insetEdgedImage;
}

//@end











-(WebViewLongTouchCb)touchCB{
    return objc_getAssociatedObject(self,  &K_WebViewLongTouchCb);
}
-(void)setTouchCB:(WebViewLongTouchCb)touchCB{
    if(touchCB)
        [self hook:(NSObject*)self.delegate];
    else
        [self hook:(NSObject*)nil];
    objc_setAssociatedObject(self, &K_WebViewLongTouchCb, touchCB, OBJC_ASSOCIATION_COPY_NONATOMIC);
}



-(void)hook:(NSObject*)base{
    
    {
        base.WebViewSelf= self;
        SEL changeSEL =@selector(webViewDidStartLoad:);
        SEL hookChangeSEL = [self HookSel:changeSEL];
        void(^block)(NSObject* Self,  UIWebView *scrollView)=  ^(NSObject*  Self, UIWebView *scrollView) {
            BOOL isSuccess = NO;
            @try{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if([Self CanInvok:changeSEL hookSel:hookChangeSEL]){
                    NSMethodSignature* signature1 = [Self methodSignatureForSelector:hookChangeSEL];
                    if (signature1) {
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature1];
                        [invocation setTarget:Self];
                        [invocation setSelector:hookChangeSEL];
                        [invocation setArgument:&scrollView atIndex:2];
                        [invocation invoke];
                        isSuccess = YES;
                    }
                }
#pragma clang diagnostic pop
            }@catch (NSException * e)  {
                isSuccess = NO;
            }@finally {
            }
            UIWebView* SELF =Self.WebViewSelf;
            [SELF sl_webViewDidStartLoad:SELF];
        };
        [base AddHook:changeSEL hookBlk:block hookSel:hookChangeSEL typeEncoding:[self TypeEncoding:@selector(sl_webViewDidStartLoad:)]];
    }
    
    
    {
        base.WebViewSelf= self;
        SEL changeSEL =@selector(webView:shouldStartLoadWithRequest:navigationType:);
        SEL hookChangeSEL = [self HookSel:changeSEL];
        BOOL(^block)(NSObject* Self,  UIWebView *webView, NSURLRequest*request , UIWebViewNavigationType navigationType ) =  ^(NSObject* Self,  UIWebView *webView, NSURLRequest*request , UIWebViewNavigationType navigationType ) {
            BOOL isSuccess = NO;
            @try{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if([Self CanInvok:changeSEL hookSel:hookChangeSEL]){
                    NSMethodSignature* signature1 = [Self methodSignatureForSelector:hookChangeSEL];
                    if (signature1) {
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature1];
                        [invocation setTarget:Self];
                        [invocation setSelector:hookChangeSEL];
                        [invocation setArgument:&webView atIndex:2];
                        [invocation setArgument:&request atIndex:3];
                        [invocation setArgument:&navigationType atIndex:4];
//                        NSString *capitalizedString = @"255";
//                        [invocation setReturnValue:&capitalizedString];
                        [invocation invoke];
                        BOOL returnValue;
                        [invocation getReturnValue:&returnValue];
                        isSuccess = returnValue;
                    }
                }
#pragma clang diagnostic pop
            }@catch (NSException * e)  {
                isSuccess = NO;
            }@finally {
            }
            UIWebView* SELF =Self.WebViewSelf;
            [SELF sl_webView:SELF shouldStartLoadWithRequest:request navigationType:navigationType];
            return isSuccess;
        };
        [base AddHook:changeSEL hookBlk:block hookSel:hookChangeSEL typeEncoding:[self TypeEncoding:@selector(sl_webView:shouldStartLoadWithRequest:navigationType:)]];
    }
    
    
    
    {
        base.WebViewSelf= self;
        SEL changeSEL =@selector(webViewDidFinishLoad:);
        SEL hookChangeSEL = [self HookSel:changeSEL];
        void(^block)(NSObject* Self,  UIWebView *scrollView)=  ^(NSObject*  Self, UIWebView *scrollView) {
            BOOL isSuccess = NO;
            @try{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                if([Self CanInvok:changeSEL hookSel:hookChangeSEL]){
                    NSMethodSignature* signature1 = [Self methodSignatureForSelector:hookChangeSEL];
                    if (signature1) {
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature1];
                        [invocation setTarget:Self];
                        [invocation setSelector:hookChangeSEL];
                        [invocation setArgument:&scrollView atIndex:2];
                        [invocation invoke];
                        isSuccess = YES;
                    }
                }
#pragma clang diagnostic pop
            }@catch (NSException * e)  {
                isSuccess = NO;
            }@finally {
            }
            UIWebView* SELF =Self.WebViewSelf;
            [SELF sl_webViewDidFinishLoad:SELF];
        };
        [base AddHook:changeSEL hookBlk:block hookSel:hookChangeSEL typeEncoding:[self TypeEncoding:@selector(sl_webViewDidFinishLoad:)]];
    }
    
    
  
    //    SwizzlingMethod([self class], @selector(webViewDidStartLoad:), @selector(sl_webViewDidStartLoad:));
    //    SwizzlingMethod([self class], @selector(webView:shouldStartLoadWithRequest:navigationType:), @selector(sl_webView:shouldStartLoadWithRequest:navigationType:));
    //    SwizzlingMethod([self class], @selector(webViewDidFinishLoad:), @selector(sl_webViewDidFinishLoad:));
    
    
}


@end

