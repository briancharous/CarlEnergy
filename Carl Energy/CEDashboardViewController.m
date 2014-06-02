//
//  SecondViewController.m
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//



#import "CEDashboardViewController.h"


@implementation CEDashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // listen for when the app enters the foreground to start animating the
    // wind turbine blades
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartSubviewsAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    
//    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"ic_dashboard_selected"]];
    
    [self.scrollView setFrame:self.view.frame];
    
//    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    //    pullToRefreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -50, self.scrollView.frame.size.width, 30)];
    [pullToRefreshLabel setText:@"Pull to refresh"];
    [self.scrollView addSubview:pullToRefreshLabel];
    self.dashboardViews = [[NSMutableArray alloc] init];
    
    // create the wind usage view and electricity usage views
    NSInteger curY = 0;
    CEWindView *windView = [[CEWindView alloc] initWithFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [CEWindView preferredHeightForPortrait])];
    [windView setDelegate:self];
    [self.dashboardViews addObject:windView];
    curY += [CEWindView preferredHeightForPortrait];
    CEElectricityUsageView *elecView = [[CEElectricityUsageView alloc] initWithFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [CEElectricityUsageView preferredHeightForPortrait])];
    [self.dashboardViews addObject:elecView];
    [elecView setDelegate:self];
    curY += [CEElectricityUsageView preferredHeightForPortrait];
    
    
    // setup the scroll view
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, curY)];
    for (CEDashboardItemView *view in self.dashboardViews) {
        [self.scrollView addSubview:view];
//        [self.mainView addSubview:view];
        [view restartAnimation];
    }
//    [self.scrollView addSubview:self.mainView];
    [self refreshSubviewsData];
    
    // Refresh control doesn't really seem to work super well
    // weird jump when you pull down
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshSubviewsData) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:refreshControl];
    // make refresh control always on bottom
    [refreshControl.layer setZPosition:-1];
}

- (void)viewWillAppear:(BOOL)animated {
    [self restartSubviewsAnimation];
    NSInteger curY = 0;
    for (CEDashboardItemView *view in self.dashboardViews) {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            [view setFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [view preferredHeightForPortrait])];
            curY += [view preferredHeightForPortrait];
        }
        else {
            [view setFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [view preferredHeightForLandscape])];
            curY += [view preferredHeightForLandscape];
        }
    }
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, curY)];
}

- (void)restartSubviewsAnimation {
    for (CEWindView *view in self.dashboardViews) {
        [view restartAnimation];
    }
}

- (void)refreshSubviewsData {
    // keep track of the number of views that have refreshed their data so far
    numRefreshedViews = 0;
    if (!isRefreshing) {
        isRefreshing = YES;
        for (CEWindView *view in self.dashboardViews) {
            [view refreshData];
        }
    }
    [refreshControl beginRefreshing];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //    // undraw and redraw the graph
    //    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    //    // Maybe not needed after more content added:
    //    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];
    //    [self makePieChart];
    
//    [self.mainView setFrame:CGRectMake(0,0,self.scrollView.frame.size.width, 480)];

    [self.scrollView setFrame:self.view.frame];
    NSInteger curY = 0;
    for (CEDashboardItemView *view in self.dashboardViews) {
        if (UIInterfaceOrientationIsPortrait(curOrientation)) {
            [UIView animateWithDuration:.25 animations:^ {
                [view setFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [view preferredHeightForPortrait])];
            }];
            curY += [view preferredHeightForPortrait];
        }
        else {
            [UIView animateWithDuration:.25 animations:^ {
                [view setFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [view preferredHeightForLandscape])];
            }];
            curY += [view preferredHeightForLandscape];
        }
    }
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, curY)];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    curOrientation = toInterfaceOrientation;
}
//
//    NSInteger curY = 0;
//    for (CEDashboardItemView *view in self.dashboardViews) {
//        [UIView animateWithDuration:duration animations:^ {
//            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [view preferredHeightForLandscape])];
//            }
//            else {
//                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [view preferredHeightForPortrait])];
//            }
//        }];
//        curY += [view preferredHeightForPortrait];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Dashboard view delegate
- (void)dashboardItemViewRefreshedData:(CEDashboardItemView *)view {
    numRefreshedViews++;
    if (numRefreshedViews == [self.dashboardViews count]) {
        isRefreshing = NO;
        [refreshControl endRefreshing];
    }
}


@end