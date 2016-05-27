//
//  ZKRDynamicAnimateView.h
//  ZAKER
//
//  Created by chars on 16/4/27.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZKRDynamicAnimateView;

@protocol ZKRDynamicAnimateViewDelegate <NSObject>

@required
/**
 仿真动画即将开始时调用，判断是否可以进行动画。若为NO则不执行拖拽动画效果。
 通过 - (BOOL)dynamicAnimateViewModifyImageView:andOriginalPoint: 方法，
 若传入imageView的frame为empty，则返回NO；为非empty，则返回YES。
 */
- (BOOL)dynamicAnimateViewCanExecAnimate:(ZKRDynamicAnimateView *)dynamicAnimateView;

@optional
/** 仿真动画退出时调用，可添加自定义退场动画。 */
- (void)dynamicAnimateViewExitTransition:(ZKRDynamicAnimateView *)dynamicAnimateView;

/** 仿真动画还原时调用，可添加自定义还原效果。 */
- (void)dynamicAnimateViewRecoverView:(ZKRDynamicAnimateView *)dynamicAnimateView;

@end

@interface ZKRDynamicAnimateView : UIView

@property (nonatomic, weak) id<ZKRDynamicAnimateViewDelegate> delegate;
@property (nonatomic) CGPoint currentAnchorPoint;

/** 图片拖拽手势结束后调用，执行退场动画效果。 */
- (void)dynamicAnimateViewAfterDragGestureEnded:(UIPanGestureRecognizer *)gestureRecognizer;

/** 修改动态操作图的初始点及frame信息。 若能进行动画则修改数据成功，返回YES；否则，不修改任何数据，返回NO */
- (BOOL)dynamicAnimateViewModifyImageView:(UIImageView *)imageView andOriginalPoint:(CGPoint)point;

@end