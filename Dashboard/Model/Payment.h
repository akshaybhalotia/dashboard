//
//  Payment.h
//  Dashboard
//
//  Created by Pranav Gupta on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject

@property NSString *paymentID;
@property float amount;
@property NSString *currency;
@property NSString *status;
@property NSString *email;
@property NSTimeInterval createdAt;

@end
