//
//  CEBuildingDetailViewController.m
//  Carl Energy
//
//  Created by Michelle Chen on 5/10/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEBuildingDetailViewController.h"
#include <stdlib.h>

@implementation CEBuildingDetailViewController

NSString *  const CEClear       = @"clear";
NSString *  const CEElectric       = @"elec";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize graph makers
    self.elecGraphMaker = [[CELineGraphMaker alloc] init];
    self.waterGraphMaker = [[CELineGraphMaker alloc] init];
    self.steamGraphMaker = [[CELineGraphMaker alloc] init];

    // set navbar title
    if (self.building) {
        [self.navigationItem setTitle:self.building.displayName];
    }
    
    // initialize graphs
    self.elecLineGraph = [self.elecGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeElectricity forBuilding:self.building];
    self.waterLineGraph = [self.waterGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeWater forBuilding:self.building];
    self.steamLineGraph = [self.steamGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeSteam forBuilding:self.building];
    
    // bring segmented control on top of graphs
    [self.view bringSubviewToFront:self.segmentedControl];
    
    // to enable scrolling
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 850)];
    
    UIBarButtonItem *pinButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_pin"] style:UIBarButtonItemStylePlain target:self action:@selector(pinToDashboard)];
    [self.navigationItem setRightBarButtonItem:pinButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.scrollView setFrame:self.view.frame];
    [self redrawForNewOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
    // deallocate graph views to save memory
    [self.electricityLineGraphView removeFromSuperview];
    [self.waterLineGraphView removeFromSuperview];
    [self.steamLineGraphView removeFromSuperview];
    
    self.electricityLineGraphView = nil;
    self.waterLineGraphView = nil;
    self.steamLineGraphView = nil;
}

- (void)pinToDashboard {
//    [self.navigationItem setPrompt:[NSString stringWithFormat:@"%@ pinned to Dashboard", self.building.displayName]];
    UILabel *confirmationLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    [confirmationLabel setText:[NSString stringWithFormat:@"%@ added to Dashboard", self.building.displayName]];
    [confirmationLabel setBackgroundColor:[UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.8]];
    [confirmationLabel setTextColor:[UIColor whiteColor]];
    [confirmationLabel setNumberOfLines:2];
    [confirmationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:confirmationLabel];
    [UIView animateWithDuration:.25 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        // 64 is height of nav bar + status bar
        [confirmationLabel setFrame:CGRectMake(0, 64, self.view.frame.size.width, confirmationLabel.frame.size.height)];
    } completion:nil];
//    __weak CEBuildingDetailViewController *blockSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,  2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
        [UIView animateWithDuration:.25 animations:^ {
            [confirmationLabel setFrame:CGRectMake(0, 0, self.view.frame.size.width, confirmationLabel.frame.size.height)];
        }completion:^ (BOOL finished) {
            [confirmationLabel removeFromSuperview];
        }];
    });
    NSMutableArray *dashboardItems = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"dashboard"] mutableCopy];
    [dashboardItems addObject:@{@"type": @0, @"name": self.building.displayName}];
    [[NSUserDefaults standardUserDefaults] setObject:dashboardItems forKey:@"dashboard"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"new_pin" object:self userInfo:nil];
}

-(IBAction)timeChanged:(UISegmentedControl *)sender
{
    [self.elecGraphMaker requestDataOfType:kUsageTypeElectricity forBuilding:self.building forTimeScale:self.segmentedControl.selectedSegmentIndex];
    [self.waterGraphMaker requestDataOfType:kUsageTypeWater forBuilding:self.building forTimeScale:self.segmentedControl.selectedSegmentIndex];
    [self.steamGraphMaker requestDataOfType:kUsageTypeSteam forBuilding:self.building forTimeScale:self.segmentedControl.selectedSegmentIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // remove the current graphs so they can be redrawn after rotation
    [self.electricityLineGraphView removeFromSuperview];
    [self.waterLineGraphView removeFromSuperview];
    [self.steamLineGraphView removeFromSuperview];
    self.electricityLineGraphView = nil;
    self.waterLineGraphView = nil;
    self.steamLineGraphView = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.scrollView setFrame:self.view.bounds];
    [self redrawForNewOrientation];
}
- (void) redrawForNewOrientation
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGRect parentRect = CGRectMake(0, 75, self.scrollView.frame.size.width, 250);
    CGRect parentRect2 = CGRectMake(0, 350, self.scrollView.frame.size.width, 250);
    CGRect parentRect3 = CGRectMake(0, 615, self.scrollView.frame.size.width, 250);
    self.electricityLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.electricityLineGraphView.hostedGraph = self.elecLineGraph;
    self.waterLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect2];
    self.waterLineGraphView.hostedGraph = self.waterLineGraph;
    self.steamLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect3];
    self.steamLineGraphView.hostedGraph = self.steamLineGraph;
    
    [self.scrollView addSubview:self.electricityLineGraphView];
    [self.scrollView addSubview:self.waterLineGraphView];
    [self.scrollView addSubview:self.steamLineGraphView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
