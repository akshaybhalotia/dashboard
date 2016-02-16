//
//  PaymentListViewController.m
//  Dashboard
//
//  Created by Pranav Gupta on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import "PaymentListViewController.h"
#import "PaymentListCell.h"

static NSString *const kCellIdentifier = @"paymentCell";

@implementation PaymentListViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	return cell;
}

@end
