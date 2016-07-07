//
//  WZSlider.h
//  WZSlider
//
//  Created by liwang.zhao on 16/7/6.
//  Copyright © 2016年 LandOfMystery. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface WZSliderViewModel : NSObject<NSCopying>

@property (nonatomic, assign) NSInteger maxPrice;       //区间最大价格
@property (nonatomic, assign) NSInteger minPrice;       //区间最小价格
@property (nonatomic, assign) NSInteger maxSelectPrice; //选中的最大价格
@property (nonatomic, assign) NSInteger minSelectPrice; //选中的最小价格
@property (nonatomic, assign) NSInteger unit;           //区间最小单位

@end

// 筛选完成
typedef void (^complete)(WZSliderViewModel* viewModel);


@interface WZSlider : UIView

@property (nonatomic, strong) WZSliderViewModel *viewModel;         // 数据
@property (nonatomic, copy) complete completeBlock;                 // 筛选完成调用

//清空
- (void)reset;

@end
