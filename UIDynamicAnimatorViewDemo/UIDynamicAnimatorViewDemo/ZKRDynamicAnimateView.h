//
//  ZKRDynamicAnimateView.h
//  ZAKER
//
//  Created by chars on 16/4/27.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZKRDynamicAnimateViewDelegate <NSObject>

@required
/** 仿真动画退出时调用 */
- (void) dynamicAnimateViewExitTransitionForImageView:(UIImageView *)imageView andMagnitude:(CGFloat)magnitude;
/** 仿真动画还原时调用 */
- (void) dynamicAnimateViewRecoverView;

@end

@interface ZKRDynamicAnimateView : UIView

@property (nonatomic, weak) id<ZKRDynamicAnimateViewDelegate> delegate;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer; /** 拖拽手势 */

- (instancetype) initWithImageView:(UIImageView *)imageView andPoint:(CGPoint)touchPoint;
- (void) dynamicAnimateViewAfterDragGestureEnded:(UIPanGestureRecognizer *)gestureRecognizer;

@end