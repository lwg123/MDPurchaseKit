//
//  MDPurchase.h
//  MDPurchaseKit
//
//  Created by weiguang on 2019/6/28.
//  Copyright © 2019 duia. All rights reserved.
//  内购功能管理类

#import <Foundation/Foundation.h>

#define kProductXXB_A @"pth_A"    //1学币
#define kProductXXB_B @"pth_B"    //18学币
#define kProductXXB_C @"pth_C"    //218学币
#define kProductXXB_D @"pth_D"    //998学币
#define kProductXXB_E @"pth_E"    //1298学币
#define kProductXXB_F @"pth_F"    //2298学币
#define kProductXXB_G @"pth_G"    //3298学币
#define kProductXXB_H @"pth_H"    //4498学币
#define kProductXXB_I @"pth_I"    //6498学币
#define kProductXXB_J @"pth_J"    //8学币
#define kProductXXB_K @"pth_K"    //45学币
#define kProductXXB_L @"pth_L"    //98学币
#define kProductXXB_M @"pth_M"    //12学币
#define kProductXXB_N @"pth_N"    //6学币

//充值金额枚举
typedef NS_ENUM(NSInteger ,iapProductType) {
    iapProduct1 = 1,
    iapProduct6 = 6,
    iapProduct8 = 8,
    iapProduct12 = 12,
    iapProduct18 = 18,
    iapProduct45 = 45,
    iapProduct98 = 98,
    iapProduct218 = 218,
    iapProduct998 = 998,
    iapProduct1298 = 1298,
    iapProduct2298 = 2298,
    iapProduct3298 = 3298,
    iapProduct4498 = 4498,
    iapProduct6498 = 6498,
};


NS_ASSUME_NONNULL_BEGIN

@protocol PurchaseResultDelegate <NSObject>

/**
 内购成功代理
 
 @param receipt 苹果收据、用于服务器验证支付结果
 */
- (void)successfulDAPurchaseWithReceipt:(NSString *)receipt;

/**
 内购失败代理
 
 @param errorCode 错误码
 @param errorMessage 错误信息
 */
- (void)failedDAPurchaseWithError:(NSInteger)errorCode message:(NSString*)errorMessage;

@end


@interface MDPurchase : NSObject

@property (nonatomic,weak) id<PurchaseResultDelegate> delegate;

/**
 注意一定要用单例来初始化，否则会重复添加监听
 */
+ (instancetype)shareInstance;

/**
 判断应用是否支持内购
 
 @return YES为支持 NO不支持
 */
+ (BOOL)canMakePayProduct;

/**
 商品购买请求
 
 @param type 商品的充值的类型
 @return return value description
 */
- (BOOL)requestProductWithProductType:(iapProductType)type;

@end

NS_ASSUME_NONNULL_END
