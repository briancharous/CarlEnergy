//
//  CEBuildingDetailViewController.m
//  Carl Energy
//
//  Created by Michelle Chen on 5/10/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEBuildingDetailViewController.h"


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
    switch (timeScale) {
        case kTimeScaleDay:
            previous = [now dateByAddingTimeInterval:-60*60*24];
            resolution = kResolutionHour;
            break;
        case kTimeScaleWeek:
            previous = [now dateByAddingTimeInterval:-60*60*24*7];
            resolution = kResolutionDay;
            break;
        case kTimeScaleMonth:
            previous = [now dateByAddingTimeInterval:-60*60*24*30];
            resolution = kResolutionDay;
        case kTimeScaleYear:
            previous = [now dateByAddingTimeInterval:-60*60*24*365];
            resolution = kResolutionMonth;
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

-(void)makeLineGraph:(NSInteger)timeframeIndex
{
    // Create and assign the host view
    self.electricityLineGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CGRect parentRect = CGRectMake(0, 60, self.segmentedControl.frame.size.width, 300);
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    [self.scrollView setFrame:self.view.bounds];
//    [self.segmentedControl setFrame:self.scrollView.bounds];
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
    [self.electricityLineGraph.plotAreaFrame setPaddingLeft:30.0f];
    [self.electricityLineGraph.plotAreaFrame setPaddingBottom:30.0f];
    
    // Create plot
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.electricityLineGraph.defaultPlotSpace;
    CPTScatterPlot *elecPlot = [[CPTScatterPlot alloc] init];
    elecPlot.dataSource = self;
    //elecPlot.identifier = elec;
    CPTColor *elecColor = [CPTColor redColor];
    [self.electricityLineGraph addPlot:elecPlot toPlotSpace:plotSpace];
    
    // Configure plot space??
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:elecPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    
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
    
    // Configure axes
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
            NSLog(@"%lu: %@", (unsigned long)index, yValue);
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
