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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CEDataRetriever *retriever = [[CEDataRetriever alloc] init];
    [retriever setDelegate:self];
    
    // TODO: Change this to call a dataRetriever method to get data
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:@40.0, @80.0, nil];
    
    self.dataForChart = contentArray;
    // Maybe not needed after more content added:
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];
    [self makePieChart];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // undraw and redraw the graph
    [self.hostView removeFromSuperview];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    // Maybe not needed after more content added:
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];
    [self makePieChart];
}

- (void)makePieChart
{
    // Create and assign the host view
    CPTXYGraph *pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CGRect parentRect = CGRectMake(0, 60, self.scrollView.frame.size.width, 300);
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
    pieChart.axisSet = nil;
    pieChart.title = @"Current Electricity vs. Wind";
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
     return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if ( index >= [self.dataForChart count] ) {
        return nil;
    }
    
    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        return [self.dataForChart objectAtIndex:index];
    }
    else {
        return @(index);
    }
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor darkGrayColor];
    }
    
    float windValue = [[self.dataForChart objectAtIndex:1] floatValue];
    float elecValue = [[self.dataForChart objectAtIndex:0] floatValue];
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
        return @"Electric";
    }
    else if (index == 1) {
        return @"Wind";
    }
    return nil;
}

@end
