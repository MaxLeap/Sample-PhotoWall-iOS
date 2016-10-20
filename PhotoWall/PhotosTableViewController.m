//
//  PhotosTableViewController.m
//  PhotoWall
//
//  Created by Sun Jin on 10/14/15.
//  Copyright © 2015 leap. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "PWTabBarController.h"
#import "PWImageViewController.h"
#import <MaxLeap/MaxLeap.h>
#import "PWPhotoCell.h"

@interface PhotosTableViewController ()
@property (nonatomic, strong) NSArray<MLObject *> *photos;
@end

@implementation PhotosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    
    [self.tableView registerClass:[PWPhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh];
}

- (void)signOut {
    [MLUser logOut];
    [(PWTabBarController *)self.tabBarController presentLoginViewControllerAnimated:YES];
}

- (void)showError:(NSError *)error {
    // error occurred
    NSString *message = [NSString stringWithFormat:@"code: %ld, %@", (long)error.code, error.localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)refresh {
    if (NO == self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height) animated:YES];
    }
    
    [self constructQuery:^(MLQuery *query, NSError *error) {
        if (error) {
            [self showError:error];
            [self.refreshControl endRefreshing];
        } else {
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    [self showError:error];
                } else {
                    self.photos = objects;
                    [self.tableView reloadData];
                }
                [self.refreshControl endRefreshing];
            }];
        }
    }];
}

- (void)constructQuery:(void (^)(MLQuery *query, NSError *error))block {
    if (!block) {
        return;
    }
    MLQuery *query = [MLQuery queryWithClassName:@"Photos"];
    if (self.region == PWPhotoRegion10Km) {
        // 返回结果会自动从近到远排序
        [MLGeoPoint geoPointForCurrentLocationInBackground:^(MLGeoPoint *geoPoint, NSError *error) {
            if (geoPoint) {
                [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:10];
            }
            block(error?nil:query, error);
        }];
    } else {
        [query orderByDescending:@"createdAt"];
        block(query, nil);
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.width *3/4 +54;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PWPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    MLObject *photo = self.photos[indexPath.row];
    [cell configureWithPhoto:photo];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PWPhotoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Create image info
    PWImageInfo *imageInfo = [[PWImageInfo alloc] init];
    imageInfo.image = cell.photoView.image;
    imageInfo.referenceRect = cell.photoView.frame;
    imageInfo.referenceView = cell.photoView.superview;
    imageInfo.referenceContentMode = cell.photoView.contentMode;
    imageInfo.referenceCornerRadius = cell.photoView.layer.cornerRadius;
    
    [PWImageViewController displayWithImageInfo:imageInfo fromViewController:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
