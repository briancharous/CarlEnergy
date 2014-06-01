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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartBladeAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"ic_dashboard_selected"]];

//  Refresh control doesn't really seem to work in a scroll view
//    refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(getElectricProductionAndUsage) forControlEvents:UIControlEventValueChanged];
//    [self.scrollView addSubview:refreshControl];
    
    [self.scrollView setContentSize:self.view.frame.size];
    [self.scrollView setFrame:self.view.frame];
    [self makeTurbine];
    [self makeUsageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self restartBladeAnimation];
}

- (void)restartBladeAnimation {
    if (windView) {
        [windView startBladeAnimation];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    // undraw and redraw the graph
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    // Maybe not needed after more content added:
//    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];
//    [self makePieChart];

}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (windView) {
        
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
    }
}

- (void)makeTurbine {
    windView = [[CEWindView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 350)];
    [self.scrollView addSubview:windView];
    [windView refreshData];
}

- (void)makeUsageView {
    elecView = [[CEElectricityUsageView alloc] initWithFrame:CGRectMake(0, 350, self.scrollView.bounds.size.width, 200)];
    [self.scrollView addSubview:elecView];
    [elecView refreshData];
}
//
//- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
//    return 2;
//}
//
//- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
//    
//    switch (index) {
//        case 0:
//            return [windProduction floatValue];
//            break;
//        case 1:
//            return [energyConsumption floatValue];
//            break;
//        default:
//            break;
//    }
//    return 0;
//}
//
//- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
//    switch (index) {
//        case 0:
//            return [NSString stringWithFormat:@"%@", windProduction];
//            break;
//        case 1:
//            return [NSString stringWithFormat:@"%@", energyConsumption];
//            break;
//        default:
//            break;
//    }
//    return @"";
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}










@end
