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

@protocol CEBuildingsListControllerDelegate;

@interface CEBuildingsListTableViewController : UITableViewController <CEDataRetrieverDelegate>

@property (nonatomic, assign) id <CEBuildingsListControllerDelegate> delegate;
@property NSArray *buildings;

@end


@protocol CEBuildingsListControllerDelegate <NSObject>

-(void)buildingsList:(CEBuildingsListTableViewController *)list didSelectBuilding:(CEBuilding *)building;

@end