//
//  CEBuildingDetailViewController.m
//  Carl Energy
//
//  Created by Michelle Chen on 5/10/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEBuildingDetailViewController.h"


@interface CEBuildingDetailViewController ()
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
//@property (weak, nonatomic) IBOutlet UILabel *dummyLabel;
- (IBAction)timeChanged:(UISegmentedControl *)sender;
//@property (nonatomic, strong) CPTGraphHostingView *hostView;

@end

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
    // Do any additional setup after loading the view.
    CEDataRetriever *retriever = [[CEDataRetriever alloc] init];
    [retriever setDelegate:self];
    // placeholder code:
    self.dataForChart = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 24; i++) {
        [self.dataForChart addObject:@50.0];
    }
    [self makeLineGraph:0];
    self.dummyLabel.text = @"day";

    [NSThread detachNewThreadSelector:@selector(requestData) toTarget:self withObject:nil];
}

- (void)requestData {
    CEDataRetriever *retreiver = [[CEDataRetriever alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd+HH:mm:ss"];
    NSDate *start = [formatter dateFromString:@"2014/01/01+00:00:00"];
    NSDate *end = [formatter dateFromString:@"2015/01/01+00:00:00"];
    CEBuilding *b = [[CEBuilding alloc] init];
    [b setDisplayName:@"Burton"];
    [b setWebName:@"burton"];
    [retreiver getUsage:kUsageTypeElectricity ForBuilding:b startTime:start endTime:end resolution:kResolutionMonth];
}

-(IBAction)timeChanged:(UISegmentedControl *)sender
{
    [self makeLineGraph:self.segmentedControl.selectedSegmentIndex];
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            self.dummyLabel.text = @"day";
            break;
        case 1:
            self.dummyLabel.text = @"week";
            break;
        case 2:
            self.dummyLabel.text = @"month";
            break;
        case 3:
            self.dummyLabel.text = @"year";
            break;
        default:
            break;
    }
}

-(void)makeLineGraph:(NSInteger)timeframeIndex
{
    // Create and assign the host view
    CPTXYGraph *lineGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CGRect parentRect = CGRectMake(0, 60, self.segmentedControl.frame.size.width, 300);
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    [self.scrollView setFrame:self.view.bounds];
    [self.segmentedControl setFrame:self.scrollView.bounds];
    [self.segmentedControl addSubview:self.hostView];
    self.hostView.hostedGraph = lineGraph;
    
    // Define the textStyle for the title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor darkGrayColor];
    textStyle.fontName = @"HelveticaNeue-Thin";
    textStyle.fontSize = 25.0f;
    
    // Make title
    NSString *title = @"Electricity Usage";
    lineGraph.title = title;
    lineGraph.titleTextStyle = textStyle;
    //lineGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    lineGraph.titleDisplacement = CGPointMake(0.0f, 40.0f);
    
    // Set plot area padding
    [lineGraph.plotAreaFrame setPaddingLeft:30.0f];
    [lineGraph.plotAreaFrame setPaddingBottom:30.0f];
    
    // Create plot
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) lineGraph.defaultPlotSpace;
    CPTScatterPlot *elecPlot = [[CPTScatterPlot alloc] init];
    elecPlot.dataSource = self;
    //elecPlot.identifier = elec;
    CPTColor *elecColor = [CPTColor redColor];
    [lineGraph addPlot:elecPlot toPlotSpace:plotSpace];
    
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
    // extremely temporary
    return 24;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return [NSNumber numberWithUnsignedInteger:index];
            break;
            
        case CPTScatterPlotFieldY:
            return [self.dataForChart objectAtIndex:index];
            break;
    }
    return [NSDecimalNumber zero];

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
