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


@interface CEDashboardViewController : UIViewController <CEDashboardItemViewDelegate, UIScrollViewDelegate> {

    NSInteger numRefreshedViews;
    UILabel *pullToRefreshLabel;
    UIRefreshControl *refreshControl;
    BOOL isRefreshing;
    UIInterfaceOrientation curOrientation;
}

- (void)restartSubviewsAnimation;
- (void)refreshSubviewsData;
- (void)setupDashboardViews;

@property IBOutlet UIScrollView *scrollView;
@property NSMutableArray *dashboardViews;
//@property UIView *mainView;

@end
