//
//  MLLoginViewController.m
//  MaxLeap
//
//  Created by Sun Jin on 8/5/14.
//  Copyright (c) 2014 iLegendsoft. All rights reserved.
//

#import "SignUpViewController.h"
#import "NSString+emailValidation.h"
#import "SVProgressHUD.h"
#import <MaxLeap/MaxLeap.h>

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameTextField.borderStyle = UITextBorderStyleNone;
    self.usernameTextField.layer.borderWidth = 0.5;
    self.usernameTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.layer.borderWidth = .5;
    self.passwordTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.passwordAgainTextField.borderStyle = UITextBorderStyleNone;
    self.passwordAgainTextField.layer.borderWidth = .5;
    self.passwordAgainTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    self.usernamePromtLabel.text = nil;
    self.passwordPromtLabel.text = nil;
    self.passwordAgainPromtLabel.text = nil;
}

- (BOOL)checkTextField:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameTextField]) {
        if (![textField.text isValidEmail]) {
            self.usernamePromtLabel.text = @"Please enter a valid email address.";
            return NO;
        }
    } else if ([textField isEqual:self.passwordTextField]) {
        if (textField.text.length == 0) {
            self.passwordPromtLabel.text = @"You cannot leave this empty";
            return NO;
        }
    } else if ([textField isEqual:self.passwordAgainTextField]) {
        
        NSString *password = self.passwordTextField.text;
        NSString *passwordAgain = self.passwordAgainTextField.text;
        
        if (passwordAgain.length == 0) {
            self.passwordAgainPromtLabel.text = @"Please confirm the password.";
            return NO;
        }
        
        if (NO == [password isEqualToString:passwordAgain]) {
            self.passwordAgainPromtLabel.text = @"These passwords don't match. Try Again?";
            return NO;
        }
    }
    
    return YES;
}

- (IBAction)signup:(id)sender {
    
    if ( ! [self checkTextField:self.usernameTextField]) {
        return;
    }
    if ( ! [self checkTextField:self.passwordTextField]) {
        return;
    }
    if ( ! [self checkTextField:self.passwordAgainTextField]) {
        return;
    }
    
    [SVProgressHUD show];
    
    MLUser *user = [MLUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.usernameTextField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:[NSString stringWithFormat:@"Code: %ld\n%@", (long)error.code, error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        self.usernamePromtLabel.text = nil;
    } else if ([textField isEqual:self.passwordTextField]) {
        self.passwordPromtLabel.text = nil;
    } else if ([textField isEqual:self.passwordAgainTextField]) {
        self.passwordAgainPromtLabel.text = nil;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self checkTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTextField]) {
        [self.passwordAgainTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordAgainTextField]) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
