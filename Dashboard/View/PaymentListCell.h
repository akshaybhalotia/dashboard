//
//  PaymentListCell.h
//  Dashboard
//
//  Created by Pranav Gupta on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@end
