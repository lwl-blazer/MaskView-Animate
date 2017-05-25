//
//  UIImageView+BLBannerAnimation.h
//  MaskViewAnimateDemo
//
//  Created by blazer on 16/8/24.
//  Copyright © 2016年 blazer. All rights reserved.
//  图片轮播广告页碎片化动画

#import <UIKit/UIKit.h>
#import "UIView+BLFadeAnimation.h"

#define BLFADEDURATION 2.0

@interface UIImageView (BLBannerAnimation)

//设置后停止动画
@property(nonatomic, assign) BOOL stop;

//每次切换图片的动画时长 1.5~2.5
@property(nonatomic, assign) NSTimeInterval fadeDuration;

//轮播图片数组
@property(nonatomic, strong) NSArray *bannerImages;

- (void)fadeBanner;

- (void)fadeBannerWithImages:(NSArray *)images;

- (void)stopBanner;


@end
