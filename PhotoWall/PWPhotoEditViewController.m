//
//  PWPhotoEditViewController.m
//  PhotoWall
//
//  Created by Sun Jin on 10/14/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import "PWPhotoEditViewController.h"
#import "UIImage+Resize.h"
#import "SVProgressHUD.h"
#import <MaxLeap/MaxLeap.h>

@interface PWPhotoEditViewController ()
<UITextFieldDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskId;

@end

@implementation PWPhotoEditViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NSObject

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = [aImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
        self.bgTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupView {
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width-16, 44)];
    self.titleTextField.returnKeyType = UIReturnKeyDone;
    self.titleTextField.borderStyle = UITextBorderStyleNone;
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add a caption..." attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    self.titleTextField.textColor = [UIColor whiteColor];
    self.titleTextField.delegate = self;
    [self.view addSubview:self.titleTextField];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.width)];
    imageView.image = self.image;
    [self.view addSubview:imageView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [cancelButton sizeToFit];
    cancelButton.frame = CGRectMake(10, self.view.frame.size.height -50, cancelButton.bounds.size.width, cancelButton.bounds.size.height);
    [self.view addSubview:cancelButton];
    
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [publishButton setImage:[UIImage imageNamed:@"ok_normal"] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(publishAction:) forControlEvents:UIControlEventTouchUpInside];
    [publishButton sizeToFit];
    publishButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - publishButton.bounds.size.height/2 -1);
    [self.view addSubview:publishButton];
}

- (void)publishAction:(id)sender {
    [self.titleTextField resignFirstResponder];
    [self postImage];
}

- (void)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ()

- (void)showError:(NSError *)error {
    // error occurred
    NSString *message = [NSString stringWithFormat:@"code: %ld, %@", (long)error.code, error.localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)postImage {
    [SVProgressHUD show];
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
    }];
    NSLog(@"Requested background expiration task with id %lu for Anypic photo publish", (unsigned long)self.bgTaskId);
    NSString *caption = self.titleTextField.text;
    
    [self getCurrentLocationAndImageFileRepresentationWithCompletion:^(MLGeoPoint *geoPoint, MLFile *imageFile, NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
            [self showError:error];
            [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
        } else {
            MLObject *photo = [MLObject objectWithClassName:@"Photos"];
            if (caption) {
                photo[@"title"] = caption;
            }
            photo[@"location"] = geoPoint;
            photo[@"image"] = imageFile;
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD dismiss];
                if (succeeded) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self showError:error];
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
            }];
        }
    }];
}

- (void)getCurrentLocationAndImageFileRepresentationWithCompletion:(void (^)(MLGeoPoint *geoPoint, MLFile *imageFile, NSError *error))completion {
    if (!completion) {
        return;
    }
    [MLGeoPoint geoPointForCurrentLocationInBackground:^(MLGeoPoint *geoPoint, NSError *error) {
        if (error) {
            completion(nil, nil, error);
        } else {
            [self saveImageFileWithCompletion:^(MLFile *file, NSError *error) {
                if (error) {
                    completion(geoPoint, nil, error);
                } else {
                    completion(geoPoint, file, nil);
                }
            }];
        }
    }];
}

- (void)saveImageFileWithCompletion:(void(^)(MLFile *file, NSError *error))completion {
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.8f);
    if (!imageData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil, [NSError errorWithDomain:@"imageFileSaveDomain" code:1 userInfo:@{NSLocalizedDescriptionKey:@"No image data!"}]);
            }
        });
        return;
    }
    
    MLFile *photoFile = [MLFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completion) {
            completion(succeeded?photoFile:nil, error);
        }
    }];
}

@end
