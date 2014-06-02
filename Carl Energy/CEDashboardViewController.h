//
//  SecondViewController.h
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEDataRetriever.h"
#import "CEWindView.h"
#import "CEElectricityUsageView.h"
#import "CEBuildingMiniView.h"
#import "CEDashboardReorderTableViewController.h"


@interface CEDashboardViewController : UIViewController <CEDashboardItemViewDelegate, UIScrollViewDelegate, CEDashboardReorderDelegate> {

    NSInteger numRefreshedViews;
    UILabel *pullToRefreshLabel;
    UIRefreshControl *refreshControl;
    BOOL isRefreshing;
    UIInterfaceOrientation curOrientation;
    UIButton *reorderButton;
}

- (void)restartSubviewsAnimation;
- (void)refreshSubviewsData;
- (void)setupDashboardViews;
- (void)presentReorderView;
- (void)reloadAllViews;

@property IBOutlet UIScrollView *scrollView;
@property NSMutableArray *dashboardViews;

@end
