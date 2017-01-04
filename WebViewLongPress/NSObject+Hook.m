//
//  UIButton+Block.m
//  ButtonBlock
//
//  Created by zouxu on 13-11-25.
//
//

#import "NSObject+Hook.h"
#import <objc/runtime.h>






@implementation NSObject (Hook)

#if 0
{
    SEL changeSEL =@selector(scrollViewWillBeginDragging:);
    SEL hookChangeSEL = [self HookSel:changeSEL];
    void(^block)(id Self,  UIScrollView *scrollView)=  ^(id Self, UIScrollView *scrollView) {
        BOOL isSuccess = NO;
        @try{
            if([Self CanInvok:changeSEL hookSel:hookChangeSEL]){
                NSMethodSignature* signature1 = [Self methodSignatureForSelector:hookChangeSEL];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature1];
                [invocation setTarget:Self];
                [invocation setSelector:hookChangeSEL];
                [invocation setArgument:&scrollView atIndex:2];
                [invocation invoke];
                isSuccess = YES;
            }
        }@catch (NSException * e)  {
            isSuccess = NO;
            //     NSLog(@"ecstion: %@", e);
        }@finally {
        }
        [SELF scrollViewWillBeginDragging:scrollView];
    };
    [base AddHook:changeSEL hookBlk:block hookSel:hookChangeSEL typeEncoding:[self TypeEncoding:changeSEL]];
}
#endif


-(SEL)HookSel:(SEL)changeSEL{
    SEL hookChangeSEL =NSSelectorFromString([NSString stringWithFormat:@"hook_%@", NSStringFromSelector(changeSEL) ]);
    return hookChangeSEL;
}

-(const char *)TypeEncoding:(SEL)sel{
    Method originalMethod = class_getInstanceMethod([self class], sel);
    return method_getTypeEncoding(originalMethod);
}

-(BOOL)CanInvok:(SEL)original_SEL hookSel:(SEL)hookSel{
    IMP originalMethod = class_getMethodImplementation([self class], original_SEL);
    IMP hookMethod = class_getMethodImplementation([self class], hookSel);
    id originalId= imp_getBlock(originalMethod);
    id hookId = imp_getBlock(hookMethod);
    return originalId != hookId;
}


-(void)AddHook:(SEL)originalSelector hookBlk:(id)hookBlk{
    
    Class class = [self class];
    SEL swizzledSelector =NSSelectorFromString([NSString stringWithFormat:@"hook_%@", NSStringFromSelector(originalSelector)]);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    const char* typeEncoding = method_getTypeEncoding(originalMethod);
    IMP hookIMP = imp_implementationWithBlock(hookBlk);
    
    
    //如果delegate没有重载了这个方法
    //1添加tag函数，方便下次重入的时候做判断。并且加入自己的函数
    //2如果发现了上次加入的tag函数，直接replace就ok了
    SEL delegateNotOver_tag =NSSelectorFromString([NSString stringWithFormat:@"delegate_not_overrid_tag_%@", NSStringFromSelector(originalSelector)]);
    IMP delegateNotOver_imp = class_getMethodImplementation([self class], delegateNotOver_tag);
    id delegateId= imp_getBlock(delegateNotOver_imp);
    if(delegateId){
        BOOL replaceSuc = class_replaceMethod(class, originalSelector,hookIMP,typeEncoding);
        NSLog(@"delete not override, replace: %d", replaceSuc);
        return;
    }else if(!originalMethod && !swizzledMethod){
        IMP tagIMP = imp_implementationWithBlock(hookBlk);
        BOOL didTagMethod = class_addMethod(class, delegateNotOver_tag,tagIMP,typeEncoding);
        BOOL didAddMethod = class_addMethod(class, originalSelector,hookIMP,typeEncoding);
        NSLog(@"delete not override, add tag: %d, add orginal: %d", didTagMethod,didAddMethod );
        return;
    }
    
    //因为别人的函数替换，在load里面就替换一次，所以可以那样搞。但是我们这个可以来回替换。所以需要判断以前的东西
    //这是不同的地方
    IMP aleardySwizze_imp = class_getMethodImplementation([self class], originalSelector);
    id aleardySwizze_impid= imp_getBlock(aleardySwizze_imp);
    if(aleardySwizze_impid){
        //说明已经加入这个函数，并且已经swizze
        BOOL replaceSuc = class_replaceMethod(class, originalSelector,hookIMP,typeEncoding);
        NSLog(@"replaceSuc: %d", replaceSuc);
        return;
    }
    
    //如果delegate已经重载了这个方法，那就exchange。
    BOOL didAddMethod = class_addMethod(class, swizzledSelector,hookIMP,typeEncoding);
    if (!didAddMethod) {
        //因为swizzle已经存在，既然存在，当然它已经swizz了，它的sel就是original的sel
        BOOL replaceSuc = class_replaceMethod(class, originalSelector,hookIMP,typeEncoding);
        NSLog(@"replaceSuc: %d", replaceSuc);
    } else {
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
        NSLog(@"exchange");
    }
}





-(void)AddHook:(SEL)original_SEL hookBlk:(id)hookBlk hookSel:(SEL)hookSel typeEncoding:(const char*)typeEncoding{
    
    Class originalClass = [self class];
    //exchange
    Method originalMethod = class_getInstanceMethod(originalClass, original_SEL);
    
    IMP newIMP = imp_implementationWithBlock(hookBlk);
    if(originalMethod){//如果以前有这个函数，需要判断是自己加进去的还是本来就是原来的
            BOOL originalFunIsBlkNeedReplace = imp_getBlock(class_getMethodImplementation([self class], original_SEL)) != 0;
        if(originalFunIsBlkNeedReplace){//如果是自己加进去的，就需要replace
            BOOL addOk = class_replaceMethod(originalClass, original_SEL,newIMP,typeEncoding);
            NSLog(@"org replace: %d", addOk);
        }
    }else{//如果原来没有，就自己加进去
        BOOL addOk = class_addMethod(originalClass, original_SEL,newIMP,typeEncoding);
        NSLog(@"org add: %d", addOk);
    }
    originalMethod = class_getInstanceMethod(originalClass, original_SEL);
    
    assert(originalMethod);
    Method hookMethod = class_getInstanceMethod(originalClass, hookSel);
    
    IMP hookIMP = imp_implementationWithBlock(hookBlk);
    const char * typeEncodin2g =method_getTypeEncoding(originalMethod);
    if(hookMethod){//如果以前有了就replace
        BOOL replaceSuc = class_replaceMethod(originalClass, hookSel,hookIMP,typeEncodin2g);
        NSLog(@"hook replace: %d", replaceSuc);
    }else{//没有就加上
        BOOL addSuc = class_addMethod(originalClass, hookSel,hookIMP,typeEncodin2g);
        NSLog(@"hook add: %d", addSuc);
    }
    hookMethod = class_getInstanceMethod(originalClass, hookSel);
    assert(hookMethod);
    method_exchangeImplementations(originalMethod, hookMethod);
}
@end






