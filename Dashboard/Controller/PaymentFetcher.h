//
//  PaymentFetcher.h
//  Dashboard
//
//  Created by Pranav Gupta on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"

@protocol PaymentFetcherProtocol;

@interface PaymentFetcher : NSObject

@property (weak) id<PaymentFetcherProtocol> delegate;

-(void)fetchPaymentListFrom:(NSTimeInterval)fromTimestamp
					   upto:(NSTimeInterval)toTimestamp
			numberOfRecords:(int)records
				skipRecords:(int)skip;

@end

@protocol PaymentFetcherProtocol <NSObject>

-(void)didFetchPaymentList:(NSArray *)list withError:(NSError *)error;

@end