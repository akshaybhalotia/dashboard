//
//  PaymentFetcher.m
//  Dashboard
//
//  Created by Pranav Gupta on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import "PaymentFetcher.h"

#import "AFNetworking.h"

static NSString *const PUBLIC_KEY = @"rzp_test_K2AsUEhLAvCUej";
static NSString *const SECRET = @"CoX0Zrb81Rw7kO2b8PsTu0Ht";

static NSString *const BASE_URL = @"https://api.razorpay.com/v1/";

static NSString *const PAYMENT_LIST = @"payments";
static NSString *const PAYMENT_DETAILS = @"payments/%@";
static NSString *const REFUND = @"payments/%@/refund";
static NSString *const CAPTURE = @"payments/%@/capture";

static NSString *const kFrom = @"from";
static NSString *const kTo = @"to";
static NSString *const kCount = @"count";
static NSString *const kSkip = @"skip";

static NSString *const kItems = @"items";
static NSString *const kId = @"id";
static NSString *const kAmount = @"amount";
static NSString *const kCurrency = @"currency";
static NSString *const kStatus = @"status";
static NSString *const kEmail = @"email";
static NSString *const kCreatedAt = @"created_at";
static NSString *const kPaymentId = @"payment_id";

@interface PaymentFetcher ()

@property AFHTTPSessionManager *manager;

@end

@implementation PaymentFetcher

-(instancetype)init {
	if (self = [super init]) {
		self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
		self.manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
		[self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		self.manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
	}
	return self;
}

-(void)fetchPaymentListFrom:(NSTimeInterval)fromTimestamp
					   upto:(NSTimeInterval)toTimestamp
			numberOfRecords:(int)records
				skipRecords:(int)skip {
	[self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:PUBLIC_KEY
																   password:SECRET];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if (fromTimestamp) {
		[params setValue:@(fromTimestamp) forKey:kFrom];
	}
	if (toTimestamp) {
		[params setValue:@(toTimestamp) forKey:kTo];
	}
	if (records) {
		[params setValue:@(records) forKey:kCount];
	}
	if (skip) {
		[params setValue:@(skip) forKey:kSkip];
	}
	[self.manager GET:PAYMENT_LIST parameters:(params ? params : nil) progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
		NSDictionary *result = (NSDictionary *)responseObject;
		if (result) {
			NSArray *items = [result objectForKey:kItems];
			NSMutableArray *list = [NSMutableArray array];
			for (NSDictionary *item in items) {
				Payment *payment = [Payment new];
				payment.paymentID = [item objectForKey:kId];
				payment.amount = [[item objectForKey:kAmount] floatValue];
				payment.currency = [item objectForKey:kCurrency];
				payment.status = [item objectForKey:kStatus];
				payment.email = [item objectForKey:kEmail];
				payment.createdAt = [[item objectForKey:kCreatedAt] doubleValue];
				[list addObject:payment];
			}
			[self.delegate didFetchPaymentList:list withError:nil];
		} else {
			NSError *error = [NSError errorWithDomain:@"dashboard" code:-1 userInfo:@{@"reason": @"Empty response"}];
			[self.delegate didFetchPaymentList:nil withError:error];
		}
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		[self.delegate didFetchPaymentList:nil withError:error];
	}];
	[self.manager.requestSerializer clearAuthorizationHeader];
}

-(void)refundPayment:(NSString *)paymentId amount:(float)amount {
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:PUBLIC_KEY
                                                                   password:SECRET];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (amount) {
        [params setValue:@(amount) forKey:kAmount];
    }
    [self.manager POST:[NSString stringWithFormat:REFUND, paymentId] parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        if (result) {
            Refund *payment = [Refund new];
            payment.refundID = [result objectForKey:kId];
            payment.paymentID = [result objectForKey:kPaymentId];
            payment.amount = [[result objectForKey:kAmount] floatValue];
            payment.currency = [result objectForKey:kCurrency];
            payment.createdAt = [[result objectForKey:kCreatedAt] doubleValue];
            [self.delegate didRefundPaymentWithError:nil];
        } else {
            NSError *error = [NSError errorWithDomain:@"dashboard" code:-1 userInfo:@{@"reason": @"Empty response"}];
            [self.delegate didRefundPaymentWithError:error];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.delegate didRefundPaymentWithError:error];
    }];
    [self.manager.requestSerializer clearAuthorizationHeader];
}

-(void)capturePayment:(NSString *)paymentId amount:(float)amount {
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:PUBLIC_KEY
                                                                   password:SECRET];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (amount) {
        [params setValue:@(amount) forKey:kAmount];
    }
    [self.manager POST:[NSString stringWithFormat:CAPTURE, paymentId] parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        if (result) {
            CapturedPayment *payment = [CapturedPayment new];
            payment.paymentID = [result objectForKey:kPaymentId];
            payment.amount = [[result objectForKey:kAmount] floatValue];
            payment.currency = [result objectForKey:kCurrency];
            payment.createdAt = [[result objectForKey:kCreatedAt] doubleValue];
            [self.delegate didCapturePaymentWithError:nil];
        } else {
            NSError *error = [NSError errorWithDomain:@"dashboard" code:-1 userInfo:@{@"reason": @"Empty response"}];
            [self.delegate didCapturePaymentWithError:error];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.delegate didCapturePaymentWithError:error];
    }];
    [self.manager.requestSerializer clearAuthorizationHeader];
}

-(void)fetchPaymentInfoForPaymentId:(NSString *)paymentId {
    [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:PUBLIC_KEY
                                                                   password:SECRET];
    [self.manager GET:[NSString stringWithFormat:PAYMENT_DETAILS, paymentId] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        if (result) {
            Payment *payment = [Payment new];
            payment.paymentID = [result objectForKey:kId];
            payment.amount = [[result objectForKey:kAmount] floatValue];
            payment.currency = [result objectForKey:kCurrency];
            payment.status = [result objectForKey:kStatus];
            payment.email = [result objectForKey:kEmail];
            payment.createdAt = [[result objectForKey:kCreatedAt] doubleValue];
            [self.delegate didFetchPaymentDetails:payment withError:nil];
        } else {
            NSError *error = [NSError errorWithDomain:@"dashboard" code:-1 userInfo:@{@"reason": @"Empty response"}];
            [self.delegate didFetchPaymentDetails:nil withError:error];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.delegate didFetchPaymentDetails:nil withError:error];
    }];
    [self.manager.requestSerializer clearAuthorizationHeader];
}

@end
