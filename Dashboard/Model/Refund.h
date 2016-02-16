//
//  Refund.h
//  Dashboard
//
//  Created by Akshay Bhalotia on 17/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Refund : NSObject

@property NSString *paymentID;
@property NSString *refundID;
@property float amount;
@property NSString *currency;
@property NSTimeInterval createdAt;

@end
