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
    
    CEDataRetriever *retriever = [[CEDataRetriever alloc] init];
    [retriever setDelegate:self];
    
    // Maybe not needed after more content added:

    [self.scrollView setContentSize:self.view.frame.size];
    [self.scrollView setFrame:self.view.frame];
    [self makeTurbine];
    [self getElectricProductionAndUsage];
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
    windView = [[[NSBundle mainBundle] loadNibNamed:@"CEWindView" owner:self options:nil] objectAtIndex:0];
    [windView setFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 350)];
    [windView.producedLabel setText:@""];
    [windView.consumedLabel setText:@""];
    [self.scrollView addSubview:windView];
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


#pragma mark Data Retrieval
- (void)getElectricProductionAndUsage {
    // get wind production and main campus consumption
    // between now and one hour ago
    
    CEDataRetriever *windRetreiver = [[CEDataRetriever alloc] init];
    CEDataRetriever *electricRetreiver = [[CEDataRetriever alloc] init];
    CEDataRetriever *gasRetreiver = [[CEDataRetriever alloc] init];
    CEDataRetriever *fuelRetreiver = [[CEDataRetriever alloc] init];
    [windRetreiver setDelegate:self];
    [electricRetreiver setDelegate:self];
    [gasRetreiver setDelegate:self];
    [fuelRetreiver setDelegate:self];
    
    NSDate *now = [NSDate date];
    NSDate *oneHourAgo = [now dateByAddingTimeInterval:-60*60*24];
    
    gotWindProduction = NO;
    windProduction = @(0);
    dispatch_async(dispatch_queue_create("com.carlenergy.dashboard", NULL), ^ {
        [windRetreiver getTotalWindProductionWithStartTime:oneHourAgo endTime:now resolution:kResolutionHour];
    });
    
    gotElectricityUsage = NO;
    energyConsumption = @(0);
    dispatch_async(dispatch_queue_create("com.carlenergy.dashboard", NULL), ^ {
        [electricRetreiver getTotalCampusElectricityUsageWithStartTime:oneHourAgo endTime:now resolution:kResolutionHour];
    });
}

- (void)updateUsageData {
    if (!gotWindProduction || !gotElectricityUsage) {
        return;
    }

    NSString *producedString = [NSString stringWithFormat:@"%lu kWh produced", (long)[windProduction integerValue]];
   
    float percentageWind = [windProduction floatValue]/[energyConsumption floatValue] * 100;
    NSString *consumedString = [NSString stringWithFormat:@"%i%% campus energy from wind", (int)percentageWind];
    [[windView producedLabel] setText:producedString];
    [[windView consumedLabel] setText:consumedString];
}

#pragma mark CEDataRetreiverDelegate

- (void)retriever:(CEDataRetriever *)retreiver gotWindProduction:(NSArray *)production {
    float totalProduction = 0;
    for (CEDataPoint *point in production) {
        totalProduction += point.value * point.weight;
    }
    windProduction = @(totalProduction);
    gotWindProduction = YES;
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self updateUsageData];
    });
}

- (void)retriever:(CEDataRetriever *)retreiver gotCampusElectricityUsage:(NSArray *)usage {
    float totalUsage = 0;
    for (CEDataPoint *point in usage) {
        totalUsage += point.value * point.weight;
    }
    energyConsumption = @(totalUsage);
    gotElectricityUsage = YES;
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self updateUsageData];
    });
//    [self performSelectorOnMainThread:@selector(updateUsageData) withObject:nil waitUntilDone:NO];
}



@end
