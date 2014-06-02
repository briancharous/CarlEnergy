//
//  CEDashboardReorderTableViewController.m
//  Carl Energy
//
//  Created by Brian Charous on 6/1/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEDashboardReorderTableViewController.h"

@interface CEDashboardReorderTableViewController ()

@end

@implementation CEDashboardReorderTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)done {
    [[NSUserDefaults standardUserDefaults] setObject:self.views forKey:@"dashboard"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate reorderViewDidFinish:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [self.tableView setEditing:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.views count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSDictionary *dict = [self.views objectAtIndex:[indexPath row]];
    NSInteger type = [[dict objectForKey:@"type"] intValue];
    switch (type) {
        case 1: {
            [cell.textLabel setText:@"Wind Production"];
            break;
        }
        case 2: {
            [cell.textLabel setText:@"Campus Electricity"];
            break;
        }
        case 0: {
            // create mini building
            [cell.textLabel setText:[dict objectForKey:@"name"]];
            break;
        }
        default:
            break;
    }

    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.views];
        [temp removeObjectAtIndex:indexPath.row];
        self.views = [NSArray arrayWithArray:temp];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSInteger fromIndex = fromIndexPath.row;
    NSInteger toIndex = toIndexPath.row;
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.views];
    [temp exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    self.views = [NSArray arrayWithArray:temp];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    // allow moving wind view and electricity view but not deletion
    NSDictionary *dict = [self.views objectAtIndex:[indexPath row]];
    NSInteger type = [[dict objectForKey:@"type"] intValue];
    switch (type) {
        case 1: {
            return UITableViewCellEditingStyleNone;
            break;
        }
        case 2: {
            return UITableViewCellEditingStyleNone;
            break;
        }
        case 0: {
            return UITableViewCellEditingStyleDelete;
            break;
        }
        default:
            break;
    }
    return UITableViewCellEditingStyleNone;
}

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
