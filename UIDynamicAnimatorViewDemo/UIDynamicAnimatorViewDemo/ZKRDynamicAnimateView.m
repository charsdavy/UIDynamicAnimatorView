//
//  ZKRDynamicAnimateView.m
//  ZAKER
//
//  Created by chars on 16/4/27.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import "ZKRDynamicAnimateView.h"

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

- (instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
    }
    return self;
}

- (void) prepareAnimator
{
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    _dynamicView = [[UIImageView alloc] init];
    [self addSubview:_dynamicView];
    
    [self handleDynamicView];
    [self setupAttachmentBehaviourWithAnchorPosition:_originalTouchPoint];
}

- (void)dynamicAnimateViewModifyImageView:(UIImageView *)imageView andOriginalPoint:(CGPoint)point
{
    _srcImageView = imageView;
    _originalTouchPoint = point;
    [self prepareAnimator];
}

- (void)setPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [_attachment setAnchorPoint:[panGestureRecognizer locationInView:self]];
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
    velocity = CGPointMake(velocity.x / 30, velocity.y / 30);
    CGFloat magnitude = (CGFloat)sqrt(pow((double)velocity.x, 2.0) + pow((double)velocity.y, 2.0));
    CGPoint p = [gestureRecognizer locationInView:self];

    [_animator removeAllBehaviors];
    
    if ([self hasRecoverForMagnitude:magnitude]) {
        [self recoverDynamicView];
        return ;
    }
    
    _collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_dynamicView]];
    _collisionBehavior.collisionDelegate = self;
    CGFloat diagonal = -sqrt(pow(CGRectGetWidth(_dynamicView.frame), 2.0) + pow(CGRectGetHeight(_dynamicView.frame), 2.0));
    UIEdgeInsets insets = UIEdgeInsetsMake(diagonal, diagonal, diagonal, diagonal);
    [_collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:insets];
    [_animator addBehavior:_collisionBehavior];
    
    _pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_dynamicView] mode:UIPushBehaviorModeInstantaneous];
    CGPoint center = _dynamicView.center;
    UIOffset offset = UIOffsetMake((p.x - center.x) / 2.0, (p.y - center.y) / 2.0);
    [_pushBehavior setTargetOffsetFromCenter:offset forItem:_dynamicView];
    _pushBehavior.pushDirection = CGVectorMake(velocity.x, velocity.y);
    [_animator addBehavior:_pushBehavior];
}

- (void)exitTransition
{
    if ([_delegate respondsToSelector:@selector(dynamicAnimateViewExitTransition)]) {
        [_delegate dynamicAnimateViewExitTransition];
    }
}

/** 根据加速度的级别值判断图片是否返回原来的位置 */
- (BOOL)hasRecoverForMagnitude:(CGFloat)magnitude
{
    if (magnitude < 30) {
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
        if ([_delegate respondsToSelector:@selector(dynamicAnimateViewRecoverView)]) {
            [_delegate dynamicAnimateViewRecoverView];
        }
    }];
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    [_animator removeAllBehaviors];
    _pushBehavior = nil;
    _collisionBehavior = nil;
    _dynamicView.hidden = YES;
    [self exitTransition];
}

@end
