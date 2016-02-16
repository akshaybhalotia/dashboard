//
//  PaymentListViewController.m
//  Dashboard
//
//  Created by Pranav Gupta on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import "PaymentListViewController.h"

#import "PaymentFetcher.h"
#import "PaymentListCell.h"

static NSString *const kCellIdentifier = @"paymentCell";

@interface PaymentListViewController () <PaymentFetcherProtocol> {
	NSArray *payments;
	NSDateFormatter *dateFormatter;
	PaymentFetcher *paymentFetcher;
}

@end

@implementation PaymentListViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	
	payments = [NSArray array];
	dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"dd/MMM/yyyy hh:mm:ss a"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	paymentFetcher = [PaymentFetcher new];
	paymentFetcher.delegate = self;
	[paymentFetcher fetchPaymentListFrom:0 upto:0 numberOfRecords:0 skipRecords:0];
}

-(void)didFetchPaymentList:(NSArray *)list withError:(NSError *)error {
	if (!error) {
		dispatch_async(dispatch_get_main_queue(), ^() {
			payments = list;
			[self.tableView reloadData];
		});
	} else {
		dispatch_async(dispatch_get_main_queue(), ^() {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"Something went wrong. Reason: %@", [error.userInfo objectForKey:@"reason"] ? [error.userInfo objectForKey:@"reason"] : [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *done = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
				[self.navigationController dismissViewControllerAnimated:YES completion:nil];
			}];
			[alert addAction:done];
			[self.navigationController presentViewController:alert animated:YES completion:nil];
		});
	}
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if ([payments count]) {
		rows = [payments count];
	}
	return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

	Payment *payment = [payments objectAtIndex:indexPath.row];
	
	cell.amountLabel.text = [NSString stringWithFormat:@"%.2f %@", payment.amount, payment.currency];
	cell.statusLabel.text = payment.status;
	cell.emailLabel.text = payment.email;
	NSDate *paymentDate = [NSDate dateWithTimeIntervalSince1970:payment.createdAt];
	cell.dateTimeLabel.text = [dateFormatter stringFromDate:paymentDate];
	
	return cell;
}

@end
