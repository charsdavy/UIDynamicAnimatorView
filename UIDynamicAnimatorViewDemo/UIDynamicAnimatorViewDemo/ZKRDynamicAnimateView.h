//
//  ZKRDynamicAnimateView.h
//  ZAKER
//
//  Created by chars on 16/4/27.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZKRDynamicAnimateViewDelegate <NSObject>

@optional
/** 仿真动画退出时调用，可添加自定义退场动画。 */
- (void) dynamicAnimateViewExitTransition;

/** 仿真动画还原时调用，可添加自定义还原效果。 */
- (void) dynamicAnimateViewRecoverView;

@end

@interface ZKRDynamicAnimateView : UIView

@property (nonatomic, weak) id<ZKRDynamicAnimateViewDelegate> delegate;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer; /** 拖拽手势 */

- (void) dynamicAnimateViewAfterDragGestureEnded:(UIPanGestureRecognizer *)gestureRecognizer;
- (void) dynamicAnimateViewModifyImageView:(UIImageView *)imageView andOriginalPoint:(CGPoint)point;

@end