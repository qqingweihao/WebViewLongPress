//
//  UIButton+Block.h
//  ButtonBlock
//
//  Created by zouxu on 13-11-25.
//
//

#import <UIKit/UIKit.h>



@interface NSObject (Hook)
-(void)AddHook:(SEL)original_SEL hookBlk:(id)hookBlk hookSel:(SEL)hookSel typeEncoding:(const char*)typeEncoding;
-(void)AddHook:(SEL)original_SEL hookBlk:(id)hookBlk;
-(SEL)HookSel:(SEL)sel;
-(const char *)TypeEncoding:(SEL)sel;//for add methord
-(BOOL)CanInvok:(SEL)original_SEL hookSel:(SEL)hookSel;
@end



