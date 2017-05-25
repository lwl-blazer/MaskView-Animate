//
//  ViewController.m
//  MaskViewAnimateDemo
//
//  Created by blazer on 16/8/24.
//  Copyright © 2016年 blazer. All rights reserved.
//  遮罩视图 maskView在iOS8之后开始使用

#import "ViewController.h"
#import "UIImageView+BLBannerAnimation.h"


@interface ViewController ()

@property(nonatomic, strong) UIImageView *imageViweOne;
@property(nonatomic, strong) UIImageView *imageViweTwo;
@property(nonatomic, strong) UIImageView *bannerImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageViweOne = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageViweOne.image = [UIImage imageNamed:@"1.jpg"];
    [self.view addSubview:self.imageViweOne];
    
    self.imageViweTwo = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageViweTwo.image = [UIImage imageNamed:@"2.jpg"];
    [self.view addSubview:self.imageViweTwo];
    
    self.bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    self.bannerImageView.image = [UIImage imageNamed:@"banner1.jpg"];
    [self.view addSubview:self.bannerImageView];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //[self imageFadeTransition];
    [self bannerFadeAnimate];
}


- (void)imageFadeTransition{
    if(self.imageViweTwo.isFade){
        [self.imageViweTwo reverseWithComplete:^{
            NSLog(@"View Show agin");
        }];
    }else{
        [self.imageViweTwo animateFadeWithComplete:^{
            NSLog(@"Finshed fade animation");
        }];
    }
}

- (void)bannerFadeAnimate{
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 1; i < 5; i ++) {
        [images addObject:[NSString stringWithFormat:@"banner%ld.jpg", i]];
    }
    [self.bannerImageView fadeBannerWithImages:images];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
