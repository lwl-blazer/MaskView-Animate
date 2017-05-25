//
//  UIView+BLFadeAnimation.h
//  MaskViewAnimateDemo
//
//  Created by blazer on 16/8/24.
//  Copyright © 2016年 blazer. All rights reserved.
//  UIView的渐变隐藏动画

#import <UIKit/UIKit.h>

#define BLMAXDURATION 1.2
#define BLMINDURATION 0.2
#define BLMULTIPLED 0.25

@interface UIView (BLFadeAnimation)

//视图是否隐藏
@property(nonatomic, assign, readonly) BOOL isFade;

//是否处在动画中
@property(nonatomic, assign, readonly) BOOL isFading;

//垂直方块个数 默认为3
@property(nonatomic, assign) NSInteger verticalCount;

//水平方块个数 默认为18
@property(nonatomic, assign) NSInteger horizontalCount;

//方块动画之间的间隔 0.2-1.2  默认0.7
@property(nonatomic, assign) NSTimeInterval intervalDuration;

//每个方块隐藏的动画时间 0.05-0.3 最多为动画时长的25% 默认是0.185
@property(nonatomic, assign) NSTimeInterval fadeAnimationDuration;


- (void)configurateWithVerticalCount:(NSInteger)verticalCount
                     horizontalCount:(NSInteger)horizontalCount
                            interval:(NSTimeInterval)interval
                            duration:(NSTimeInterval)duration;

- (void)reverseWithComplete:(void(^)(void))complete;

- (void)animateFadeWithComplete:(void(^)(void))complete;

- (void)reverseWithoutAnimate;

@end
