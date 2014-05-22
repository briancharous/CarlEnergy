//
//  FirstViewController.h
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEDataRetriever.h"
#import "CEBuilding.h"

@interface CEBuildingsListTableViewController : UITableViewController <CEDataRetrieverDelegate>

@property NSArray *buildings;

@end
