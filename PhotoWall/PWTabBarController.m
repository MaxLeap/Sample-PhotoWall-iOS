//
//  PWTabBarController.m
//  PhotoWall
//
//  Created by Sun Jin on 10/14/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import "PWTabBarController.h"
#import <MaxLeap/MaxLeap.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "PWPhotoEditViewController.h"

@interface PWTabBarController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@end

@implementation PWTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.barTintColor = [UIColor colorWithRed:0.137f green:0.137f blue:0.184f alpha:1.00f];
    
    [self addCameraButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![MLUser currentUser]) {
        [self presentLoginViewControllerAnimated:NO];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    NSString *segueId = @"showLoginViewWithoutAnimation";
    if (animated) {
        segueId = @"showLoginView";
    }
    [self performSegueWithIdentifier:segueId sender:nil];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    [self addCameraButton];
}

- (void)addCameraButton {
    NSInteger cameraButtonTag = 1001;
    [[self.tabBar viewWithTag:cameraButtonTag] removeFromSuperview];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalImage = [UIImage imageNamed:@"camera_normal"];
    [cameraButton setImage:normalImage forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cameraButton.tag = cameraButtonTag;
    CGFloat height = self.tabBar.frame.size.height;
    cameraButton.frame = CGRectMake((self.tabBar.frame.size.width - height)/2, 0, height, height);
    [self.tabBar addSubview:cameraButton];
}

- (void)cameraButtonAction:(UIButton *)cameralButton {
    if ([self canStartCameraController]) {
        [self showCamera];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Camera not available" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (BOOL)canStartCameraController {
    BOOL isCameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    NSArray *cameraMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    return isCameraAvailable && [cameraMediaTypes containsObject:(NSString *)kUTTypeImage];
}

- (void)showCamera {
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    
    cameraController.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        cameraController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        cameraController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    
    cameraController.allowsEditing = YES;
    cameraController.showsCameraControls = YES;
    cameraController.delegate = self;
    
    [self presentViewController:cameraController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    PWPhotoEditViewController *viewController = [[PWPhotoEditViewController alloc] initWithImage:image];
    [picker pushViewController:viewController animated:YES];
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
