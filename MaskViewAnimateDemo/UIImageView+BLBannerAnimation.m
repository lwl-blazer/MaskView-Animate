//
//  UIImageView+BLBannerAnimation.m
//  MaskViewAnimateDemo
//
//  Created by blazer on 16/8/24.
//  Copyright © 2016年 blazer. All rights reserved.
//

#import "UIImageView+BLBannerAnimation.h"
#import <objc/runtime.h>

const void * kCompleteBlockKey = &kCompleteBlockKey;
const void * kBannerImagesKey = &kBannerImagesKey;
const void * kPageControlkey = &kPageControlkey;
const void *kTempImageKey = &kTempImageKey;
const void *kStopKey = &kStopKey;


@implementation UIImageView (BLBannerAnimation)

- (BOOL)stop{
    return [objc_getAssociatedObject(self, kStopKey) boolValue];
}

- (void)setStop:(BOOL)stop{
    objc_setAssociatedObject(self, kStopKey, @(stop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)fadeDuration{
    if (self.bannerImages.count < 2) {
        return 0;
    }
    return (self.verticalCount * self.horizontalCount + 3) * self.intervalDuration;
}

- (void)setFadeDuration:(NSTimeInterval)fadeDuration{
    if (self.bannerImages.count > 1) {
        fadeDuration = MIN(2.5, MAX(1.5, fadeDuration));
        self.fadeAnimationDuration = fadeDuration / (self.bannerImages.count + 3) / BLMULTIPLED;
        self.intervalDuration = self.fadeAnimationDuration * BLMULTIPLED;
    }
}

- (NSArray *)bannerImages{
    return objc_getAssociatedObject(self, kBannerImagesKey);
}

- (void)setBannerImages:(NSArray *)bannerImages{
    objc_setAssociatedObject(self, kBannerImagesKey, bannerImages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)fadeBanner{
    NSParameterAssert(self.superview);
    //展示第一张图片
    self.image = [UIImage imageNamed:self.bannerImages.firstObject];
    
    if (self.bannerImages.count < 2) {
        return;
    }
    //得到下一张图片
    UIImageView *tempBanner = [self associateTempBannerWithImage:[UIImage imageNamed:self.bannerImages[1]]];
    self.stop = NO;
    __block NSInteger idx = 0;
    __weak typeof(self) weakSelf = self;
    //pageControl
    [self associatePageControlWithCurrentIdx:idx];
    //block
    void (^complete)() = ^{
        NSInteger updateIndex = [weakSelf updateImageWithCurrentIndex:++idx tempBanner:tempBanner];
        idx = updateIndex;
        [weakSelf associatePageControlWithCurrentIdx:idx];
    };

    /*
     * 保存block并执行动画 
     * 在这里保存这个block是有必要的，动态的保存起来，否则这个block执行到第三次的图片碎片的时候就会被释放从而导致崩溃
     */
    objc_setAssociatedObject(self, kCompleteBlockKey, complete, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self animateFadeWithComplete:^{
        if (!self.stop) {
            complete();
        }
    }];
}

//设置PageControl
/*
 *pageControl一开始我加在执行动画的imageView上面，但是在动画执行到一半的时候，pageControl也会随着局部隐藏动画隐藏起来。因此根据imageView当前的坐标重新计算出合适的尺寸范围
 */
- (void)associatePageControlWithCurrentIdx:(NSInteger)idx{
    UIPageControl *pageControl = objc_getAssociatedObject(self, kPageControlkey);
    if (!pageControl) {
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.frame.origin.x, CGRectGetHeight(self.frame) - 37 + self.frame.origin.y, CGRectGetWidth(self.frame), 37)];
        [self.superview addSubview:pageControl];
        pageControl.numberOfPages = self.bannerImages.count;
        objc_setAssociatedObject(self, kPageControlkey, pageControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    pageControl.currentPage = idx;
}

//获取动态绑定临时展示的UIImageView
- (UIImageView *)associateTempBannerWithImage:(UIImage *)image{
    UIImageView *tempBanner = objc_getAssociatedObject(self, kTempImageKey);
    if (!tempBanner) {
        tempBanner = [[UIImageView alloc] initWithFrame:self.frame];
        objc_setAssociatedObject(self, kTempImageKey, tempBanner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.superview insertSubview:tempBanner belowSubview:self];
    }
    tempBanner.image = image;
    return tempBanner;
}



//更新展示的图片，并且返回下一次要展示的图片下标
- (NSInteger)updateImageWithCurrentIndex:(NSInteger)idx tempBanner:(UIImageView *)tempBanner{
    if (idx >= self.bannerImages.count) {  //复原
        idx = 0;
    }
    self.image = [UIImage imageNamed:self.bannerImages[idx]];
    
    //别忘了在每次图片切换完成之后，将所有的子视图遮罩还原，并且更新图片显示
    [self reverseWithoutAnimate];
    
    NSInteger nextIdx = idx + 1;
    if (nextIdx >= self.bannerImages.count) {
        nextIdx = 0;
    }
    tempBanner.image = [UIImage imageNamed:self.bannerImages[nextIdx]];
    [self animateFadeWithComplete:^{
        if (!self.stop) {
            //得到上面的block并再执行上面的代码块
            void (^complete)() = objc_getAssociatedObject(self, kCompleteBlockKey);
            complete();
        }else{
            //完成以后，直接致空
            [objc_getAssociatedObject(self, kTempImageKey) removeFromSuperview];
            [objc_getAssociatedObject(self, kPageControlkey) removeFromSuperview];
            objc_setAssociatedObject(self, kTempImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, kTempImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }];
    return idx;
}

- (void)fadeBannerWithImages:(NSArray *)images{
    self.bannerImages = images;
    [self fadeBanner];
}

- (void)stopBanner{
    self.stop = YES;
}

@end
