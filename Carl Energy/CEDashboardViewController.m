//
//  SecondViewController.m
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//



#import "CEDashboardViewController.h"

#define statusBarHeight 20


@implementation CEDashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // listen for when the app enters the foreground to start animating the
    // wind turbine blades
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartSubviewsAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"ic_dashboard_selected"]];
    
    [self.scrollView setFrame:self.view.frame];
    [self.scrollView setDelegate:self];
    contentOffsetZero = statusBarHeight + self.navigationController.navigationBar.frame.size.height;
//    pullToRefreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -50, self.scrollView.frame.size.width, 30)];
    [pullToRefreshLabel setText:@"Pull to refresh"];
    [self.scrollView addSubview:pullToRefreshLabel];
    self.dashboardViews = [[NSMutableArray alloc] init];
    
    // create the wind usage view and electricity usage views
    NSInteger curY = 0;
    CEWindView *windView = [[CEWindView alloc] initWithFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [CEWindView preferredHeight])];
    [windView setDelegate:self];
    [self.dashboardViews addObject:windView];
    curY += [CEWindView preferredHeight];
    CEElectricityUsageView *elecView = [[CEElectricityUsageView alloc] initWithFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, [CEElectricityUsageView preferredHeight])];
    [self.dashboardViews addObject:elecView];
    [elecView setDelegate:self];
    curY += [CEElectricityUsageView preferredHeight];
    
    
    // setup the scroll view
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, curY)];
    for (CEDashboardItemView *view in self.dashboardViews) {
        [self.scrollView addSubview:view];
        [view restartAnimation];
    }

//  Refresh control doesn't really seem to work in a scroll view
//    refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(getElectricProductionAndUsage) forControlEvents:UIControlEventValueChanged];
//    [self.scrollView addSubview:refreshControl];
    
    //set length of scrollview 
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 350)];
    [self.scrollView setFrame:self.view.frame];
    [self makeTurbine];
}

- (void)viewWillAppear:(BOOL)animated {
    [self restartSubviewsAnimation];
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
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 100)];
//    [self makePieChart];

}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    if (windView) {
    
        // NO IDEA WHAT IS GOING ON HERE
        /*
        [UIView animateWithDuration:duration animations:^ {
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
                NSLog(@"landscape");
                [windView setFrame:CGRectMake(windView.frame.origin.x, windView.frame.origin.y, self.scrollView.bounds.size.width, 200)];
            }
            else {
                NSLog(@"portrait");
                [windView setFrame:CGRectMake(windView.frame.origin.x, windView.frame.origin.y, self.scrollView.bounds.size.width, 350)];
            }
        }];
        */
//    }
}

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
