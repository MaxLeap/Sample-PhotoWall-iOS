//
//  PWPhotoCell.m
//  PhotoWall
//
//  Created by Sun Jin on 10/15/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import "PWPhotoCell.h"

@interface PWPhotoCell ()

@property (nonatomic, strong) MLObject *photo;
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UILabel *titileLabel;

@end

@implementation PWPhotoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.photoView.clipsToBounds = YES;
        self.photoView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.photoView];
        
        self.titileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titileLabel.backgroundColor = [UIColor clearColor];
        self.titileLabel.textColor = [UIColor darkTextColor];
        [self.contentView addSubview:self.titileLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = width * 3/4;
    self.photoView.frame = CGRectMake(0, 0, width, height);
    self.titileLabel.frame = CGRectMake(8, height, width -16, 44);
}

- (void)prepareForReuse {
    self.photo = nil;
    self.photoView.image = nil;
    self.titileLabel.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithPhoto:(MLObject *)photo {
    self.photo = photo;
    self.titileLabel.text = photo[@"title"];
    MLFile *imageFile = photo[@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if ([photo isEqual:self.photo]) {
            self.photoView.image = [UIImage imageWithData:data];
            [self setNeedsLayout];
        }
    }];
}

@end
