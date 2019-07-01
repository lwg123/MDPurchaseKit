//
//  ViewController.m
//  MDPurchaseKit
//
//  Created by weiguang on 2019/6/28.
//  Copyright © 2019 duia. All rights reserved.
//

#import "ViewController.h"
#import "MDPurchase.h"

@interface ViewController ()<PurchaseResultDelegate>
/**当前充值类型*/
@property (nonatomic,assign)int  currentRechargeType;
@property (nonatomic,strong) MDPurchase *purchase;
/**当前充值的苹果收据*/
@property (nonatomic,copy)NSString * currentReceipt;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    self.purchase = [MDPurchase shareInstance];
    self.purchase.delegate = self;
}

- (void)setup {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [btn setTitle:@"点击购买1学币" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buyVIP) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:btn];
}


- (void)buyVIP {
    self.currentRechargeType = 0;
    iapProductType type = iapProduct1;
    
    self.currentRechargeType = type;
    
    // 根据产品类型从苹果请求产品信息(请求不到的话则证明没有该标记表示的产品)
    [self.purchase requestProductWithProductType:type];
    
}

#pragma mark - 内购完成代理
- (void)successfulDAPurchaseWithReceipt:(NSString *)receipt {
    NSLog(@"苹果充值成功");
    self.currentReceipt = receipt;
    
    // 请求后台更新学币
    [self requestDuiaXueBiRecharge];
}

- (void)failedDAPurchaseWithError:(NSInteger)errorCode message:(NSString *)errorMessage {
    NSLog(@"苹果充值失败");
    if(![errorMessage hasPrefix:@"此时您没有权限"]&&![errorMessage isEqualToString:@"取消购买"]){
        
        if(errorMessage.length>100){
            errorMessage = [errorMessage substringToIndex:100];
        }
        NSRange range = [errorMessage rangeOfString:@"无法连接到 iTunes"];
        if(range.location !=NSNotFound){
            errorMessage = @"无法连接到 iTunes Store";
        }
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"购买失败" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    
}

#pragma mark- <--------  收到回执请求后台更新学币  ------->
- (void)requestDuiaXueBiRecharge {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"购买成功" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end
