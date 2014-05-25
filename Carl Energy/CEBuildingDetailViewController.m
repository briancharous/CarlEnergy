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

    // set title
    if (self.building) {
        [self.navigationItem setTitle:self.building.displayName];
    }

    CEDataRetriever *retriever = [[CEDataRetriever alloc] init];
    [retriever setDelegate:self];
    // placeholder code:
    self.dataForElectricityChart = [[NSMutableArray alloc] init];
//    for (int i = 1; i <= 24; i++) {
//        [self.dataForElectricityChart addObject:@10];
//    }
    [self timeChanged:nil];
    [self makeLineGraph:self.segmentedControl.selectedSegmentIndex];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];

}

- (void)requestDataOfType:(UsageType)type forTimeScale:(CETimeScale)timeScale {
    // get some dummy data to test if the request works
    CEDataRetriever *retreiver = [[CEDataRetriever alloc] init];
    [retreiver setDelegate:self];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd+HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSDate *previous;
    Resolution resolution;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *x = axisSet.xAxis;
    switch (timeScale) {
        case kTimeScaleDay:
            previous = [now dateByAddingTimeInterval:-60*60*24];
            resolution = kResolutionHour;
            x.title = @"Hour";
            break;
        case kTimeScaleWeek:
            previous = [now dateByAddingTimeInterval:-60*60*24*7];
            resolution = kResolutionDay;
            x.title = @"Day";
            break;
        case kTimeScaleMonth:
            previous = [now dateByAddingTimeInterval:-60*60*24*30];
            resolution = kResolutionDay;
            x.title = @"Day";
            break;
        case kTimeScaleYear:
            previous = [now dateByAddingTimeInterval:-60*60*24*365];
            resolution = kResolutionMonth;
            x.title = @"Month";
            break;
        default:
            break;
    }
    
    // TODO: cancel request if another one is in progress
    if (!retreiver.requestInProgress) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            [retreiver getUsage:kUsageTypeElectricity ForBuilding:self.building startTime:previous endTime:now resolution:resolution];
        });
    }
}

-(IBAction)timeChanged:(UISegmentedControl *)sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self requestDataOfType:kUsageTypeElectricity forTimeScale:kTimeScaleDay];
            break;
        case 1:
            [self requestDataOfType:kUsageTypeElectricity forTimeScale:kTimeScaleWeek];
            break;
        case 2:
            [self requestDataOfType:kUsageTypeElectricity forTimeScale:kTimeScaleMonth];
            break;
        case 3:
            [self requestDataOfType:kUsageTypeElectricity forTimeScale:kTimeScaleYear];
            break;
        default:
            break;
    }
}

// TODO: subclass this entire method into a graphMaker
// TOOO: make this use real data
-(void)makeLineGraph:(NSInteger)timeframeIndex
{
    // Create and assign the host view
    self.electricityLineGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CGRect parentRect = CGRectMake(0, 80, self.scrollView.frame.size.width,250);
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
//    [self.segmentedControl setFrame:self.scrollView.bounds];
    [self.scrollView setFrame:self.view.bounds];
    [self.scrollView addSubview:self.hostView];
    self.hostView.hostedGraph = self.electricityLineGraph;
    
    // Define the textStyle for the title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor darkGrayColor];
    textStyle.fontName = @"HelveticaNeue-Thin";
    textStyle.fontSize = 25.0f;
    
    // Make title
    NSString *title = @"Electricity Usage";
    self.electricityLineGraph.title = title;
    self.electricityLineGraph.titleTextStyle = textStyle;
    //lineGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    self.electricityLineGraph.titleDisplacement = CGPointMake(0.0f, 40.0f);
    
    // Set plot area padding
    [self.electricityLineGraph.plotAreaFrame setPaddingLeft:35.0f];
    [self.electricityLineGraph.plotAreaFrame setPaddingBottom:150.0f];
    
    // Create plot
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.electricityLineGraph.defaultPlotSpace;
    CPTScatterPlot *elecPlot = [[CPTScatterPlot alloc] init];
    elecPlot.dataSource = self;
    //elecPlot.identifier = elec;
    CPTColor *elecColor = [CPTColor redColor];
    [self.electricityLineGraph addPlot:elecPlot toPlotSpace:plotSpace];
    
    // Configure plot space??
    //[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:elecPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    // Do line style stuff?
    CPTMutableLineStyle *lineStyle = [elecPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.5;
    lineStyle.lineColor = elecColor;
    elecPlot.dataLineStyle = lineStyle;
    CPTMutableLineStyle *elecSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    elecSymbolLineStyle.lineColor = elecColor;
    CPTPlotSymbol *elecSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    elecSymbol.fill = [CPTFill fillWithColor:elecColor];
    elecSymbol.lineStyle = elecSymbolLineStyle;
    elecSymbol.size = CGSizeMake(6.0f, 6.0f);
    elecPlot.plotSymbol = elecSymbol;
    
    // TODO: clean up this code
    // Configure axes
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Hour";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = 24;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    for (int k = 1; k <= 24; k++) {
        if (k % 2 == 0) {
            NSString *myString = [NSString stringWithFormat:@"%i", k];
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:myString  textStyle:x.labelTextStyle];
            CGFloat location = k;
            label.tickLocation = CPTDecimalFromCGFloat(location);
            label.offset = x.majorTickLength;
            if (label) {
                [xLabels addObject:label];
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"kW";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 10;
    NSInteger minorIncrement = 5;
    CGFloat yMax = 100.0f;  // should determine dynamically
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TODO: make this use real data
#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.dataForElectricityChart count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return @(index);
            break;
            
        case CPTScatterPlotFieldY: {
            NSNumber *yValue = [self.dataForElectricityChart objectAtIndex:index];
            return yValue;
            break;
        }
    }
    return [NSDecimalNumber zero];

}

#pragma mark - CEDataRetreiverDelegate methods
- (void)retriever:(CEDataRetriever *)retriever gotUsage:(NSArray *)usage ofType:(UsageType)usageType forBuilding:(CEBuilding *)building {
    [self.dataForElectricityChart removeAllObjects];
    for (CEDataPoint *point in usage) {
        [self.dataForElectricityChart addObject:@(point.weight * point.value)];
    }
    [self performSelectorOnMainThread:@selector(reloadPlotData) withObject:nil waitUntilDone:NO];
}

- (void)reloadPlotData {
    [self.electricityLineGraph reloadData];
    [self.electricityLineGraph.defaultPlotSpace scaleToFitPlots:[self.electricityLineGraph allPlots]];
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
