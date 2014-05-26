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
    CGRect parentRect = CGRectMake(0, 75, 320, 250);
    self.electricityLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect];
    CGRect parentRect2 = CGRectMake(0, 325, 320, 250);
    self.waterLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect2];
    CGRect parentRect3 = CGRectMake(0, 575, 320, 250);
    self.steamLineGraphView = [[CPTGraphHostingView alloc] initWithFrame:parentRect3];
    
    self.elecGraphMaker = [[CELineGraphMaker alloc] init];
    self.waterGraphMaker = [[CELineGraphMaker alloc] init];
    self.steamGraphMaker = [[CELineGraphMaker alloc] init];

    // set navbar title
    if (self.building) {
        [self.navigationItem setTitle:self.building.displayName];
    }
    
    // create graphs and add them to the scroll view
    CPTGraph *elecLineGraph = [self.elecGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeElectricity forBuilding:self.building];
    CPTGraph *waterLineGraph = [self.waterGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeWater forBuilding:self.building];
    CPTGraph *steamLineGraph = [self.steamGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeSteam forBuilding:self.building];
    self.electricityLineGraphView.hostedGraph = elecLineGraph;
    [self.scrollView addSubview:self.electricityLineGraphView];
    self.waterLineGraphView.hostedGraph = waterLineGraph;
    [self.scrollView addSubview:self.waterLineGraphView];
    self.steamLineGraphView.hostedGraph = steamLineGraph;
    [self.scrollView addSubview:self.steamLineGraphView];
    
    // to enable scrolling
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 800)];

}

-(IBAction)timeChanged:(UISegmentedControl *)sender
{
    CPTGraph *elecLineGraph = [self.elecGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeElectricity forBuilding:self.building];
    self.electricityLineGraphView.hostedGraph = elecLineGraph;
    CPTGraph *waterLineGraph = [self.waterGraphMaker makeLineGraphForTime:self.segmentedControl.selectedSegmentIndex forUsage:kUsageTypeWater forBuilding:self.building];
    self.waterLineGraphView.hostedGraph = waterLineGraph;
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
