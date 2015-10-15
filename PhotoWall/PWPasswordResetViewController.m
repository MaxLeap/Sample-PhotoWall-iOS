//
//  PWPasswordResetViewController.m
//  PhotoWall
//
//  Created by Sun Jin on 10/15/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import "PWPasswordResetViewController.h"
#import "NSString+emailValidation.h"
#import <MaxLeap/MLUser.h>

@interface PWPasswordResetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation PWPasswordResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.emailTextField.borderStyle = UITextBorderStyleNone;
    self.emailTextField.layer.borderWidth = .5;
    self.emailTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneAction:(id)sender {
    NSString *email = self.emailTextField.text;
    
    if (![email isValidEmail]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please enter a valid email address" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [MLUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        NSString *title = nil;
        NSString *msg = nil;
        if (succeeded) {
            title = @"Password Reset Link has been sent";
            msg = @"We've emailed you instructions. Please go to your inbox and click the link inside to reset your password.";
        } else {
            if (error.code == kMLErrorUserNotFound) {
                msg = @"That e-mail address doesn't have an associated user account. Are you sure you've registered?";
            } else {
                msg = error.localizedDescription;
            }
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
