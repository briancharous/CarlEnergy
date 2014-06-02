//
//  CEDashboardReorderTableViewController.h
//  Carl Energy
//
//  Created by Brian Charous on 6/1/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CEDashboardReorderDelegate;


@interface CEDashboardReorderTableViewController : UITableViewController


@property NSArray *views;
@property (nonatomic, assign) id <CEDashboardReorderDelegate> delegate;

- (void)done;

@end

@protocol CEDashboardReorderDelegate <NSObject>

- (void)reorderViewDidFinish:(CEDashboardReorderTableViewController *)view;

@end
