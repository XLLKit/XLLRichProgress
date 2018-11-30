//
//  XLLProgressBar.h
//  XLLRichProgressTest
//
//  Created by 肖乐 on 2018/11/28.
//  Copyright © 2018 iOSCoder. All rights reserved.
//  进度条

#import <UIKit/UIKit.h>

@interface XLLProgressBar : UIView

//开始动画
- (void)startAnimation;
//失败
- (void)failedProcess;
//恢复原状
- (void)resumeOrigin;

@property (nonatomic, assign) CGFloat progress;

@end
