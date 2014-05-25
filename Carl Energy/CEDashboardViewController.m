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
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"ic_dashboard_selected"]];
    
    CEDataRetriever *retriever = [[CEDataRetriever alloc] init];
    [retriever setDelegate:self];
    
    // Maybe not needed after more content added:
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];
    [self makePieChart];
    [self getElectricProducionAndUsage];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // undraw and redraw the graph
    [self.hostView removeFromSuperview];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    // Maybe not needed after more content added:
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];
    [self makePieChart];
}

#pragma mark Pie Chart functions

- (void)makePieChart
{
    // Create and assign the host view
    pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CGRect parentRect = CGRectMake(0, 60, self.scrollView.frame.size.width, 300);
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:parentRect];
    [self.scrollView setFrame:self.view.bounds];
    [self.scrollView addSubview:self.hostView];
    //NSLog(@"%@", self.scrollView.subviews);
    self.hostView.hostedGraph = pieChart;
    
    // Define the textStyle for the title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor darkGrayColor];
    textStyle.fontName = @"HelveticaNeue-Thin";
    textStyle.fontSize = 25.0f;
    
    // Set up the graph title
    pieChart.axisSet = nil;
    pieChart.title = @"Wind Production";
    pieChart.titleTextStyle = textStyle;
    pieChart.titleDisplacement = CGPointMake(0.0f, 60);
    CPTTheme *theme = [CPTTheme themeNamed:nil];
    [pieChart applyTheme:theme];
    
    // Create the plot
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource      = self;
    piePlot.pieRadius       = 100.0;
    piePlot.identifier      = @"Pie Chart 1";
    piePlot.startAngle      = M_PI_4;
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.centerAnchor    = CGPointMake(0.5, 0.5);
    piePlot.borderLineStyle = nil;
    piePlot.delegate        = self;
    [pieChart addPlot:piePlot];
    
    // Create the legend
    CPTLegend *myLegend = [CPTLegend legendWithGraph:pieChart];
    myLegend.numberOfColumns = 1;
    myLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    myLegend.borderLineStyle = [CPTLineStyle lineStyle];
    myLegend.cornerRadius = 5.0;
    pieChart.legend = myLegend;
    pieChart.legendAnchor = CPTRectAnchorBottomLeft;
    CGFloat legendPadding = (self.view.bounds.size.width / 16);
    pieChart.legendDisplacement = CGPointMake(legendPadding, 0.0);
    
    //TODO: Center graph on rotation to landscape
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
     return 2;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSLog(@"number for plot: %lu", (unsigned long)index);
    if ( index >= 2) {
        return nil;
    }
    
    switch (index) {
        case 0:
            return windProduction;
            break;
        case 1:
            return energyConsumption;
            break;
        default:
            break;
    }
    return @(0);
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor darkGrayColor];
    }
    
    float windValue = [windProduction floatValue];
    float elecValue = [energyConsumption floatValue];
    float totalEnergy = windValue + elecValue;
    NSString *labelValue = nil;
    
    // electric
    if (index == 0) {
        float elecPercent = elecValue / totalEnergy;
        labelValue = [NSString stringWithFormat:@"%0.2f units (%0.1f %%)", elecValue, (elecPercent * 100.0f)];
    }
    // wind
    else if (index == 1) {
        float windPercent = windValue / totalEnergy;
        labelValue = [NSString stringWithFormat:@"%0.2f units (%0.1f %%)", windValue, (windPercent * 100.0f)];
    }
    return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    if (index == 0) {
        return @"Consumption";
    }
    else if (index == 1) {
        return @"Wind Production";
    }
    return nil;
}

#pragma mark Data Retrieval
- (void)getElectricProducionAndUsage {
    // get wind production and main campus consumption
    // between now and one hour ago
    
    CEDataRetriever *windRetreiver = [[CEDataRetriever alloc] init];
    CEDataRetriever *electricRetreiver = [[CEDataRetriever alloc] init];
    [windRetreiver setDelegate:self];
    [electricRetreiver setDelegate:self];
    
    NSDate *now = [NSDate date];
    NSDate *oneHourAgo = [now dateByAddingTimeInterval:-60*60*24];
    
    gotWindProduction = NO;
    windProduction = @(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [windRetreiver getTotalWindProductionWithStartTime:oneHourAgo endTime:now resolution:kResolutionLive];
    });
    
    gotElectricityUsage = NO;
    energyConsumption = @(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [electricRetreiver getTotalCampusElectricityUsageWithStartTime:oneHourAgo endTime:now resolution:kResolutionLive];
    });
}

- (void)updatePieChart {
    if (!gotWindProduction || !gotElectricityUsage) {
        return;
    }
    
    [pieChart reloadData];
    NSLog(@"draw now!!!!");
    [pieChart.plotAreaFrame.plotArea setNeedsDisplay];
//    [pieChart performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

#pragma mark CEDataRetreiverDelegate

- (void)retriever:(CEDataRetriever *)retreiver gotWindProduction:(NSArray *)production {
    float totalProduction = 0;
    for (CEDataPoint *point in production) {
        totalProduction += point.value * point.weight;
    }
    windProduction = @(totalProduction);
    gotWindProduction = YES;
    [self updatePieChart];
}

- (void)retriever:(CEDataRetriever *)retreiver gotCampusElectricityUsage:(NSArray *)usage {
    float totalUsage = 0;
    for (CEDataPoint *point in usage) {
        totalUsage += point.value * point.weight;
    }
    energyConsumption = @(totalUsage);
    gotElectricityUsage = YES;
    [self performSelectorOnMainThread:@selector(updatePieChart) withObject:nil waitUntilDone:NO];
}



@end
