//
//  XLLProgressMsg.m
//  XLLRichProgressTest
//
//  Created by 肖乐 on 2018/11/28.
//  Copyright © 2018 iOSCoder. All rights reserved.
//

#import "XLLProgressMsg.h"

@interface XLLProgressMsg ()

//箭头所需的两个layer
@property (nonatomic, strong) CAShapeLayer *sanjiaoLayer;
@property (nonatomic, strong) CAShapeLayer *changfangLayer;
//显示进度百分比
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation XLLProgressMsg

#pragma mark - lazy loading
- (CAShapeLayer *)sanjiaoLayer
{
    if (_sanjiaoLayer == nil)
    {
        _sanjiaoLayer = [CAShapeLayer layer];
        _sanjiaoLayer.fillColor = [UIColor whiteColor].CGColor;
        _sanjiaoLayer.strokeColor = [UIColor whiteColor].CGColor;
        _sanjiaoLayer.lineCap = kCALineCapRound;
        _sanjiaoLayer.lineJoin = kCALineJoinRound;
    }
    return _sanjiaoLayer;
}

- (CAShapeLayer *)changfangLayer
{
    if (_changfangLayer == nil)
    {
        _changfangLayer = [CAShapeLayer layer];
        _changfangLayer.fillColor = [UIColor whiteColor].CGColor;
        _changfangLayer.strokeColor = [UIColor whiteColor].CGColor;
        _changfangLayer.lineCap = kCALineCapRound;
        _changfangLayer.lineJoin = kCALineJoinRound;
    }
    return _changfangLayer;
}

- (UILabel *)progressLabel
{
    if (_progressLabel == nil)
    {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont systemFontOfSize:11.f];
        _progressLabel.textColor = [UIColor purpleColor];
    }
    return _progressLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupBase];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupBase];
    }
    return self;
}

- (void)setupBase
{
    [self.layer addSublayer:self.sanjiaoLayer];
    [self.layer addSublayer:self.changfangLayer];
    [self addSubview:self.progressLabel];
}

#pragma mark - setter
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",100 * progress];
    if (ABS(progress - 1.0) < 0.000001) //浮点型判断相等技巧
    {
        [self finishProcess];
    }
}

- (void)finishProcess
{
    //旋转一波
    self.progressLabel.text = @"done";
    
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnim.toValue = @(M_PI);
    //动画结束后还需要回转，不然文字也会旋转
    rotationAnim.fillMode = kCAFillModeBackwards;
    rotationAnim.removedOnCompletion = NO;
    rotationAnim.duration = 0.2;
    rotationAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.sanjiaoLayer addAnimation:rotationAnim forKey:nil];
    [self.changfangLayer addAnimation:rotationAnim forKey:nil];
    [self.progressLabel.layer addAnimation:rotationAnim forKey:nil];
}

#pragma mark - public method
- (void)startAnimation
{
    self.progressLabel.hidden = NO;
    CABasicAnimation *sanjiaoAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    sanjiaoAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 1)];
    sanjiaoAnim.duration = XLLAnimationDuration;
    sanjiaoAnim.fillMode = kCAFillModeForwards;
    sanjiaoAnim.removedOnCompletion = NO;
    [self.sanjiaoLayer addAnimation:sanjiaoAnim forKey:nil];
    
    CABasicAnimation *changfangAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    changfangAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 0.9, 1)];
    changfangAnim.duration = XLLAnimationDuration;
    changfangAnim.fillMode = kCAFillModeForwards;
    changfangAnim.removedOnCompletion = NO;
    [self.changfangLayer addAnimation:changfangAnim forKey:nil];
}

- (void)processFailed
{
    self.progressLabel.text = @"failed";
    
    //旋转
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.toValue = @(M_PI_4 * 0.4);
    anim.duration = 0.2;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    [self.layer addAnimation:anim forKey:nil];
}

- (void)resumeOriginIsFailed:(BOOL)isFailed
{
    if (isFailed)
    {
        //将self.layer扶正
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        anim.toValue = @(0);
        anim.duration = 0.2;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = NO;
        [self.layer addAnimation:anim forKey:nil];
    }
    self.progressLabel.hidden = YES;
    //恢复原状
    CABasicAnimation *originAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    originAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    originAnim.duration = XLLAnimationDuration;
    originAnim.fillMode = kCAFillModeForwards;
    originAnim.removedOnCompletion = NO;
    [self.sanjiaoLayer addAnimation:originAnim forKey:nil];
    [self.changfangLayer addAnimation:originAnim forKey:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.progressLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 25);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    self.sanjiaoLayer.frame = self.layer.bounds;
    self.changfangLayer.frame = self.layer.bounds;
    
    //设置layer 路径
    CGFloat changfangW = self.layer.frame.size.width * 0.25;
    CGFloat changfangH = self.layer.frame.size.height * 0.25;
    UIBezierPath *changfangPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((self.layer.frame.size.width - changfangW) * 0.5, self.layer.frame.size.height * 0.25, changfangW, changfangH) cornerRadius:1];
    self.changfangLayer.path = changfangPath.CGPath;
    
    CGFloat sanjiaoW = self.layer.frame.size.width * 0.5;
    CGFloat sanjiaoH = self.layer.frame.size.height * 0.25;
    CGPoint startPoint = CGPointMake((self.layer.frame.size.width - sanjiaoW) * 0.5, self.layer.frame.size.height * 0.5);
    UIBezierPath *sanjiaoPath = [UIBezierPath bezierPath];
    [sanjiaoPath moveToPoint:startPoint];
    [sanjiaoPath addLineToPoint:CGPointMake(self.layer.frame.size.width * 0.5, self.layer.frame.size.height - sanjiaoH)];
    [sanjiaoPath addLineToPoint:CGPointMake(startPoint.x + sanjiaoW, startPoint.y)];
    [sanjiaoPath closePath];
    self.sanjiaoLayer.path = sanjiaoPath.CGPath;
}


@end
