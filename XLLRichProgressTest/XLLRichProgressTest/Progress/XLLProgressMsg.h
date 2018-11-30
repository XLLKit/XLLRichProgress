//
//  XLLProgressMsg.h
//  XLLRichProgressTest
//
//  Created by 肖乐 on 2018/11/28.
//  Copyright © 2018 iOSCoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLLProgressMsg : UIView

@property (nonatomic, assign) CGFloat progress;

- (void)startAnimation;
- (void)processFailed;
- (void)resumeOriginIsFailed:(BOOL)isFailed;

@end
