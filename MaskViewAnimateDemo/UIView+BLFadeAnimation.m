//
//  UIView+BLFadeAnimation.m
//  MaskViewAnimateDemo
//
//  Created by blazer on 16/8/24.
//  Copyright © 2016年 blazer. All rights reserved.
//

#import "UIView+BLFadeAnimation.h"
#import <objc/runtime.h>

/*
 * 修饰指针
 * const int *A; 或 int const *A;  //const修饰指向的对象，A可变，A指向的对象不可变
 * int *const A;   //const修饰指针A A不可变，A指向的对象可变
 * const int *const A;    //指针A和A指向的对象都不可变
 * 例如：
 * const int *r = &x;   //声明r为一个指向常量的x的指针，r指向的对象不能被修改，但他可以指向任何地址的常量
 * 
 * pointer const 可以指定普通变量，用改指针不能修改它指向的对象，并不表示指向的对象是const不能被改变，例如：
 * int i = 10;
 * const int *p = &i;
 * i = 11;   //wrong
 * *p = 11;  //correct
 */

const void * kIsFadeKey = &kIsFadeKey;
const void * kIsAnimatingKey = &kIsAnimatingKey;
const void * kVerticalCountKey = &kVerticalCountKey;
const void * kHorizontalCountKey = &kHorizontalCountKey;
const void * kIntervalDurationKey = &kIntervalDurationKey;
const void * kAnimationDurationKey = &kAnimationDurationKey;


static NSInteger kMaskViewTag = 0x1000000;

@implementation UIView (BLFadeAnimation)

/*
 在category中声明的所有属性编译器都不会自动绑定getter和setter方法，所以需要重写，而且不能使用下划线+变量名的方式直接访问变量，解决的方法：导入objc/runtime.h文件使用动态时提供的objc_associateObject机制来为视图动态增加属性
 三个函数:
 objc_setAssociatedObject 用于给对象添加关联对象，传入nil则可以移除已有的关联对象
 objc_getAssociatedObject 用于获取关联对象
 objc_removeAssociatedObject 用于移除一个对象的所有关联对象。    //这个函数会移除一个对象的所有关联对象，将该对象恢复成原始状态。这样做有时候会把别人所添加的也一并移除了，通常的错误是objc_setAssociatedObject函数传入nil来移除某个已有的关联对象
 五种关联策略：
 关联策略                                   等价属性                                               说明
 OBJC_ASSOCIATION_ASSIGN               @property(assign)or@property(unsafe_unretained)      弱引用关联对象
 OBJC_ASSOCIATION_RETAIN_NONATOMIC     @property(strong, nonatomic)                         强引用关联对象，且为非原子操作
 OBJC_ASSOCIATION_COPY_NONATOMIC       @property(copy, nonatomic)                           复制关联对象，且为非原子操作
 OBJC_ASSOCIATION_RETAIN               @property(strong, atomic)                           强引用关联对象，且为原子操作
 OBJC_ASSOCIATION_COPY                 @property(copy, atomic)                             复制关联对象，且为原子操作
 */
#pragma mark --setter&getter
- (BOOL)isFade{
    return [objc_getAssociatedObject(self, kIsFadeKey) boolValue];
}

- (void)setIsFade:(BOOL)isFade{
    objc_setAssociatedObject(self, kIsFadeKey, @(isFade), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isFading{
    return [objc_getAssociatedObject(self, kIsAnimatingKey) boolValue];
}

- (void)setIsFading:(BOOL)isFading{
    objc_setAssociatedObject(self, kIsAnimatingKey, @(isFading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)verticalCount{
    NSNumber *count = objc_getAssociatedObject(self, kVerticalCountKey);
    if (!count) {
        self.verticalCount = 2;   //设置默认值
    }
    return [objc_getAssociatedObject(self, kVerticalCountKey) integerValue];
}

- (void)setVerticalCount:(NSInteger)verticalCount{
    verticalCount = MAX(1, MIN(4, verticalCount));
    objc_setAssociatedObject(self, kVerticalCountKey, @(verticalCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)horizontalCount{
    NSNumber *count = objc_getAssociatedObject(self, kHorizontalCountKey);
    if (!count) {
        self.horizontalCount = 18;
    }
    return [objc_getAssociatedObject(self, kHorizontalCountKey) integerValue];
}

- (void)setHorizontalCount:(NSInteger)horizontalCount{
    horizontalCount = MAX(16, MIN(20, horizontalCount));
    objc_setAssociatedObject(self, kHorizontalCountKey, @(horizontalCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSTimeInterval)intervalDuration{
    NSNumber *count = objc_getAssociatedObject(self, kIntervalDurationKey);
    if (!count) {
        objc_setAssociatedObject(self, kIntervalDurationKey, @(0.175), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [objc_getAssociatedObject(self, kIntervalDurationKey) doubleValue];
}

- (void)setIntervalDuration:(NSTimeInterval)intervalDuration{
    intervalDuration = MAX(BLMINDURATION * BLMULTIPLED, MIN(self.fadeAnimationDuration *BLMULTIPLED, intervalDuration));
    objc_setAssociatedObject(self, kIntervalDurationKey, @(intervalDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)fadeAnimationDuration{
    NSNumber *count = objc_getAssociatedObject(self, kAnimationDurationKey);
    if (!count) {
        objc_setAssociatedObject(self, kAnimationDurationKey, @(0.7), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [objc_getAssociatedObject(self, kAnimationDurationKey) doubleValue];
}

- (void)setFadeAnimationDuration:(NSTimeInterval)fadeAnimationDuration{
    fadeAnimationDuration = MAX(BLMINDURATION, MIN(BLMAXDURATION, fadeAnimationDuration));
    if (self.intervalDuration > fadeAnimationDuration * BLMULTIPLED || self.intervalDuration <= 0) {
        self.intervalDuration = fadeAnimationDuration *BLMULTIPLED;
    }
    objc_setAssociatedObject(self, kAnimationDurationKey, @(fadeAnimationDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark --操作
- (void)configurateWithVerticalCount:(NSInteger)verticalCount horizontalCount:(NSInteger)horizontalCount interval:(NSTimeInterval)interval duration:(NSTimeInterval)duration{
    self.verticalCount = verticalCount;
    self.horizontalCount = horizontalCount;
    self.intervalDuration = interval;
    self.fadeAnimationDuration = duration;
    if (!self.maskView) {
        self.maskView = self.fadeMaskView;
    }
}

- (UIView *)fadeMaskView{
    UIView *fadeMaskView = [[UIView alloc] initWithFrame:self.bounds];
    if (self.horizontalCount <= 0) {
        self.horizontalCount = 10;
    }
    if (self.verticalCount <= 0) {
        self.verticalCount = 3;
    }
    CGFloat itemWidth = CGRectGetWidth(self.frame) / (self.horizontalCount);
    CGFloat itemHeight = CGRectGetHeight(self.frame) / (self.verticalCount);
    //为了能依次实现对maskview上面的view进行隐藏，所以给他们加标识
    for (NSInteger line = 0; line < self.horizontalCount; line ++) {
        for (NSInteger row = 0; row < self.verticalCount; row ++) {
            UIView *maskSubview = [[UIView alloc] initWithFrame:CGRectMake(itemWidth * line, itemHeight * row, itemWidth, itemHeight)];
            maskSubview.tag = [self subViewTag:line * self.verticalCount + row];
            maskSubview.backgroundColor = [UIColor blackColor];
            [fadeMaskView addSubview:maskSubview];
        }
    }
    return fadeMaskView;
}

//设置标识
- (NSInteger)subViewTag:(NSInteger)idx{
    return kMaskViewTag + idx;
}

//开始动画
- (void)animateFadeWithComplete:(void (^)(void))complete{
    if (self.isFading) {
        NSLog(@"It's animating!");
        return;
    }
    if (!self.maskView) {
        self.maskView = self.fadeMaskView;
    }
    self.isFading = YES;
    if (self.fadeAnimationDuration <= 0) {
        self.fadeAnimationDuration = (BLMAXDURATION + BLMINDURATION) / 2;
    }
    if (self.intervalDuration <= 0) {
        self.intervalDuration = self.fadeAnimationDuration *BLMULTIPLED;
    }
    
    __block NSInteger timeCount = 0;
    //总共上面有多少小view
    NSInteger fadeCount = self.verticalCount * self.horizontalCount;
    for (NSInteger idx = 0; idx < fadeCount; idx ++) {
        UIView *subView = [self.maskView viewWithTag:[self subViewTag:idx]];
        if (!subView) {
            continue;
        }
        //通过改变alpha的值来进行动画
        [UIView animateWithDuration:self.fadeAnimationDuration delay:self.intervalDuration *idx options:UIViewAnimationOptionCurveLinear animations:^{
            subView.alpha = 0;
        } completion:^(BOOL finished) {
            if (timeCount != fadeCount - 1) { //根据timeCount来进行判断是不是最后一个view的消失
                timeCount ++;
            }else{
                self.isFading = NO;
                self.isFade = YES;
                if (complete) {
                    complete();
                }
            }
        }];
    }
}

//反转/恢复动画效果
/*
 * NSParameterAssert()   就是希望程序在相应位置设定的条件不满足的时候抛出来，可以用作安全检查
   断言评估一个条件，如果条件为false 调用当前线程的断点句柄，每一个线程有它自己的断点句柄，它是一个NSAsserttionHandler类的对象，当被调用时，断言句柄打印一个错误信息，该错误信息包含了方法名，类名或函数名，然后它抛出一个NSInternalInconsistencyException异常
 */
- (void)reverseWithComplete:(void (^)(void))complete{
    NSParameterAssert(self.maskView);
    if (self.isFading) {
        NSLog(@"It's animating");
        return;
    }
    
    self.isFading = YES;
    if (self.fadeAnimationDuration <= 0) {
        self.fadeAnimationDuration = (BLMAXDURATION + BLMINDURATION) / 2;
    }
    if (self.intervalDuration <= 0) {
        self.intervalDuration = self.fadeAnimationDuration *BLMULTIPLED;
    }
    
    __block NSInteger timeCount = 0;
    NSInteger fadeCount = self.verticalCount * self.horizontalCount;
    for (NSInteger idx = fadeCount - 1; idx >= 0; idx --) {
        UIView *subView = [self.maskView viewWithTag:[self subViewTag:idx]];
        [UIView animateWithDuration:self.fadeAnimationDuration delay:self.intervalDuration *(fadeCount - 1 - idx) options:UIViewAnimationOptionCurveLinear animations:^{
            subView.alpha = 1;
        } completion:^(BOOL finished) {
            if (++timeCount == fadeCount) {
                self.isFade = NO;
                self.isFading = NO;
                if (complete) {
                    complete();
                }
            }
        }];
    }
}

//恢复默认值
- (void)reverseWithoutAnimate{
    if (self.isFading) {
        NSLog(@"It's animating!");
        return;
    }
    for (UIView *subView in self.maskView.subviews) {
        subView.alpha = 1;
    }
}





@end
