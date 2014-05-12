//
//  FirstViewController.m
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEBuildingsListTableViewController.h"

@interface CEBuildingsListTableViewController ()

@property NSMutableArray* dummyList;
@end

@implementation CEBuildingsListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageCache = [[NSCache alloc] init];

    // show spinner
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self setRefreshControl:refreshControl];
    [self loadInitialData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadInitialData {
    
    [self.refreshControl beginRefreshing];
    // scroll past top to show refresh control
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];

    CEDataRetriever *retreiver = [[CEDataRetriever alloc] init];
    [retreiver setDelegate:self];
    [NSThread detachNewThreadSelector:@selector(getBuildingsOnCampus) toTarget:retreiver withObject:nil];
//    [retreiver getBuildingsOnCampus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.buildings count];
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuildingName" forIndexPath:indexPath];
     CEBuilding *building = [self.buildings objectAtIndex:[indexPath row]];
     NSString *buildingName = [building displayName];
     cell.textLabel.text = buildingName;
     cell.imageView.bounds = CGRectMake(0, 0, 50, 50);
     UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     spinner.center = CGPointMake(CGRectGetMidX(cell.imageView.bounds), CGRectGetMaxY(cell.imageView.bounds));
     
     // try to get image from caceh
     UIImage *cachedImage = [self.imageCache objectForKey:building.imageURL];
     if (cachedImage == nil) {
         // remove image
         [cell.imageView setImage:nil];
         
         // async get the image
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
             NSString *imageURL = [building imageURL];
             NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
             if (imageData) {
                 UIImage *image = [UIImage imageWithData:imageData];
                 if (image) {
                     dispatch_async(dispatch_get_main_queue(), ^ {
                         UITableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                         if (updateCell) {
                             [updateCell.imageView setImage:image];
                             [updateCell setNeedsLayout];
                             // save image in cache
                             [self.imageCache setObject:image forKey:imageURL];
                         }
                     });
                 }
             }
         });
     }
     else {
         // set the imageview's image from the cache
         [cell.imageView setImage:cachedImage];
     }
  
     return cell;
 }

# pragma mark Data Retriever Delegate

- (void)retreiver:(CEDataRetriever *)retreiver gotBuildings:(NSArray *)buildings {
    [self setBuildings:buildings];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    [self.refreshControl removeFromSuperview];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
