//
//  PhotosTableViewController.h
//  PhotoWall
//
//  Created by Sun Jin on 10/14/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, PWPhotoRegion) {
    PWPhotoRegionGlobal,
    PWPhotoRegion10Km
};

@interface PhotosTableViewController : UITableViewController

@property (nonatomic) PWPhotoRegion region;

@end
