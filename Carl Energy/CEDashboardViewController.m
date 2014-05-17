//
//  SecondViewController.m
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//



#import "CEDashboardViewController.h"


@interface CEDashboardViewController ()

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;

@end

@implementation CEDashboardViewController


@synthesize dataForChart;
@synthesize hostView = hostView_;
@synthesize selectedTheme = selectedTheme_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CEDataRetriever *retriever = [[CEDataRetriever alloc] init];
    [retriever setDelegate:self];
    
    // TODO: Change this to call a dataRetriever method to get data
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:@40.0, @60.0, nil];
    
    self.dataForChart = contentArray;
    [self makePieChart];
}

- (void)makePieChart
{
    // Create and assign the host view
    //TODO: Put this in a scroll view
    CPTXYGraph *pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CGRect parentRect = CGRectMake(0, 100, self.scrollView.frame.size.width, 250);
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    [self.scrollView setFrame:self.view.bounds];
    [self.scrollView addSubview:self.hostView];
    self.hostView.hostedGraph = pieChart;
    
    // Define the textStyle for the title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor darkGrayColor];
    textStyle.fontName = @"HelveticaNeue-Thin";
    textStyle.fontSize = 25.0f;
    
    // Set up the graph title
    //TODO: Make title show up. Maybe the bounds of the graph are too big?
    pieChart.axisSet = nil;
    pieChart.title = @"Current Electricity vs. Wind";
    pieChart.titleTextStyle = textStyle;
    pieChart.titleDisplacement = CGPointMake(0.0f, 100);
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
    
    //TODO: Add legend for data types
    //TODO: Make pretty
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
     return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if ( index >= [self.dataForChart count] ) {
        return nil;
    }
    
    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        return (self.dataForChart)[index];
    }
    else {
        return @(index);
    }
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    return nil;
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    return [NSString stringWithFormat:@"legend: %lu", (unsigned long)index];
}

@end
