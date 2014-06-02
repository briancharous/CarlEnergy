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
    
    [self.scrollView setFrame:self.view.frame];
    
    
    //    pullToRefreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -50, self.scrollView.frame.size.width, 30)];
    [pullToRefreshLabel setText:@"Pull to refresh"];
    [self.scrollView addSubview:pullToRefreshLabel];
    [self.scrollView setBackgroundColor:[UIColor colorWithRed:248/255.0 green:242/255.0 blue:229/255.0 alpha:1]];
    self.dashboardViews = [[NSMutableArray alloc] init];
    
    // Refresh control doesn't really seem to work super well
    // weird jump when you pull down
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshSubviewsData) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:refreshControl];
    // make refresh control always on bottom
    [refreshControl.layer setZPosition:-1];
    [self setupDashboardViews];
    [self refreshSubviewsData];
    
    // add reorder button
    reorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reorderButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [reorderButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [reorderButton setTitle:@"Reorder Dashboard" forState:UIControlStateNormal];
    [reorderButton setShowsTouchWhenHighlighted:YES];
    [reorderButton addTarget:self action:@selector(presentReorderView) forControlEvents:UIControlEventTouchUpInside];

    // listen for new item added to dashboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllViews) name:@"new_pin" object:nil];
    
    // if it's an ipad, hook up the buildings button to show the buildings list in a popover
    // on the iphone it's managed in the storyboard
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.buildingsButton setTarget:self];
        [self.buildingsButton setAction:@selector(showBuildingsPopover)];
    }
}

- (void)showBuildingsPopover {
    if (!self.buildingsPopover) {
        CEBuildingsListTableViewController *buildingsList = [[UIStoryboard storyboardWithName:@"Main-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"buildingsList"];
        [buildingsList setDelegate:self];
        self.buildingsPopover = [[UIPopoverController alloc] initWithContentViewController:buildingsList];
    }
    [self.buildingsPopover setPopoverContentSize:CGSizeMake(300, self.view.frame.size.height)];
    [self.buildingsPopover presentPopoverFromBarButtonItem:self.buildingsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    // reload dashboard views in case user has pinned new building
    [self restartSubviewsAnimation];
    
    // relayout subviews
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
        curY += 10;
    }
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, curY+50)];
    
    [reorderButton setFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, 50)];
    [self.scrollView addSubview:reorderButton];
}

- (void)setupDashboardViews {
    NSArray *views = [[NSUserDefaults standardUserDefaults] arrayForKey:@"dashboard"];
    if (views == nil) {
        // create default views list
        // type 1 is the wind view, type 2 is elecricity view, type 0 is custom building
        views = @[@{@"type": @1}, @{@"type": @2}];
        [[NSUserDefaults standardUserDefaults] setObject:views forKey:@"dashboard"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    for (NSDictionary *dict in views) {
        NSInteger type = [[dict objectForKey:@"type"] intValue];
        switch (type) {
            case 1: {
                CEWindView *windView = [[CEWindView alloc] initWithFrame:CGRectZero];
                [windView setDelegate:self];
                [self.dashboardViews addObject:windView];
                break;
            }
            case 2: {
                CEElectricityUsageView *elecView = [[CEElectricityUsageView alloc] initWithFrame:CGRectZero];
                [self.dashboardViews addObject:elecView];
                [elecView setDelegate:self];
                break;
            }
            case 0: {
                // create mini building
                CEBuilding *b = nil;
                CEDataRetriever *r = [[CEDataRetriever alloc] init];
                NSArray *buildingsDictionaries = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"plist"]];
                for (NSDictionary *bdict in buildingsDictionaries) {
                    if ([[bdict objectForKey:@"displayName"] isEqualToString:[dict objectForKey:@"name"]]) {
                        b = [r buildingFromDictionary:bdict];
                        break;
                    }
                }
                r = nil;
                CEBuildingMiniView *mini = [[CEBuildingMiniView alloc] initWithFrame:CGRectZero];
                [mini setDelegate:self];
                [mini setBuilding:b];
                [self.dashboardViews addObject:mini];
                break;
            }
            default:
                break;
        }
    }
    

    for (CEDashboardItemView *view in self.dashboardViews) {
        [self.scrollView addSubview:view];
        [view restartAnimation];
    }
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

- (void)presentReorderView {
    CEDashboardReorderTableViewController *reorderVC = [[CEDashboardReorderTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [reorderVC setViews:[[NSUserDefaults standardUserDefaults] arrayForKey:@"dashboard"]];
    [reorderVC setDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:reorderVC];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController.navigationBar setTranslucent:YES];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

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
        // put some space between subviews
        curY += 10;
    }
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, curY+50)];
    [reorderButton setFrame:CGRectMake(0, curY, self.scrollView.frame.size.width, 50)];
    [self restartSubviewsAnimation];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    curOrientation = toInterfaceOrientation;
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

#pragma mark Dashboard reorder delegate
- (void)reorderViewDidFinish:(CEDashboardReorderTableViewController *)view {
    [self reloadAllViews];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // since the ipad modal doesn't take up the whole screen, manually invoke
        // view will appear to re-layout the list
        [self viewWillAppear:YES];
    }
}

- (void)reloadAllViews {
    [self.dashboardViews removeAllObjects];
    for (CEDashboardItemView *v in self.scrollView.subviews) {
        [v removeFromSuperview];
    }
    [self.scrollView addSubview:refreshControl];
    [self setupDashboardViews];
    [self refreshSubviewsData];
}

#pragma mark Buildings list delegate
- (void)buildingsList:(CEBuildingsListTableViewController *)list didSelectBuilding:(CEBuilding *)building {
    // if this is an ipad, the list is shown in a popover
    // hide the popover and push the detail view
    [self.buildingsPopover dismissPopoverAnimated:YES];
    CEBuildingDetailViewController *detailView = [[UIStoryboard storyboardWithName:@"Main-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"buildingDetailView"];
    [detailView setBuilding:building];
    [self.navigationController pushViewController:detailView animated:YES];
}


@end