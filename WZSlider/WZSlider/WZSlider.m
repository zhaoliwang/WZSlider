//
//  WZSlider.m
//  WZSlider
//
//  Created by liwang.zhao on 16/7/6.
//  Copyright © 2016年 LandOfMystery. All rights reserved.
//

#import "WZSlider.h"
#import "UIImage+Tint.h"

@implementation WZSliderViewModel

- (id)copyWithZone:(nullable NSZone *)zone{
    WZSliderViewModel *viewModel = [[WZSliderViewModel allocWithZone:zone] init];
    viewModel.maxPrice = self.maxPrice;
    viewModel.minPrice = self.minPrice;
    viewModel.minSelectPrice = self.minSelectPrice;
    viewModel.maxSelectPrice = self.maxSelectPrice;
    viewModel.unit = self.unit;
    return viewModel;
}

@end

@interface WZSlider()

//view
@property (nonatomic, strong) UILabel *titleLabel;              //title
@property (nonatomic, strong) UILabel *minPriceLabel;           //最小价格label
@property (nonatomic, strong) UILabel *maxPriceLabel;           //最大价格label
@property (nonatomic, strong) UIView *lineBackgroundView;       //线条背景view
@property (nonatomic, strong) UIView *lineView;                 //线条view
@property (nonatomic, strong) UIView *minThumbView;             //左侧滑动view
@property (nonatomic, strong) UIView *maxThumbView;             //右侧滑动view
@property (nonatomic, strong) UIView *cursorView;               //游标view

@property (nonatomic, strong) UIView *activeView;               //记录活动的view

//data
@property (nonatomic, assign) CGFloat interval;                 //间距
@property (nonatomic, strong) WZSliderViewModel *tmpViewModel;  //临时数据

@end

@implementation WZSlider

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setMultipleTouchEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _tmpViewModel = [_viewModel copy];
        [self initViews:frame];
    }
    return self;
}

- (void)reset{
    _tmpViewModel.minSelectPrice = _tmpViewModel.minPrice;
    _tmpViewModel.maxSelectPrice = _tmpViewModel.maxPrice;
    
    [self setMinThumb:[NSString stringWithFormat:@"$%lu",_tmpViewModel.minSelectPrice] animated:YES];
    [self setMaxThumb:[NSString stringWithFormat:@"$%lu",_tmpViewModel.maxSelectPrice] animated:YES];
}

- (void)setViewModel:(WZSliderViewModel *)viewModel{
    _tmpViewModel = [viewModel copy];
    NSAssert(_tmpViewModel.unit > 0, @"unit must be greater than zero");
    NSAssert(_tmpViewModel.maxPrice >= _tmpViewModel.maxSelectPrice && _tmpViewModel.maxSelectPrice > _tmpViewModel.minSelectPrice && _tmpViewModel.minSelectPrice >= _tmpViewModel.minPrice, @"Parameter error");
    NSInteger number = (_tmpViewModel.maxPrice - _tmpViewModel.minPrice)%_tmpViewModel.unit;
    NSAssert(number == 0, @"Parameter error(unit)");
    
    NSInteger num = (_tmpViewModel.maxPrice - _tmpViewModel.minPrice)/_tmpViewModel.unit;
    [self setInterval:((self.frame.size.width - 24 - 44)/num)];

    [self setMinThumb:[NSString stringWithFormat:@"$%lu",_tmpViewModel.minSelectPrice] animated:NO];
    [self setMaxThumb:[NSString stringWithFormat:@"$%lu",_tmpViewModel.maxSelectPrice] animated:NO];
}

#pragma mark - 触摸事件

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([[touches anyObject] view] == _minThumbView || [[touches anyObject] view] == _maxThumbView) {
        _activeView = (UIImageView *)[[touches anyObject] view];
        
        [self.cursorView setCenter:CGPointMake(_activeView.center.x, self.cursorView.center.y)];
        [self.cursorView setHidden:NO];
        self.cursorView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.cursorView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if (_activeView == _minThumbView) {
        [self setCursorPrice:_tmpViewModel.minSelectPrice];
    } else if (_activeView == _maxThumbView){
        [self setCursorPrice:_tmpViewModel.maxSelectPrice];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint startPreviousLocation = [[touches anyObject] previousLocationInView:_minThumbView];
    CGPoint startCurrentLocation = [[touches anyObject] locationInView:_minThumbView];
    
    CGPoint endPreviousLocation = [[touches anyObject] previousLocationInView:_maxThumbView];
    CGPoint endCurrentLocation = [[touches anyObject] locationInView:_maxThumbView];
    
    CGFloat moved = 0;
    if ([[touches anyObject] view] == _minThumbView) {
        moved = startCurrentLocation.x - startPreviousLocation.x;
    } else if ([[touches anyObject] view] == _maxThumbView){
        moved = endCurrentLocation.x - endPreviousLocation.x;
    }
    
    CGRect minThumbFrame = [_minThumbView frame];
    CGRect maxThumbFrame = [_maxThumbView frame];
    
    if (_activeView == _minThumbView) {
        if (minThumbFrame.origin.x == 12 && moved <= 0) {
            minThumbFrame.origin.x = 12;
        } else if (minThumbFrame.origin.x == 12 && moved > 0){
            if (fabs(minThumbFrame.origin.x - maxThumbFrame.origin.x + _interval) < 0.000001) {
                _activeView = _maxThumbView;
            } else {
                //防止滑动距离过大超过边界
                if (moved > (maxThumbFrame.origin.x - minThumbFrame.origin.x - _interval)) {
                    minThumbFrame.origin.x = maxThumbFrame.origin.x - _interval;
                } else {
                    minThumbFrame.origin.x += moved;
                }
            }
        } else {
            if (fabs(minThumbFrame.origin.x - maxThumbFrame.origin.x + _interval) < 0.000001) {
                if (moved <= 0) {
                    minThumbFrame.origin.x += moved;
                } else {
                    _activeView = _maxThumbView;
                }
            } else {
                if (minThumbFrame.origin.x > maxThumbFrame.origin.x - _interval) {
                    _activeView = _maxThumbView;
                    NSInteger index = (minThumbFrame.origin.x - 12 + 0.5 * _interval)/_interval;
                    minThumbFrame.origin.x = index * _interval + 12;
                } else {
                    //防止滑动距离过大超过边界
                    if (moved > (maxThumbFrame.origin.x - minThumbFrame.origin.x - _interval)) {
                        minThumbFrame.origin.x = maxThumbFrame.origin.x - _interval;
                    } else {
                        minThumbFrame.origin.x += moved;
                    }
                }
            }
        }
        
    } else if (_activeView == _maxThumbView) {
        CGFloat width = self.frame.size.width;
        if (maxThumbFrame.origin.x == width - 12 - maxThumbFrame.size.width && moved >= 0) {
            maxThumbFrame.origin.x = width - 12 - maxThumbFrame.size.width;
        } else if (maxThumbFrame.origin.x == width - 12 - maxThumbFrame.size.width && moved < 0){
            if (minThumbFrame.origin.x == maxThumbFrame.origin.x - _interval) {
                _activeView = _minThumbView;
            } else {
                //防止滑动距离过大超过边界
                if (-moved > (maxThumbFrame.origin.x - minThumbFrame.origin.x - _interval)) {
                    maxThumbFrame.origin.x = minThumbFrame.origin.x + _interval;
                } else {
                    maxThumbFrame.origin.x += moved;
                }
            }
        } else {
            if (fabs(minThumbFrame.origin.x - maxThumbFrame.origin.x + _interval) < 0.000001) {
                if (moved > 0) {
                    maxThumbFrame.origin.x += moved;
                } else {
                    _activeView = _minThumbView;
                }
            } else {
                if (fabs(minThumbFrame.origin.x - maxThumbFrame.origin.x + _interval) < 0.000001) {
                    NSInteger index = (maxThumbFrame.origin.x - 12 + 0.5 * _interval)/_interval;
                    maxThumbFrame.origin.x = index*_interval + 12;
                    _activeView = _minThumbView;
                }else {
                    //防止滑动距离过大超过边界
                    if (-moved > (maxThumbFrame.origin.x - minThumbFrame.origin.x - _interval)) {
                        maxThumbFrame.origin.x = minThumbFrame.origin.x + _interval;
                    } else {
                        maxThumbFrame.origin.x += moved;
                    }
                    
                }
            }
        }
    }
    if (minThumbFrame.origin.x < 12) {
        minThumbFrame.origin.x = 12;
    }
    if (maxThumbFrame.origin.x > self.frame.size.width - 12 - maxThumbFrame.size.width) {
        maxThumbFrame.origin.x = self.frame.size.width - 12 - maxThumbFrame.size.width;
    }
    
    [_minThumbView setFrame:minThumbFrame];
    [_maxThumbView setFrame:maxThumbFrame];
    
    //设置标签价格
    NSInteger maxIndex = (maxThumbFrame.origin.x - 12 + 0.5 * _interval)/_interval;
    _tmpViewModel.maxSelectPrice = _tmpViewModel.minPrice + maxIndex * _tmpViewModel.unit;
    _maxPriceLabel.text = [NSString stringWithFormat:@"$%lu",_tmpViewModel.maxSelectPrice];
    
    NSInteger minIndex = (minThumbFrame.origin.x - 12 + 0.5 * _interval)/_interval;
    _tmpViewModel.minSelectPrice = _tmpViewModel.minPrice + minIndex * _tmpViewModel.unit;
    _minPriceLabel.text = [NSString stringWithFormat:@"$%lu",_tmpViewModel.minSelectPrice];

    [self.cursorView setCenter:CGPointMake(_activeView.center.x, self.cursorView.center.y)];
    if (_activeView == _minThumbView) {
        [self setCursorPrice:_tmpViewModel.minSelectPrice];
    } else {
        [self setCursorPrice:_tmpViewModel.maxSelectPrice];
    }
    
    [_lineView setFrame:CGRectMake(_minThumbView.center.x - 34, 0, _maxThumbView.center.x - _minThumbView.center.x, 2)];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //若不是这两个按钮，直接返回，避免点按其他位置结束时也调用该方法，造成不必要的麻烦
    if ([[touches anyObject] view] != _minThumbView && [[touches anyObject] view] != _maxThumbView) {
        return;
    }
    
    // 设置报价
    NSInteger indexMin = (_minThumbView.frame.origin.x - 12 + 0.5 * _interval)/_interval;
    NSInteger indexMax = (_maxThumbView.frame.origin.x - 12 + 0.5 * _interval)/_interval;
    
    
    _tmpViewModel.minSelectPrice = _tmpViewModel.minPrice + indexMin * _tmpViewModel.unit;
    _tmpViewModel.maxSelectPrice = _tmpViewModel.minPrice + indexMax * _tmpViewModel.unit;

    [self setMinThumb:[NSString stringWithFormat:@"$%lu",_tmpViewModel.minSelectPrice] animated:YES];
    [self setMaxThumb:[NSString stringWithFormat:@"$%lu",_tmpViewModel.maxSelectPrice] animated:YES];
    
    [self.cursorView setCenter:CGPointMake(_activeView.center.x, self.cursorView.center.y)];
    _activeView = nil;
    
    
    [UIView animateWithDuration:0.1 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.cursorView.transform = CGAffineTransformMakeScale(0.3,0.3);
    } completion:^(BOOL finished) {
        [self.cursorView setHidden:YES];
        
    }];
}


#pragma private method

- (void)initViews:(CGRect)frame{
    [self addSubview:self.titleLabel];
    [self addSubview:self.minPriceLabel];
    [self addSubview:self.maxPriceLabel];
    [self addSubview:self.lineBackgroundView];
    [self.lineBackgroundView addSubview:self.lineView];
    [self addSubview:self.minThumbView];
    [self addSubview:self.maxThumbView];
    [self addSubview:self.cursorView];
    
    [self bringSubviewToFront:self.minThumbView];
    [self bringSubviewToFront:self.maxThumbView];
}


- (void)setCursorPrice:(NSInteger)price{
    UILabel *priceLabel = [self.cursorView viewWithTag:100];
    [priceLabel setText:[NSString stringWithFormat:@"$%lu",price]];
}

- (void)setMinThumb:(NSString *)newMinThumb animated:(BOOL)animated{
    if (newMinThumb){
        // 重新设置最小报价滑块坐标
        NSInteger index = (_tmpViewModel.minSelectPrice - _tmpViewModel.minPrice)/_tmpViewModel.unit;
        _minPriceLabel.text = newMinThumb;
        
        if (animated) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [_minThumbView setCenter:CGPointMake((_interval * index + 22 + 12), _minThumbView.center.y)];
                                 
                                 [_lineView setFrame:CGRectMake(_minThumbView.center.x - 34,
                                                                  0,
                                                                  _maxThumbView.center.x - _minThumbView.center.x,
                                                                  2)];
                             }];
        }
        else{
            [_minThumbView setCenter:CGPointMake((_interval * index + 22 + 12), _minThumbView.center.y)];
            
            [_lineView setFrame:CGRectMake(_minThumbView.center.x - 34,
                                           0,
                                           _maxThumbView.center.x - _minThumbView.center.x,
                                           2)];
        }
    }
}

// 设置最大报价
- (void)setMaxThumb:(NSString *)newMaxThumb animated:(BOOL)animated{
    if (newMaxThumb){
        _maxPriceLabel.text = newMaxThumb;
        
        // 重新设置最大报价滑块坐标
        NSInteger index = (_tmpViewModel.maxSelectPrice - _tmpViewModel.minPrice)/_tmpViewModel.unit;
        
        if (animated){
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [_maxThumbView setCenter:CGPointMake((_interval * index + 22 + 12), _maxThumbView.center.y)];
                                 [_lineView setFrame:CGRectMake(_minThumbView.center.x - 34,
                                                                  0,
                                                                  _maxThumbView.center.x - _minThumbView.center.x,
                                                                  2)];
                             }];
        } else {
            [_maxThumbView setCenter:CGPointMake((_interval * index + 22 + 12), _maxThumbView.center.y)];
            [_lineView setFrame:CGRectMake(_minThumbView.center.x - 34,
                                           0,
                                           _maxThumbView.center.x - _minThumbView.center.x,
                                           2)];
        }
    }
}


#pragma  mark - getter
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, self.frame.size.width - 12, 32)];
        [_titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setText:@"区间选择"];
        [_titleLabel setTextColor:[UIColor colorWithRed:53/255.0 green:69/255.0 blue:24/255.0 alpha:1]];
    }
    
    return _titleLabel;
}

- (UILabel *)minPriceLabel{
    if (!_minPriceLabel) {
        _minPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 52, (self.frame.size.width-24)/2, 14)];
        [_minPriceLabel setFont:[UIFont systemFontOfSize:14]];
        [_minPriceLabel setTextColor:[UIColor blackColor]];
    }
    
    return _minPriceLabel;
}

- (UILabel *)maxPriceLabel{
    if (!_maxPriceLabel) {
        _maxPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 52, (self.frame.size.width-24)/2, 14)];
        [_maxPriceLabel setFont:[UIFont systemFontOfSize:14]];
        [_maxPriceLabel setTextColor:[UIColor blackColor]];
        [_maxPriceLabel setTextAlignment:NSTextAlignmentRight];
    }
    
    return _maxPriceLabel;
}

- (UIView *)lineBackgroundView{
    if (!_lineBackgroundView) {
        _lineBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(34, 95, self.frame.size.width - 68, 2)];
        [_lineBackgroundView setBackgroundColor:[UIColor grayColor]];
        _lineBackgroundView.layer.cornerRadius = 1;
        _lineBackgroundView.layer.masksToBounds = YES;
    }
    
    return _lineBackgroundView;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(self.minThumbView.center.x, 0, self.maxThumbView.center.x - self.minThumbView.center.x, 2)];
        [_lineView setBackgroundColor:[UIColor orangeColor]];
    }
    
    return _lineView;
}

- (UIView *)minThumbView{
    if (!_minThumbView) {
        _minThumbView = [[UIView alloc] initWithFrame:CGRectMake(12, 74, 44, 44)];
        _minThumbView.layer.cornerRadius = 22;
        _minThumbView.layer.masksToBounds = YES;
        _minThumbView.layer.borderWidth = 1;
        [_minThumbView setUserInteractionEnabled:YES];
        [_minThumbView setMultipleTouchEnabled:YES];
        [_minThumbView setBackgroundColor:[UIColor colorWithRed:11/255.0 green:134/255.0 blue:219/255.0 alpha:1]];
    }
    
    return _minThumbView;
}

- (UIView *)maxThumbView{
    if (!_maxThumbView) {
        _maxThumbView = [[UIView alloc] initWithFrame:CGRectMake(12, 74, 44, 44)];
        _maxThumbView.layer.cornerRadius = 22;
        _maxThumbView.layer.masksToBounds = YES;
        _maxThumbView.layer.borderWidth = 1;
        [_maxThumbView setUserInteractionEnabled:YES];
        [_maxThumbView setMultipleTouchEnabled:YES];
        [_maxThumbView setBackgroundColor:[UIColor colorWithRed:238/255.0 green:173/255.0 blue:75/255.0 alpha:1]];

    }
    
    return _maxThumbView;
}

- (UIView *)cursorView{
    if (!_cursorView) {
        _cursorView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 64, 56)];
        [_cursorView setBackgroundColor:[UIColor clearColor]];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 48)];
        [priceLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
        priceLabel.layer.cornerRadius = 5;
        [priceLabel setFont:[UIFont systemFontOfSize:16]];
        [priceLabel setTag:100];
        priceLabel.layer.masksToBounds = YES;
        [priceLabel setTextAlignment:NSTextAlignmentCenter];
        [priceLabel setTextColor:[UIColor whiteColor]];
        [_cursorView addSubview:priceLabel];
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(24, 42, 16, 16)];
        imageview.image = [[UIImage imageNamed:@"arrow"] imageWithTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
        [_cursorView addSubview:imageview];
        _cursorView.layer.anchorPoint = CGPointMake(0.5, 1);
        _cursorView.layer.masksToBounds = YES;
        
        [_cursorView setHidden:YES];
    }
    return _cursorView;
}

@end
