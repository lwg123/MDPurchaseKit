//
//  MDPurchase.m
//  MDPurchaseKit
//
//  Created by weiguang on 2019/6/28.
//  Copyright © 2019 duia. All rights reserved.
//

#import "MDPurchase.h"
#import <StoreKit/StoreKit.h>

@interface MDPurchase()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property (nonatomic,strong)SKProductsRequest * productsRequest;/**<商品请求*/
@property (nonatomic,strong) SKProductsRequest * currentRequest;
@property (nonatomic,strong) NSTimer * requestTimer;

@end

@implementation MDPurchase

static MDPurchase *purchase = nil;
+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        purchase = [[self alloc] init];
    });
    
    return purchase;
}

- (instancetype)init{
    self = [super init];
    if(self){
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - 苹果内购逻辑处理
+ (BOOL)canMakePayProduct{
    BOOL res = NO;
    if([SKPaymentQueue canMakePayments]){
        res = YES;
    }
    return res;
}

- (BOOL)requestProductWithProductType:(iapProductType)type{
    BOOL res = NO;
    NSString * productIdentifer;
    switch (type) {
        case iapProduct1:{
            productIdentifer = kProductXXB_A;
        }
        break;
        case iapProduct18:{
            productIdentifer = kProductXXB_B;
        }
        break;
        case iapProduct218:{
            productIdentifer = kProductXXB_C;
        }
        break;
        case iapProduct998:{
            productIdentifer = kProductXXB_D;
        }
        break;
        case iapProduct1298:{
            productIdentifer = kProductXXB_E;
        }
        break;
        case iapProduct2298:{
            productIdentifer = kProductXXB_F;
        }
        break;
        case iapProduct3298:{
            productIdentifer = kProductXXB_G;
        }
        break;
        case iapProduct4498:{
            productIdentifer = kProductXXB_H;
        }
        break;
        case iapProduct6498:{
            productIdentifer = kProductXXB_I;
        }
        break;
        case iapProduct8:{
            productIdentifer = kProductXXB_J;
        }
        break;
        case iapProduct45:{
            productIdentifer = kProductXXB_K;
        }
        break;
        case iapProduct98:{
            productIdentifer = kProductXXB_L;
        }
        break;
        case iapProduct12:{
            productIdentifer = kProductXXB_M;
        }
        break;
        case iapProduct6:{
            productIdentifer = kProductXXB_N;
        }
        break;
        
        default:
        break;
    }
    //    productIdentifer = @"com.duiaApp.AAC_VIPAWV";
    NSSet * set = [NSSet setWithObjects:productIdentifer, nil];
    _productsRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:set];
    _productsRequest.delegate = self;
    
    self.currentRequest = _productsRequest;
    [self startRequestTimer];
    [_productsRequest start];
    
    return res;
}

- (void)startRequestTimer{
    if(self.requestTimer){
        [self.requestTimer invalidate];
        self.requestTimer = nil;
    }
    
    self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestCancel) userInfo:nil repeats:NO];
    
}

- (void)requestCancel{
    
    if(self.currentRequest){
        [self.currentRequest cancel];
        if ([_delegate respondsToSelector:@selector(failedDAPurchaseWithError:message:)]){
            [_delegate failedDAPurchaseWithError:0 message:@"请求超时，请检查网络后重试"];
        }
        NSLog(@"取消内购请求");
    }
    
}

#pragma mark- <-----------  SKProductsRequestDelegate协议方法  ----------->
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        SKPayment * PaymentRequest = [SKPayment paymentWithProduct:product];
        
        [[SKPaymentQueue defaultQueue] addPayment:PaymentRequest];
    }
    
}

#pragma mark- <-----------  SKRequestDelegate协议方法(SKProductsRequestDelegate的父协议)  ----------->
//反馈信息结束
- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"requestDidFinish--%@",request);
    
    // 停止加载动画
    
}

//反馈信息 错误提示
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError--%@--%@",error,request);
    if([_delegate respondsToSelector:@selector(failedDAPurchaseWithError:message:)]){
        [_delegate failedDAPurchaseWithError:error.code message:@"无法连接到iTunesStore"];
    }
}


#pragma mark- <-----------  SKPaymentTransactionObserver观察者协议方法  ----------->
/// 更新了事务
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:{
                //内购处理中
                
            }
            break;
            case SKPaymentTransactionStateFailed:{
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                if(transaction.error.code != SKErrorPaymentCancelled) // 非取消型失败
                {
                    if([_delegate respondsToSelector:@selector(failedDAPurchaseWithError:message:)]){
                        [_delegate failedDAPurchaseWithError:transaction.error.code message:transaction.error.description];
                    }
                }
                else // 取消内购
                {
                    if([_delegate respondsToSelector:@selector(failedDAPurchaseWithError:message:)]){
                        [_delegate failedDAPurchaseWithError:transaction.error.code message:@"取消购买"];
                    }
                }
            }
            break;
            case SKPaymentTransactionStateDeferred:{
                //
            }
            break;
            case SKPaymentTransactionStatePurchased:{
                //内购购买成功
                
                NSData * receiptData =  [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"购买成功长度%zd",receiptData.length);
                if (!receiptData) {
                    NSLog(@"获取支付凭证为空");
                    return;
                }

                receiptData = transaction.transactionReceipt;
                
                if([self.delegate respondsToSelector:@selector(successfulDAPurchaseWithReceipt:isRestore:)]){
                    [self.delegate successfulDAPurchaseWithReceipt:[self encodingReceipt:receiptData]];
                }
            }
            break;
            case SKPaymentTransactionStateRestored:{
                //回复购买---新对啊为消耗性商品 不支持恢复购买
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
            default:
            break;
        }
    }
}

- (void)completeTransactionWith:(SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    NSLog(@"内购取消");
    
    if([_delegate respondsToSelector:@selector(failedDAPurchaseWithError:message:)]){
        SKPaymentTransaction * transaction = transactions.firstObject;
        
    }
    
    
}

//内购回调
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    
}

#pragma mark- <-----------  回执UTF8编码  ----------->
/// 对回执UTF8编码
- (NSString *)encodingReceipt:(NSData *)receiptData{
    
    NSString *receipt = [[NSString alloc]initWithData:receiptData encoding:NSUTF8StringEncoding];
    
    
    
    NSString * encodingString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                      (CFStringRef)receipt,
                                                                                                      NULL,
                                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                      kCFStringEncodingUTF8));
    
    
    return encodingString;
}




- (void)dealloc{
    //移除监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}



@end
