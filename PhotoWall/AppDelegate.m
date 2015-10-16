//
//  AppDelegate.m
//  PhotoWall
//
//  Created by Sun Jin on 10/14/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <MaxLeap/MaxLeap.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MaxLeap setApplicationId:@"561c74ada5ff7f00018300bc" clientKey:@"M2dJS01MdmRXZ2x1YkhLdWRhV3ZDQQ" site:MLSiteCN];
    
    [self setUIAppearence];
    
    return YES;
}

- (void)setUIAppearence {
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor greenColor]} forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -12)];
    
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.137f green:0.137f blue:0.184f alpha:1.00f];
    [UINavigationBar appearance].titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"BradleyHandITCTT-Bold" size:24], NSForegroundColorAttributeName:[UIColor whiteColor]};
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
