//
//  XLLProgressBar.m
//  XLLRichProgressTest
//
//  Created by 肖乐 on 2018/11/28.
//  Copyright © 2018 iOSCoder. All rights reserved.
//

#import "XLLProgressBar.h"
#import "XLLProgressMsg.h"

typedef NS_ENUM(NSInteger, XLLProgressState) {
    
    XLLProgressStateDefault,   //初始状态
    XLLProgressStateAnimation, //动画状态
    XLLProgressStateProgress,  //进度状态
    XLLProgressStateSuccess,   //完成状态
    XLLProgressStateFailed     //萎缩状态
};

@interface XLLProgressBar () <CAAnimationDelegate>

//当前状态
@property (nonatomic, assign) XLLProgressState state;
//小方框
@property (nonatomic, strong) CAShapeLayer *contentLayer;
//进度layer
@property (nonatomic, strong) CAShapeLayer *progressLayer;
//信息框
@property (nonatomic, strong) XLLProgressMsg *progressMsg;
//定时器
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation XLLProgressBar

#pragma mark - lazy loading
- (CAShapeLayer *)contentLayer
{
    if (_contentLayer == nil)
    {
        _contentLayer = [CAShapeLayer layer];
        //设置layer填充与边框颜色
        _contentLayer.fillColor = [UIColor lightGrayColor].CGColor;
        _contentLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        //设置layer的两端与拐角连接样式
        _contentLayer.lineCap = kCALineCapRound;
        _contentLayer.lineJoin = kCALineJoinRound;
    }
    return _contentLayer;
}

- (CAShapeLayer *)progressLayer
{
    if (_progressLayer == nil)
    {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [UIColor lightGrayColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineJoin = kCALineJoinRound;
        _progressLayer.lineWidth = 4.f;
    }
    return _progressLayer;
}

- (XLLProgressMsg *)progressMsg
{
    if (_progressMsg == nil)
    {
        _progressMsg = [[XLLProgressMsg alloc] init];
    }
    return _progressMsg;
}

- (CADisplayLink *)displayLink
{
    if (_displayLink == nil)
    {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    }
    return _displayLink;
}

#pragma mark - lift circle
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
    [self.layer addSublayer:self.contentLayer];
    [self.layer addSublayer:self.progressLayer];
    [self addSubview:self.progressMsg];
}

#pragma mark - timer
- (void)updateProgress
{
    self.progress += 0.01;
    self.progressMsg.transform = CGAffineTransformMakeTranslation(self.frame.size.width * self.progress, 0);
    //更新progressLayer路径
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    [progressPath moveToPoint:CGPointMake(0, self.frame.size.height * 0.5)];
    [progressPath addLineToPoint:CGPointMake(self.frame.size.width * self.progress, self.frame.size.height * 0.5)];
    [progressPath closePath];
    self.progressLayer.path = progressPath.CGPath;
}

#pragma mark - public method
- (void)startAnimation
{
    if (self.state != XLLProgressStateDefault)
        return;
    self.state = XLLProgressStateAnimation;
    //对各个layer添加动画对象
    [self.progressMsg startAnimation];
    [self startLayerAnimation];
}

- (void)resumeOrigin
{
    if (self.state == XLLProgressStateFailed || self.state == XLLProgressStateSuccess)
    {
        [self.progressMsg resumeOriginIsFailed:(self.state == XLLProgressStateFailed)];
        //恢复方框
        CABasicAnimation *contentAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
        contentAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        contentAnim.duration = XLLAnimationDuration;
        contentAnim.fillMode = kCAFillModeForwards;
        contentAnim.removedOnCompletion = NO;
        [self.contentLayer addAnimation:contentAnim forKey:nil];
        
        //恢复msg的transform
        self.progressMsg.transform = CGAffineTransformIdentity;
        //恢复msg的position
        CABasicAnimation *msgAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        msgAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5)];
        msgAnim.duration = XLLAnimationDuration;
        msgAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        msgAnim.fillMode = kCAFillModeForwards;
        msgAnim.removedOnCompletion = NO;
        [self.progressMsg.layer addAnimation:msgAnim forKey:nil];
        
        //恢复progressLayer
        self.progressLayer.path = [UIBezierPath bezierPath].CGPath;
        [self.progressLayer addAnimation:contentAnim forKey:nil];
        if (self.state == XLLProgressStateFailed)
        {
            CABasicAnimation *progressAnim = [CABasicAnimation animationWithKeyPath:@"position.y"];
            progressAnim.byValue = @(-4.0);
            progressAnim.duration = XLLAnimationDuration;
            progressAnim.fillMode = kCAFillModeForwards;
            progressAnim.removedOnCompletion = NO;
            [self.progressLayer addAnimation:progressAnim forKey:nil];
        }
        
        //进度值设为0
        _progress = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.state = XLLProgressStateDefault;
        });
    }
}

- (void)failedProcess
{
    if (self.state == XLLProgressStateProgress)
    {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.state = XLLProgressStateAnimation;
        //对progressLayer做流水下沉动画
        //分析下沉动画，有两个点
        //1.progressLayer缩小
        //2.progressLayer.y下沉
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 0, 1)];
        CABasicAnimation *yAnim = [CABasicAnimation animationWithKeyPath:@"position.y"];
        yAnim.byValue = @(4.0);
//        yAnim.toValue = @(self.progressLayer.position.y + 4.0);
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = self.progress * 1.5;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        group.animations = @[scaleAnim, yAnim];
        [self.progressLayer addAnimation:group forKey:nil];
        
        //水滴
        CALayer *waterLayer = [CALayer layer];
        waterLayer.frame = CGRectMake(self.progress * self.frame.size.width, self.frame.size.height * 0.5, 2, 0);
        waterLayer.backgroundColor = [UIColor whiteColor].CGColor;
        waterLayer.cornerRadius = 1.0;
        waterLayer.masksToBounds = YES;
        [self.layer addSublayer:waterLayer];
        //水滴加长动画,并下移
        CABasicAnimation *waterAnim1 = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
        waterAnim1.toValue = [NSValue valueWithCGSize:CGSizeMake(2, self.progress * self.frame.size.width)];
        CABasicAnimation *waterAnim2 = [CABasicAnimation animationWithKeyPath:@"position.y"];
        waterAnim2.toValue = @(waterLayer.position.y + 150);
        
        CAAnimationGroup *waterGroup = [CAAnimationGroup animation];
        waterGroup.duration = self.progress * 1.5;
        waterGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        waterGroup.fillMode = kCAFillModeForwards;
        waterGroup.removedOnCompletion = NO;
        waterGroup.animations = @[waterAnim1, waterAnim2];
        //因为waterLayer锚点在中间，所以肯定会以锚点向两边加长，固重新设置锚点
        waterLayer.anchorPoint = CGPointZero;
        [waterLayer addAnimation:waterGroup forKey:nil];
        
        //做msg萎缩动画
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.progressMsg processFailed];
            [waterLayer removeFromSuperlayer];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //确保失败动画完成
            self.state = XLLProgressStateFailed;
        });
    }
}

- (void)startLayerAnimation
{
    //方框动画
    [self startContentLayerAnimation];
    //msg动画
    [self startMsgLayerAnimation];
}

- (void)startContentLayerAnimation
{
    //小方框添加缩放动画
    //当前小方框尺寸 self.layer.height, self.layer.height
    //Width由height->width  Height由height->lineWidth
    CGFloat biliX = CGRectGetWidth(self.layer.frame) / CGRectGetHeight(self.layer.frame);
    CGFloat biliY = 4.f / CGRectGetHeight(self.layer.frame);
    CABasicAnimation *contentScaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    contentScaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(biliX, biliY, 1)];
    contentScaleAnim.duration = XLLAnimationDuration;
    //动画后保持状态
    contentScaleAnim.fillMode = kCAFillModeForwards;
    //后台持续动画
    contentScaleAnim.removedOnCompletion = NO;
    [self.contentLayer addAnimation:contentScaleAnim forKey:nil];
}

- (void)startMsgLayerAnimation
{
    //对msg添加动画组
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    //获取msg的position,不了解position的先了解下锚点
    //position就是重心锚点相对于父layer的位置
    CGPoint msgPosition = self.progressMsg.layer.position;
    [movePath moveToPoint:msgPosition];
    //弹跳一下
    [movePath addLineToPoint:CGPointMake(msgPosition.x, msgPosition.y - 40)];
    //-7是因为使msg的箭头与线在同一水平上
    [movePath addLineToPoint:CGPointMake(msgPosition.x, msgPosition.y - 8)];
    [movePath addLineToPoint:CGPointMake(msgPosition.x + 20, msgPosition.y - 8)];
    [movePath addLineToPoint:CGPointMake(0, msgPosition.y - 8)];
    moveAnim.path = movePath.CGPath;
    moveAnim.duration = 0.9;
    moveAnim.fillMode = kCAFillModeForwards;
    moveAnim.removedOnCompletion = NO;
    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    moveAnim.delegate = self;
    [self.progressMsg.layer addAnimation:moveAnim forKey:XLLProgressMsgAnim];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[self.progressMsg.layer animationForKey:XLLProgressMsgAnim] isEqual:anim])
    {
        //开始
        self.state = XLLProgressStateProgress;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - setter
- (void)setProgress:(CGFloat)progress
{
    //容错，限制progress在0-1之间
    progress = MIN(MAX(progress, 0), 1);
    _progress = progress;
    self.progressMsg.progress = progress;
    
    if (ABS(progress - 1) < 0.000001 && self.state == XLLProgressStateProgress)
    {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.state = XLLProgressStateSuccess;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat msgWH = MIN(self.frame.size.width, self.frame.size.height);
    self.progressMsg.frame = CGRectMake(ABS(self.frame.size.width - self.frame.size.height) * 0.5, 0, msgWH, msgWH);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    //设置方框layer
    self.contentLayer.frame = self.layer.bounds;
    CGFloat contentWH = MIN(self.layer.frame.size.width, self.layer.frame.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(ABS((self.layer.frame.size.width - self.layer.frame.size.height)) * 0.5, 0, contentWH, contentWH) cornerRadius:5.f];
    self.contentLayer.path = path.CGPath;
    
    //设置progressLayer
    self.progressLayer.frame = self.layer.bounds;
}

@end
