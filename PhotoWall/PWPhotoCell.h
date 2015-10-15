//
//  PWPhotoCell.h
//  PhotoWall
//
//  Created by Sun Jin on 10/15/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MaxLeap/MaxLeap.h>

@interface PWPhotoCell : UITableViewCell

- (void)configureWithPhoto:(MLObject *)photo;

@end
