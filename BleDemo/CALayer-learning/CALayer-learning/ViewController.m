//
//  ViewController.m
//  CALayer-learning
//
//  Created by 周腾飞 on 2019/6/3.
//  Copyright © 2019年 周腾飞. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "TestViewController.h"



@interface ViewController ()


@property (nonatomic, strong) UIButton *button;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.button];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.width.height.mas_equalTo(100);
    }];
    
    short int a = 0x1122;     // 十进制为4386，其中11称为高子节(即15~8位)。
    char b = ((char *)&a)[0]; // 取变量a的低子节(即7~0位)
    printf("----------------------%x\n", b);          // 输出22代表编译器为小端模式
    
    NSLog(@">>>>>>>>%d", IsBigEndian() ? TRUE : FALSE);
    
}


BOOL IsBigEndian()
{
    int a = 0x1234;
    char b =  *(char *)&a;  //通过将int强制类型转换成char单字节，通过判断起始存储位置。即等于 取b等于a的低地址部分
    if( b == 0x12)
    {
        return TRUE;
    }
    return FALSE;
}

- (void)buttonClick:(UIButton *)btn
{
    TestViewController *vc = [[TestViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (UIButton *)button
{
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setTitle:@"按钮" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}


@end

