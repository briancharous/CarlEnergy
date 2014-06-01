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
    
    [self.scrollView setFrame:self.view.frame];
    
    //initialize graph views and graph maker
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat myWidth = 0;
    if (UIInterfaceOrientationIsPortrait([self interfaceOrientation])) {
        myWidth = 0;
    }
    else {
        myWidth = screenHeight / 2 - 160;
    }
    CGRect parentRect = CGRectMake(myWidth, 75, 320, 250);
    CGRect parentRect2 = CGRectMake(myWidth, 350, 320, 250);
    CGRect parentRect3 = CGRectMake(myWidth, 615, 320, 250);
    self.electricityLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.waterLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect2];
    self.steamLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect3];
    
    self.elecGraphMaker = [[CELineGraphMaker alloc] init];
    self.waterGraphMaker = [[CELineGraphMaker alloc] init];
    self.steamGraphMaker = [[CELineGraphMaker alloc] init];

    // set navbar title
    if (self.building) {
        [self.navigationItem setTitle:self.building.displayName];
    }
    
    // create graphs and add them to the scroll view
    self.elecLineGraph = [self.elecGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeElectricity forBuilding:self.building];
    self.waterLineGraph = [self.waterGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeWater forBuilding:self.building];
    self.steamLineGraph = [self.steamGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeSteam forBuilding:self.building];
    self.electricityLineGraphView.hostedGraph = self.elecLineGraph;
    [self.scrollView addSubview:self.electricityLineGraphView];
    self.waterLineGraphView.hostedGraph = self.waterLineGraph;
    [self.scrollView addSubview:self.waterLineGraphView];
    self.steamLineGraphView.hostedGraph = self.steamLineGraph;
    [self.scrollView addSubview:self.steamLineGraphView];
    
    // bring segmented control on top of graphs
    [self.view bringSubviewToFront:self.segmentedControl];
    
    // to enable scrolling
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 850)];

}

- (void)viewDidAppear:(BOOL)animated {
    [self.scrollView setFrame:self.view.frame];
    [self redrawForNewOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.elecGraphMaker.hostView removeFromSuperview];
    [self.waterGraphMaker.hostView removeFromSuperview];
    [self.steamGraphMaker.hostView removeFromSuperview];

    self.elecGraphMaker.hostView = nil;
    self.waterGraphMaker.hostView = nil;
    self.steamGraphMaker.hostView = nil;
}

-(IBAction)timeChanged:(UISegmentedControl *)sender
{

    // remove old graphs
//    [self.electricityLineGraphView.hostedGraph removeFromSuperlayer];
//    self.electricityLineGraphView.hostedGraph = nil;
//    [self.waterLineGraphView.hostedGraph removeFromSuperlayer];
////    [self.ele]
//    self.waterLineGraphView.hostedGraph = nil;
//    [self.steamLineGraphView.hostedGraph removeFromSuperlayer];
//    self.steamLineGraphView.hostedGraph = nil;
//    [self.electricityLineGraphView.hostedGraph remove]
//    self.elecLineGraph = nil;
//    self.waterLineGraph = nil;
//    self.steamLineGraph = nil;

    [self.elecGraphMaker requestDataOfType:kUsageTypeElectricity forBuilding:self.building forTimeScale:self.segmentedControl.selectedSegmentIndex];
    [self.waterGraphMaker requestDataOfType:kUsageTypeWater forBuilding:self.building forTimeScale:self.segmentedControl.selectedSegmentIndex];
    [self.steamGraphMaker requestDataOfType:kUsageTypeSteam forBuilding:self.building forTimeScale:self.segmentedControl.selectedSegmentIndex];
//    self.elecLineGraph = [self.elecGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeElectricity forBuilding:self.building];
//    self.electricityLineGraphView.hostedGraph = self.elecLineGraph;
//    self.waterLineGraph = [self.waterGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeWater forBuilding:self.building];
//    self.waterLineGraphView.hostedGraph = self.waterLineGraph;
//    self.steamLineGraph = [self.steamGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeSteam forBuilding:self.building];
//    self.steamLineGraphView.hostedGraph = self.steamLineGraph;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.scrollView setFrame:self.view.frame];
    
    // remove old graph views
    [self.elecGraphMaker.hostView removeFromSuperview];
    [self.waterGraphMaker.hostView removeFromSuperview];
    [self.steamGraphMaker.hostView removeFromSuperview];
    
    self.elecGraphMaker.hostView = nil;
    self.waterGraphMaker.hostView = nil;
    self.steamGraphMaker.hostView = nil;
    
    [self redrawForNewOrientation];
    
}

- (void) redrawForNewOrientation
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat myWidth = 0;
    if (UIInterfaceOrientationIsPortrait([self interfaceOrientation])) {
        myWidth = 0;
    }
    else {
        myWidth = screenHeight / 2 - 160;
    }
    CGRect parentRect = CGRectMake(myWidth, 75, 320, 250);
    CGRect parentRect2 = CGRectMake(myWidth, 350, 320, 250);
    CGRect parentRect3 = CGRectMake(myWidth, 615, 320, 250);
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
