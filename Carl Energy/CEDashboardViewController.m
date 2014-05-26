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
<<<<<<< HEAD
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1)];
    [self makePieChart];
    [self getElectricProductionAndUsage];
=======
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [self makeTurbine];
    [self getElectricProducionAndUsage];
>>>>>>> no-coreplot
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


<<<<<<< HEAD
- (void)makePieChart
{
    // Create and assign the host view
    pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CGRect parentRect = CGRectMake(0, 50, self.scrollView.frame.size.width, 300);
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
    piePlot.pieRadius       = 50.0;
    piePlot.identifier      = @"Pie Chart 1";
    piePlot.startAngle      = M_PI_4;
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.centerAnchor    = CGPointMake(0.5, 0.6);
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
    
    
=======
- (void)makeTurbine {
//    CEWindView *windView = [[CEWindView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 300)];
    windView = [[[NSBundle mainBundle] loadNibNamed:@"CEWindView" owner:self options:nil] objectAtIndex:0];
    [windView setFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 400)];
    [windView.producedLabel setText:@""];
    [windView.consumedLabel setText:@""];
    [self.scrollView addSubview:windView];
>>>>>>> no-coreplot
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

<<<<<<< HEAD
#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
     return 4;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSLog(@"number for plot: %lu", (unsigned long)index);
    if ( index >= 4) {
        return nil;
    }
    
    switch (index) {
        case 0:
            return windProduction;
            break;
        case 1:
            return energyConsumption;
            break;
        case 2:
            return gasConsumption;
            break;
        case 3:
            return fuelConsumption;
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
    float gasValue = [gasConsumption floatValue];
    float fuelValue = [fuelConsumption floatValue];
    float totalEnergy = windValue + elecValue + gasValue + fuelValue;
    NSString *labelValue = nil;
    
    // electric
    if (index == 1) {
        float elecPercent = elecValue / totalEnergy;
        labelValue = [NSString stringWithFormat:@"%.f (%0.1f%%)", elecValue, (elecPercent * 100.0f)];
    }
    // wind
    else if (index == 0) {
        float windPercent = windValue / totalEnergy;
        labelValue = [NSString stringWithFormat:@"%.f (%0.1f%%)", windValue, (windPercent * 100.0f)];
    }
    return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
    // gas
    if (index == 2) {
        float gasPercent = gasValue / totalEnergy;
        labelValue = [NSString stringWithFormat:@"%.f (%0.1f%%)", gasValue, (gasPercent * 100.0f)];
    }
    // fuel
    if (index == 3) {
        float fuelPercent = fuelValue / totalEnergy;
        labelValue = [NSString stringWithFormat:@"%.f (%0.1f%%)", fuelValue, (fuelPercent * 100.0f)];
    }
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    // These units might be wrong
    if (index == 0) {
        return @"Electric Consumption (kW)";
    }
    else if (index == 1) {
        return @"Wind Production (kW)";
    }
    else if (index == 2) {
        return @"Gas Consumption (kW)";
    }
    else if (index == 3) {
        return @"Oil Consumption (kW)";
    }
    return nil;
}
=======
>>>>>>> no-coreplot

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
    
    gotGasUsage = NO;
    energyConsumption = @(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [gasRetreiver getTotalCampusElectricityUsageWithStartTime:oneHourAgo endTime:now resolution:kResolutionLive];
    });
    
    gotFuelUsage = NO;
    energyConsumption = @(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        [fuelRetreiver getTotalCampusElectricityUsageWithStartTime:oneHourAgo endTime:now resolution:kResolutionLive];
    });
}

<<<<<<< HEAD
- (void)updatePieChart {
    // TODO: add || !gotGasUsage || !gotFuelUsage when it doesn't break everything
    if (!gotWindProduction || !gotElectricityUsage) {
        return;
    }
    [pieChart reloadData];
    NSLog(@"draw now!!!!");
    [pieChart.plotAreaFrame.plotArea setNeedsDisplay];
//    [pieChart performSelector:@selector(reloadData) withObject:nil afterDelay:0];
=======
- (void)updateUsageData {
    if (!gotWindProduction || !gotElectricityUsage) {
        return;
    }

    NSString *producedString = [NSString stringWithFormat:@"%lu kWh produced", [windProduction integerValue]];
   
    float percentageWind = [windProduction floatValue]/[energyConsumption floatValue] * 100;
    NSString *consumedString = [NSString stringWithFormat:@"%i%% campus energy from wind", (int)percentageWind];
    [[windView producedLabel] setText:producedString];
    [[windView consumedLabel] setText:consumedString];
    [[windView consumedLabel] setNeedsDisplay];
    [[windView producedLabel] setNeedsDisplay];
    NSLog(@"%@, %@", windProduction, energyConsumption);

>>>>>>> no-coreplot
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

- (void)retriever:(CEDataRetriever *)retreiver gotCampusGasUsage:(NSArray *)usage {
    float totalUsage = 0;
    for (CEDataPoint *point in usage) {
        totalUsage += point.value * point.weight;
    }
    gasConsumption = @(totalUsage);
    gotGasUsage = YES;
    [self performSelectorOnMainThread:@selector(updatePieChart) withObject:nil waitUntilDone:NO];
}

- (void)retriever:(CEDataRetriever *)retreiver gotCampusFuelUsage:(NSArray *)usage {
    float totalUsage = 0;
    for (CEDataPoint *point in usage) {
        totalUsage += point.value * point.weight;
    }
    fuelConsumption = @(totalUsage);
    gotFuelUsage = YES;
    [self performSelectorOnMainThread:@selector(updatePieChart) withObject:nil waitUntilDone:NO];
}



@end
