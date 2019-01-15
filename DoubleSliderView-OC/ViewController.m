//
//  ViewController.m
//  DoubleSliderView-OC
//
//  Created by DU on 2019/1/13.
//  Copyright © 2019 DU. All rights reserved.
//

#import "ViewController.h"
#import "DoubleSliderView.h"
#import "UIView+Extension.h"

@interface ViewController ()

@property (nonatomic, assign) NSInteger minAge;
@property (nonatomic, assign) NSInteger maxAge;
@property (nonatomic, assign) NSInteger curMinAge;
@property (nonatomic, assign) NSInteger curMaxAge;

@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *ageTipsLabel;
@property (nonatomic, strong) DoubleSliderView *doubleSliderView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.minAge = 12;
    self.maxAge = 35;
    self.curMinAge = 12;
    self.curMaxAge = 35;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.ageLabel];
    [self.view addSubview:self.ageTipsLabel];
    [self.view addSubview:self.doubleSliderView];
    
    self.ageLabel.centerY = 156;
    self.ageLabel.x = 52;
    
    self.ageTipsLabel.centerY = self.ageLabel.centerY;
    self.ageTipsLabel.x = self.ageLabel.right + 7;
    
    self.doubleSliderView.x = 52;
    self.doubleSliderView.y = 185 - 10;
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - action
//根据值获取整数

- (CGFloat)fetchIntFromValue:(CGFloat)value {
    CGFloat newValue = floorf(value);
    CGFloat changeValue = value - newValue;
    if (changeValue >= 0.5) {
        newValue = newValue + 1;
    }
    return newValue;
}

- (void)sliderValueChangeActionIsLeft: (BOOL)isLeft finish: (BOOL)finish {
    if (isLeft) {
        CGFloat age = (self.maxAge - self.minAge) * self.doubleSliderView.curMinValue;
        CGFloat tmpAge = [self fetchIntFromValue:age];
        if (tmpAge != age) {
            self.curMinAge = (NSInteger)tmpAge + self.minAge;
            [self changeAgeTipsText];
        }
    }else {
        CGFloat age = (self.maxAge - self.minAge) * self.doubleSliderView.curMaxValue;
        CGFloat tmpAge = [self fetchIntFromValue:age];
        if (tmpAge != age) {
            self.curMaxAge = (NSInteger)tmpAge + self.minAge;
            [self changeAgeTipsText];
        }
    }
    if (finish) {
        [self changeSliderValue];
    }
}

//值取整后可能改变了原始的大小，所以需要重新改变滑块的位置
- (void)changeSliderValue {
    CGFloat finishMinValue = (CGFloat)(self.curMinAge - self.minAge)/(CGFloat)(self.maxAge - self.minAge);
    CGFloat finishMaxValue = (CGFloat)(self.curMaxAge - self.minAge)/(CGFloat)(self.maxAge - self.minAge);
    self.doubleSliderView.curMinValue = finishMinValue;
    self.doubleSliderView.curMaxValue = finishMaxValue;
    [self.doubleSliderView changeLocationFromValue];
}

- (void)changeAgeTipsText {
    if (self.curMinAge == self.curMaxAge) {
        self.ageTipsLabel.text = [NSString stringWithFormat:@"%li岁", self.curMinAge];
    }else {
        self.ageTipsLabel.text = [NSString stringWithFormat:@"%li~%li岁", self.curMinAge, self.curMaxAge];
    }
    [self.ageTipsLabel sizeToFit];
    self.ageTipsLabel.centerY = self.ageLabel.centerY;
    self.ageTipsLabel.x = self.ageLabel.right + 7;
}

#pragma mark - setter & getter

- (UILabel *)ageLabel {
    if (!_ageLabel) {
        _ageLabel = [[UILabel alloc] init];
        _ageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _ageLabel.textColor = [UIColor blackColor];
        _ageLabel.text = @"年龄 age";
        [_ageLabel sizeToFit];
    }
    return _ageLabel;
}

- (UILabel *)ageTipsLabel {
    if (!_ageTipsLabel) {
        _ageTipsLabel = [[UILabel alloc] init];
        _ageTipsLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _ageTipsLabel.textColor = [UIColor blackColor];
        _ageTipsLabel.text = [NSString stringWithFormat:@"%li~%li岁",self.minAge, self.maxAge];
        [_ageTipsLabel sizeToFit];
    }
    return _ageTipsLabel;
}

- (DoubleSliderView *)doubleSliderView {
    if (!_doubleSliderView) {
        _doubleSliderView = [[DoubleSliderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 52 * 2, 35 + 20)];
        _doubleSliderView.needAnimation = true;
//        CGFloat offset = self.maxAge - self.minAge;
//        if (offset > 4.0) {
//            _doubleSliderView.minInterval = 4.0/(offset);
//        }
        __weak typeof(self) weakSelf = self;
        _doubleSliderView.sliderBtnLocationChangeBlock = ^(BOOL isLeft, BOOL finish) {
            [weakSelf sliderValueChangeActionIsLeft:isLeft finish:finish];
        };
    }
    return _doubleSliderView;
}

@end
