//
//  ViewController.m
//  WZSlider
//
//  Created by liwang.zhao on 16/7/6.
//  Copyright © 2016年 LandOfMystery. All rights reserved.
//

#import "ViewController.h"
#import "WZSlider.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    WZSlider *slider = [[WZSlider alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 138)];
    WZSliderViewModel *viewModel = [[WZSliderViewModel alloc] init];
    viewModel.maxSelectPrice = 1000;
    viewModel.maxPrice = 1000;
    viewModel.minSelectPrice = 0;
    viewModel.minPrice = 0;
    viewModel.unit = 10;
    [slider setViewModel:viewModel];
    
    [self.view addSubview:slider];
    [slider setTag:100];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(56, 350, self.view.frame.size.width - 112, 44)];
    [clearButton setTitle:@"重置" forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setBackgroundColor:[UIColor colorWithRed:235/255.0 green:69/255.0 blue:165/255.0 alpha:1]];
    clearButton.layer.cornerRadius = 4;
    clearButton.layer.masksToBounds = YES;
    [self.view addSubview:clearButton];
}

- (void)reset{
    WZSlider *slider = [self.view viewWithTag:100];
    [slider reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
