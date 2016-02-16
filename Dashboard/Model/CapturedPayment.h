//
//  CapturedPayment.h
//  Dashboard
//
//  Created by Akshay Bhalotia on 17/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CapturedPayment : NSObject

@property NSString *paymentID;
@property float amount;
@property NSString *currency;
@property NSString *status;
@property NSString *email;
@property NSTimeInterval createdAt;

@end
