//
//  ZKRDynamicAnimateView.m
//  ZAKER
//
//  Created by chars on 16/4/27.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import "ZKRDynamicAnimateView.h"

#define FADE_THRESHOLD  1100.0f     //执行退出动画的阈值
#define DEFAULT_SCALE   30.0f       //默认缩放比例
#define MAGNITUDE_SCALE 300.0f      //手指滑动加速度缩放比例
#define EDGE_SCALE      100.0f      //碰撞检测边界距离缩放比例

@interface ZKRDynamicAnimateView ()<UICollisionBehaviorDelegate>
{
    CGRect _originalBounds;
    CGPoint _originalCenter;
    CGPoint _originalTouchPoint;
}

@property (nonatomic) UIImageView *srcImageView; /** 要进行动态动画的源图片视图 */
@property (nonatomic) UIDynamicAnimator *animator; /**  仿真者  */
@property (nonatomic) UIAttachmentBehavior *attachment; /** 吸附仿真 */
@property (nonatomic) UICollisionBehavior *collisionBehavior; /** 碰撞仿真 */
@property (nonatomic) UIPushBehavior *pushBehavior; /** 平移仿真 */
@property (nonatomic) UIImageView *dynamicView; /** 当前操作图片视图 */

@end

@implementation ZKRDynamicAnimateView

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
    }
    return self;
}

- (void)prepareAnimator
{
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    _dynamicView = [[UIImageView alloc] init];
    [self addSubview:_dynamicView];
    
    [self handleDynamicView];
    [self setupAttachmentBehaviourWithAnchorPosition:_originalTouchPoint];
}

- (BOOL)dynamicAnimateViewModifyImageView:(UIImageView *)imageView andOriginalPoint:(CGPoint)point
{
    if ([_delegate respondsToSelector:@selector(dynamicAnimateViewCanExecAnimate:)]) {
        if ([_delegate dynamicAnimateViewCanExecAnimate:self]) {
            _srcImageView = imageView;
            _originalTouchPoint = point;
            [self prepareAnimator];
            return YES;
        }
    }
    return NO;
}

- (void)setCurrentAnchorPoint:(CGPoint)currentAnchorPoint
{
    [_attachment setAnchorPoint:currentAnchorPoint];
}

- (void)handleDynamicView
{
    _srcImageView.hidden = YES;
    _dynamicView.hidden = NO;
    _dynamicView.frame = _srcImageView.frame;
    _dynamicView.image = _srcImageView.image;
    _originalBounds = CGRectMake(0, 0, _srcImageView.frame.size.width, _srcImageView.frame.size.height);
    _originalCenter = _srcImageView.center;
}

- (void)setupAttachmentBehaviourWithAnchorPosition:(CGPoint)anchorPosition
{
    UIOffset offset = UIOffsetMake(anchorPosition.x - _dynamicView.center.x, anchorPosition.y - _dynamicView.center.y);
    if (_attachment && _animator) {
        [_animator removeBehavior:_attachment];
    }
    _attachment = [[UIAttachmentBehavior alloc] initWithItem:_dynamicView offsetFromCenter:offset attachedToAnchor:anchorPosition];
    [_animator addBehavior:_attachment];
}

- (void)dynamicAnimateViewAfterDragGestureEnded:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self];
    // 根据手势触摸点计算出该点对应加速度值. 即根据x轴与y轴算出加速度矢量. 用勾股定理计算向量速度.
    CGFloat magnitude = sqrt(pow((double)velocity.x, 2.0) + pow((double)velocity.y, 2.0));
    [_animator removeAllBehaviors];
    
    if ([self hasRecoverForMagnitude:magnitude]) {
        [self recoverDynamicView];
        return;
    }
    
    CGSize dynamicViewSize = _dynamicView.frame.size;
    // 计算出图片的斜边距离作为碰撞检测的边界距离. 用勾股定理计算斜边长.
    CGFloat edge = sqrt(pow(dynamicViewSize.width, 2.0) + pow(dynamicViewSize.height, 2.0));
    UIEdgeInsets insets = UIEdgeInsetsMake(-edge, -edge, -edge, -edge);
    _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_dynamicView]];
    _collisionBehavior.collisionDelegate = self;
    [_collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:insets];
    [_animator addBehavior:_collisionBehavior];
    
    CGPoint p = [gestureRecognizer locationInView:self];
    CGPoint center = _dynamicView.center;
    UIOffset offset = UIOffsetMake(p.x - center.x, p.y - center.y);
    CGFloat delta = DEFAULT_SCALE - magnitude / MAGNITUDE_SCALE - edge / EDGE_SCALE;
    _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_dynamicView] mode:UIPushBehaviorModeInstantaneous];
    _pushBehavior.pushDirection = CGVectorMake(velocity.x / delta, velocity.y / delta);
    [_pushBehavior setTargetOffsetFromCenter:offset forItem:_dynamicView];
    [_animator addBehavior:_pushBehavior];
    
    [UIView animateWithDuration:0.5f animations:^{
        _dynamicView.alpha = 0;
    }];
    [self performSelector:@selector(exitTransition) withObject:nil afterDelay:0.5f];
}

- (void)exitTransition
{
    [_animator removeAllBehaviors];
    _pushBehavior = nil;
    _collisionBehavior = nil;
    _dynamicView.hidden = YES;
    
    if ([_delegate respondsToSelector:@selector(dynamicAnimateViewExitTransition:)]) {
        [_delegate dynamicAnimateViewExitTransition:self];
    }
}

/** 根据加速度的级别值判断图片是否返回原来的位置 */
- (BOOL)hasRecoverForMagnitude:(CGFloat)magnitude
{
    if (magnitude < FADE_THRESHOLD) {
        return YES;
    }
    return NO;
}

/** 将当前操作图片视图还原到初始位置 */
- (void)recoverDynamicView
{
    [UIView animateWithDuration:0.45f animations:^{
        _dynamicView.bounds = _originalBounds;
        _dynamicView.center = _originalCenter;
        _dynamicView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _srcImageView.hidden = NO;
        _dynamicView.hidden = YES;
        if ([_delegate respondsToSelector:@selector(dynamicAnimateViewRecoverView:)]) {
            [_delegate dynamicAnimateViewRecoverView:self];
        }
    }];
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    [self exitTransition];
}

@end
