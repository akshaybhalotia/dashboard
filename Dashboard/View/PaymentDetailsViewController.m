//
//  PaymentDetailsViewController.m
//  Dashboard
//
//  Created by Akshay Bhalotia on 16/02/16.
//  Copyright © 2016 Razorpay. All rights reserved.
//

#import "PaymentDetailsViewController.h"

@interface PaymentDetailsViewController () <PaymentFetcherProtocol> {
    PaymentFetcher *paymentFetcher;
    NSDateFormatter *dateFormatter;
}

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;

@end

@implementation PaymentDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd/MMM/yyyy hh:mm:ss a"];
    paymentFetcher = [PaymentFetcher new];
    paymentFetcher.delegate = self;
    
    [self fillViewData];
}

-(void)fillViewData {
    self.amountLabel.text = [NSString stringWithFormat:@"%.2f %@", self.payment.amount, self.payment.currency];
    self.statusLabel.text = self.payment.status;
    self.emailLabel.text = self.payment.email;
    NSDate *paymentDate = [NSDate dateWithTimeIntervalSince1970:self.payment.createdAt];
    self.dateTimeLabel.text = [dateFormatter stringFromDate:paymentDate];
}

- (IBAction)partialRefundPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Partial Refund" message:@"Enter amount:" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Amount";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *amountField = alert.textFields.firstObject;
        if (amountField.text.length && [amountField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
            [paymentFetcher refundPayment:self.payment.paymentID amount:[amountField.text floatValue]];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)fullRefundPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Full Refund" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [paymentFetcher refundPayment:self.payment.paymentID amount:self.payment.amount];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

-(void)didRefundPaymentWithError:(NSError *)error {
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hmmm" message:@"Payment refunded." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *done = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:done];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        });
        [paymentFetcher fetchPaymentInfoForPaymentId:self.payment.paymentID];
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

- (IBAction)capturePressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Capture" message:@"Enter amount:" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Amount";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *amountField = alert.textFields.firstObject;
        [paymentFetcher capturePayment:self.payment.paymentID amount:[amountField.text floatValue]];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

-(void)didCapturePaymentWithError:(NSError *)error {
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Yay!" message:@"Payment captured." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *done = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:done];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        });
        [paymentFetcher fetchPaymentInfoForPaymentId:self.payment.paymentID];
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

-(void)didFetchPaymentDetails:(Payment *)payment withError:(NSError *)error {
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            self.payment = payment;
            [self fillViewData];
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

@end
