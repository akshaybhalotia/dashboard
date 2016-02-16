//
//  PaymentFetcher.h
//  Dashboard
//
//  Created by Pranav Gupta on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"
#import "Refund.h"
#import "CapturedPayment.h"

@protocol PaymentFetcherProtocol;

@interface PaymentFetcher : NSObject

@property (weak) id<PaymentFetcherProtocol> delegate;

-(void)fetchPaymentListFrom:(NSTimeInterval)fromTimestamp
					   upto:(NSTimeInterval)toTimestamp
			numberOfRecords:(int)records
				skipRecords:(int)skip;
-(void)refundPayment:(NSString *)paymentId
              amount:(float)amount;
-(void)capturePayment:(NSString *)paymentId
              amount:(float)amount;
-(void)fetchPaymentInfoForPaymentId:(NSString *)paymentId;

@end

@protocol PaymentFetcherProtocol <NSObject>

@optional
-(void)didFetchPaymentList:(NSArray *)list withError:(NSError *)error;
-(void)didRefundPaymentWithError:(NSError *)error;
-(void)didCapturePaymentWithError:(NSError *)error;
-(void)didFetchPaymentDetails:(Payment *)payment withError:(NSError *)error;

@end