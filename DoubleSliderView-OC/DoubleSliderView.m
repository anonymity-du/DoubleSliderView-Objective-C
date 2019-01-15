//
//  DoubleSliderView.m
//  DoubleSliderView-OC
//
//  Created by 杜奎 on 2019/1/13.
//  Copyright © 2019 DU. All rights reserved.
//

#import "DoubleSliderView.h"
#import "UIView+Extension.h"

@interface DoubleSliderView ()

//手势起手位置类型 0 未在按钮上 not on button ; 1 在左边按钮上 on left button ; 2 在右边按钮上 on right button ; 3 两者重叠 overlap
@property (nonatomic, assign) NSInteger dragType;
@property (nonatomic, assign) CGFloat minIntervalWidth;
@property (nonatomic, assign) CGPoint minCenter;//左侧按钮的中心位置 left btn's center
@property (nonatomic, assign) CGPoint maxCenter;//右侧按钮的中心位置 right btn's center
@property (nonatomic, assign) CGFloat marginCenterX;

@property (nonatomic, strong) UIView   *minLineView;
@property (nonatomic, strong) UIView   *maxLineView;
@property (nonatomic, strong) UIView   *midLineView;
@property (nonatomic, strong) UIButton *minSliderBtn;
@property (nonatomic, strong) UIButton *maxSliderBtn;

@end

@implementation DoubleSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (self.height < 35 + 20) {
            self.height = 55;
        }
        self.marginCenterX = 17.5;
        [self createUI];
    }
    return self;
}

- (void)createUI {
    [self addSubview:self.minLineView];
    [self addSubview:self.midLineView];
    [self addSubview:self.maxLineView];
    [self addSubview:self.minSliderBtn];
    [self addSubview:self.maxSliderBtn];
    
    self.curMinValue = 0;
    self.curMaxValue = 1;
    
    CGFloat centerY = self.height * 0.5;
    
    self.minSliderBtn.centerY = centerY;
    self.maxSliderBtn.centerY = centerY;
    self.minSliderBtn.x = 0;
    self.maxSliderBtn.right = self.width;
    
    self.minLineView.centerY = centerY;
    self.midLineView.centerY = centerY;
    self.maxLineView.centerY = centerY;
    
    [self changeLineViewWidth];
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderBtnPanAction:)]];
}

#pragma mark - action

- (void)sliderBtnPanAction: (UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    CGPoint translation = [gesture translationInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGRect minSliderFrame = CGRectMake(self.minSliderBtn.x - 10, self.minSliderBtn.y - 10, self.minSliderBtn.width + 20, self.minSliderBtn.height + 20);
        CGRect maxSliderFrame = CGRectMake(self.maxSliderBtn.x - 10, self.maxSliderBtn.y - 10, self.maxSliderBtn.width + 20, self.maxSliderBtn.height + 20);
        BOOL inMinSliderBtn = CGRectContainsPoint(minSliderFrame, location);
        BOOL inMaxSliderBtn = CGRectContainsPoint(maxSliderFrame, location);
        
        if (inMinSliderBtn && !inMaxSliderBtn) {
            NSLog(@"从左边开始触摸 start drag from left");
            self.dragType = 1;
        }else if (!inMinSliderBtn && inMaxSliderBtn) {
            NSLog(@"从右边开始触摸 start drag from right");
            self.dragType = 2;
        }else if (!inMaxSliderBtn && !inMinSliderBtn) {
            NSLog(@"没有触动到按钮 not on button");
            self.dragType = 0;
        }else {
            CGFloat leftOffset = fabs(location.x - self.minSliderBtn.centerX);
            CGFloat rightOffset = fabs(location.x - self.maxSliderBtn.centerX);
            if (leftOffset > rightOffset) {
                NSLog(@"挨着，往右边 start drag from right");
                self.dragType = 2;
            }else if (leftOffset < rightOffset) {
                NSLog(@"挨着，往左边 start drag from left");
                self.dragType = 1;
            }else {
                NSLog(@"正中间 overlap");
                self.dragType = 3;
            }
        }
        if (self.dragType == 1) {
            self.minCenter = self.minSliderBtn.center;
            [self bringSubviewToFront:self.minSliderBtn];
        }else if (self.dragType == 2) {
            self.maxCenter = self.maxSliderBtn.center;
            [self bringSubviewToFront:self.maxSliderBtn];
        }
        if (self.minInterval > 0) {
            self.minIntervalWidth = (self.width - self.marginCenterX * 2) * self.minInterval;
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.dragType == 3) {
            if (translation.x > 0) {
                self.dragType = 2;
                self.maxCenter = self.maxSliderBtn.center;
                [self bringSubviewToFront:self.maxSliderBtn];
                NSLog(@"从中间往右 from center to right");
            }else if (translation.x < 0) {
                self.dragType = 1;
                self.minCenter = self.minSliderBtn.center;
                [self bringSubviewToFront:self.minSliderBtn];
                NSLog(@"从中间往左 from center to left");
            }
        }
        if (self.dragType != 0 && self.dragType != 3) {
            if (self.dragType == 1) {
                self.minSliderBtn.center = CGPointMake(self.minCenter.x + translation.x, self.minCenter.y);
                if (self.minSliderBtn.right > self.maxSliderBtn.right - self.minIntervalWidth) {
                    self.minSliderBtn.right = self.maxSliderBtn.right - self.minIntervalWidth;
                }else {
                    if (self.minSliderBtn.centerX < self.marginCenterX) {
                        self.minSliderBtn.centerX = self.marginCenterX;
                    }
                    if (self.minSliderBtn.centerX > self.width - self.marginCenterX) {
                        self.minSliderBtn.centerX = self.width - self.marginCenterX;
                    }
                }
                [self changeLineViewWidth];
                [self changeValueFromLocation];
                if (self.sliderBtnLocationChangeBlock != nil) {
                    self.sliderBtnLocationChangeBlock(true, false);
                }
            }else {
                self.maxSliderBtn.center = CGPointMake(self.maxCenter.x + translation.x, self.maxCenter.y);
                if (self.maxSliderBtn.x < self.minSliderBtn.x + self.minIntervalWidth) {
                    self.maxSliderBtn.x = self.minSliderBtn.x + self.minIntervalWidth;
                }else {
                    if (self.maxSliderBtn.centerX < self.marginCenterX) {
                        self.maxSliderBtn.centerX = self.marginCenterX;
                    }
                    if (self.maxSliderBtn.centerX > self.width - self.marginCenterX) {
                        self.maxSliderBtn.centerX = self.width - self.marginCenterX;
                    }
                }
                [self changeLineViewWidth];
                [self changeValueFromLocation];
                if (self.sliderBtnLocationChangeBlock != nil) {
                    self.sliderBtnLocationChangeBlock(false, false);
                }
            }
        }
     
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.dragType == 1) {
            [self changeValueFromLocation];
            if (self.sliderBtnLocationChangeBlock != nil) {
                self.sliderBtnLocationChangeBlock(true, true);
            }
        }else if (self.dragType == 2) {
            [self changeValueFromLocation];
            if (self.sliderBtnLocationChangeBlock != nil) {
                self.sliderBtnLocationChangeBlock(false, true);
            }
        }
        self.dragType = 0;
    }
}

//改变值域的线宽
- (void)changeLineViewWidth {
    self.minLineView.width = self.minSliderBtn.centerX;
    self.minLineView.x = 0;
    
    self.maxLineView.width = self.width - self.maxSliderBtn.centerX;
    self.maxLineView.right = self.width;
    
    self.midLineView.width = self.maxSliderBtn.centerX - self.minSliderBtn.centerX;
    self.midLineView.x = self.minLineView.right;
}

//根据滑块位置改变当前最小和最大的值
- (void)changeValueFromLocation {
    CGFloat contentWidth = self.width - self.marginCenterX * 2;
    self.curMinValue = (self.minSliderBtn.centerX - self.marginCenterX)/contentWidth;
    self.curMaxValue = (self.maxSliderBtn.centerX - self.marginCenterX)/contentWidth;
}

//根据当前最小和最大的值改变滑块位置
- (void)changeLocationFromValue {
    CGFloat contentWidth = self.width - self.marginCenterX * 2;
    if (self.needAnimation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.minSliderBtn.centerX = self.marginCenterX + self.curMinValue * contentWidth;
            self.maxSliderBtn.centerX = self.marginCenterX + self.curMaxValue * contentWidth;
            [self changeLineViewWidth];
        }];
    }else {
        self.minSliderBtn.centerX = self.marginCenterX + self.curMinValue * contentWidth;
        self.maxSliderBtn.centerX = self.marginCenterX + self.curMaxValue * contentWidth;
        [self changeLineViewWidth];
    }
    if (self.curMinValue == self.curMaxValue) {
        if (self.curMaxValue == 0) {
            [self bringSubviewToFront:self.maxSliderBtn];
        }else {
            [self bringSubviewToFront:self.minSliderBtn];
        }
    }
}
#pragma mark - setter & getter

- (void)setMinTintColor:(UIColor *)minTintColor {
    _minTintColor = minTintColor;
    self.minLineView.backgroundColor = minTintColor;
}

- (void)setMidTintColor:(UIColor *)midTintColor {
    _midTintColor = midTintColor;
    self.midLineView.backgroundColor = midTintColor;
}

- (void)setMaxTintColor:(UIColor *)maxTintColor {
    _maxTintColor = maxTintColor;
    self.maxLineView.backgroundColor = maxTintColor;
}

- (UIView *)minLineView {
    if (!_minLineView) {
        _minLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
        _minLineView.backgroundColor = [[UIColor alloc] initWithRed:162.0/255.0 green:141.0/255.0 blue:255.0/255.0 alpha:0.2];
        _minLineView.userInteractionEnabled = NO;
    }
    return _minLineView;
}

- (UIView *)midLineView {
    if (!_midLineView) {
        _midLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
        _midLineView.backgroundColor = [[UIColor alloc] initWithRed:162.0/255.0 green:141.0/255.0 blue:255.0/255.0 alpha:1];
        _midLineView.userInteractionEnabled = NO;
    }
    return _midLineView;
}

- (UIView *)maxLineView {
    if (!_maxLineView) {
        _maxLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 5)];
        _maxLineView.backgroundColor = [[UIColor alloc] initWithRed:162.0/255.0 green:141.0/255.0 blue:255.0/255.0 alpha:0.2];
        _maxLineView.userInteractionEnabled = NO;
    }
    return _maxLineView;
}

- (UIButton *)minSliderBtn {
    if (!_minSliderBtn) {
        _minSliderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _minSliderBtn.size = CGSizeMake(35, 35);
        _minSliderBtn.backgroundColor = [UIColor whiteColor];
        _minSliderBtn.layer.cornerRadius = 17.5;
        _minSliderBtn.layer.shadowColor = [[UIColor blackColor] CGColor];
        _minSliderBtn.layer.shadowOffset = CGSizeMake(0, 1);
        _minSliderBtn.layer.shadowRadius = 5;
        _minSliderBtn.layer.shadowOpacity = 0.15;
        _minSliderBtn.userInteractionEnabled = false;
    }
    return _minSliderBtn;
}

- (UIButton *)maxSliderBtn {
    if (!_maxSliderBtn) {
        _maxSliderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _maxSliderBtn.size = CGSizeMake(35, 35);
        _maxSliderBtn.backgroundColor = [UIColor whiteColor];
        _maxSliderBtn.layer.cornerRadius = 17.5;
        _maxSliderBtn.layer.shadowColor = [[UIColor blackColor] CGColor];
        _maxSliderBtn.layer.shadowOffset = CGSizeMake(0, 1);
        _maxSliderBtn.layer.shadowRadius = 5;
        _maxSliderBtn.layer.shadowOpacity = 0.15;
        _maxSliderBtn.userInteractionEnabled = false;
    }
    return _maxSliderBtn;
}

@end
