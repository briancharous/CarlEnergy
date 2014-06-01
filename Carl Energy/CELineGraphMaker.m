//
//  CELineGraphMaker.m
//  Carl Energy
//
//  Created by Larkin Flodin on 5/25/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CELineGraphMaker.h"

@implementation CELineGraphMaker

- (void)requestDataOfType:(UsageType)type forBuilding:(CEBuilding*)building forTimeScale:(CETimeScale)timeScale
{
    if (!self.retreiver) {
        self.retreiver = [[CEDataRetriever alloc] init];
        [self.retreiver setDelegate:self];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd+HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSDate *previous;
    Resolution resolution;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.lineGraph.axisSet;
    self.x = axisSet.xAxis;
    switch (timeScale) {
        case kTimeScaleDay:
            previous = [now dateByAddingTimeInterval:-60*60*24];
            resolution = kResolutionHour;
            self.x.title = @"Hour";
            self.requestType = 0;
            break;
        case kTimeScaleWeek:
            previous = [now dateByAddingTimeInterval:-60*60*24*7];
            resolution = kResolutionDay;
            self.x.title = @"Day ";
            self.requestType = 1;
            break;
        case kTimeScaleMonth:
            previous = [now dateByAddingTimeInterval:-60*60*24*30];
            resolution = kResolutionDay;
            self.x.title = @"Day";
            self.requestType = 2;
            break;
        case kTimeScaleYear:
            previous = [now dateByAddingTimeInterval:-60*60*24*365];
            resolution = kResolutionMonth;
            self.x.title = @"Month";
            self.requestType = 3;
            break;
        default:
            break;
    }
    
    if (!self.retreiver.requestInProgress) {
        dispatch_async(dispatch_queue_create("com.carlenergy.graphs", NULL), ^ {
            [self.retreiver getUsage:type ForBuilding:building startTime:previous endTime:now resolution:resolution];
        });
    }
    else {
        // if a request is in progress, cancel the request by deleteing the old
        // data retreiver
        // is this going to be a memory issue??
        [self.retreiver setDelegate:nil];
        self.retreiver = nil;
        self.retreiver = [[CEDataRetriever alloc] init];
        [self.retreiver setDelegate:self];
    }
}



- (CPTGraph *)makeLineGraphForTime:(NSInteger)timeframeIndex forUsage:(UsageType)type forBuilding:(CEBuilding*)building
{
    // prep stuff
    switch (timeframeIndex)
    {
        case 0:
            [self requestDataOfType:type forBuilding:building forTimeScale:kTimeScaleDay];
            break;
        case 1:
            [self requestDataOfType:type forBuilding:building forTimeScale:kTimeScaleWeek];
            break;
        case 2:
            [self requestDataOfType:type forBuilding:building forTimeScale:kTimeScaleMonth];
            break;
        case 3:
            [self requestDataOfType:type forBuilding:building forTimeScale:kTimeScaleYear];
            break;
        default:
            break;
    }
    //    self.dataForClearChart = [[NSMutableArray alloc] init];
    
    // Create and assign the host view
    
    if (!self.lineGraph) {
        self.lineGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
        self.dataForChart = [[NSMutableArray alloc] init];
        
        
        // Define the textStyle for the title
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.color = [CPTColor darkGrayColor];
        textStyle.fontName = @"HelveticaNeue-Thin";
        textStyle.fontSize = 20.0f;
        
        // Make title
        NSString *title = @"";
        if (type == kUsageTypeElectricity) {
            self.energyType = kUsageTypeElectricity;
            title = @"Electricity Usage";
        }
        else if (type == kUsageTypeWater) {
            self.energyType = kUsageTypeWater;
            title = @"Water Usage";
        }
        else {
            self.energyType = kUsageTypeSteam;
            title = @"Steam Usage";
        }
        self.lineGraph.title = title;
        self.lineGraph.titleTextStyle = textStyle;
        //lineGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        self.lineGraph.titleDisplacement = CGPointMake(0.0f, 40.0f);
        
        // Set plot area padding
        [self.lineGraph.plotAreaFrame setPaddingLeft:20.0f];
        [self.lineGraph.plotAreaFrame setPaddingRight:20.0f];
        //        [self.lineGraph.plotAreaFrame setPaddingTop:20.0f];
        [self.lineGraph.plotAreaFrame setPaddingBottom:40.0f];
        self.lineGraph.plotAreaFrame.masksToBorder = NO;
        self.lineGraph.plotAreaFrame.masksToBounds = NO;
        self.lineGraph.masksToBounds = NO;
        self.lineGraph.masksToBorder = NO;
        
        // Create plot
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.lineGraph.defaultPlotSpace;
        CPTScatterPlot *elecPlot = [[CPTScatterPlot alloc] init];
        elecPlot.dataSource = self;
        elecPlot.identifier = CEElectric;
        CPTColor *elecColor = [CPTColor redColor];
        CPTMutableLineStyle *elecLineStyle = [elecPlot.dataLineStyle mutableCopy];
        elecLineStyle.lineColor = elecColor;
        elecPlot.dataLineStyle = elecLineStyle;
        [self.lineGraph addPlot:elecPlot toPlotSpace:plotSpace];
        CPTScatterPlot *msftPlot = [[CPTScatterPlot alloc] init];
        msftPlot.dataSource = self;
        msftPlot.identifier = CEClear;
        CPTColor *msftColor = [CPTColor clearColor];
        CPTMutableLineStyle *msftLineStyle = [msftPlot.dataLineStyle mutableCopy];
        msftLineStyle.lineColor = msftColor;
        msftPlot.dataLineStyle = msftLineStyle;
        [self.lineGraph addPlot:msftPlot toPlotSpace:plotSpace];
        
        // Configure plot space
        // do we want to use the next line?
        [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:elecPlot, msftPlot, nil]];
        CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
        [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.5f)];
        plotSpace.xRange = xRange;
        CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
        [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.5f)];
        plotSpace.yRange = yRange;
        
        
        
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
        axisTextStyle.fontSize = 10.0f;
        CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
        tickLineStyle.lineColor = [CPTColor blackColor];
        tickLineStyle.lineWidth = 2.0f;
        CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
        tickLineStyle.lineColor = [CPTColor blackColor];
        tickLineStyle.lineWidth = 1.0f;
        // 2 - Get axis set
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.lineGraph.axisSet;
        // 3 - Configure x-axis
        self.x = axisSet.xAxis;
        //self.x.title = @"Hour";
        self.x.titleTextStyle = axisTitleStyle;
        self.x.titleOffset = 15.0f;
        self.x.axisLineStyle = axisLineStyle;
        self.x.labelingPolicy = CPTAxisLabelingPolicyNone;
        self.x.labelTextStyle = axisTextStyle;
        self.x.majorTickLineStyle = axisLineStyle;
        self.x.majorTickLength = 4.0f;
        self.x.tickDirection = CPTSignNegative;
        self.x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
        
        //NSLog([NSString stringWithFormat:@"%i", day]);
        CGFloat dateCount = 24;
        NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
        NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
        for (int k = 1; k <= 24; k++) {
            if (k % 2 == 0) {
                NSString *myString = [NSString stringWithFormat:@"%i", k];
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:myString textStyle:self.x.labelTextStyle];
                CGFloat location = k;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = self.x.majorTickLength;
                if (label) {
                    [xLabels addObject:label];
                    [xLocations addObject:[NSNumber numberWithFloat:location]];
                }
            }
        }
        self.x.axisLabels = xLabels;
        self.x.majorTickLocations = xLocations;
        // 4 - Configure y-axis
        self.y = axisSet.yAxis;
        if (type == kUsageTypeElectricity) {
            self.y.title = @"kW hours";
        }
        else {
            self.y.title = @"gallons";
        }
        self.y.titleTextStyle = axisTitleStyle;
        self.y.titleOffset = -40.0f;
        self.y.axisLineStyle = axisLineStyle;
        self.y.majorGridLineStyle = gridLineStyle;
        self.y.labelingPolicy = CPTAxisLabelingPolicyNone;
        self.y.labelTextStyle = axisTextStyle;
        self.y.labelOffset = 21.0f;
        self.y.majorTickLineStyle = axisLineStyle;
        self.y.majorTickLength = 4.0f;
        self.y.minorTickLength = 2.0f;
        self.y.tickDirection = CPTSignPositive;
        self.y.axisConstraints = [CPTConstraints constraintWithRelativeOffset:0];
        NSInteger majorIncrement = 10;
        
        //NSLog([NSString stringWithFormat:@"%@", [self.dataForElectricityChart objectAtIndex:0]]);
        CGFloat yMax = 200.0f;  // should determine dynamically
        NSMutableSet *yLabels = [NSMutableSet set];
        NSMutableSet *yMajorLocations = [NSMutableSet set];
        NSMutableSet *yMinorLocations = [NSMutableSet set];
        for (NSInteger j = majorIncrement; j <= yMax; j += majorIncrement) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:self.y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -self.y.majorTickLength - self.y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
            
        }
        
        self.y.axisLabels = yLabels;
        self.y.majorTickLocations = yMajorLocations;
        self.y.minorTickLocations = yMinorLocations;
        self.lineGraph.axisSet = axisSet;
    }
    
    return self.lineGraph;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.dataForChart count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return @(index);
            break;
            
        case CPTScatterPlotFieldY: {
            if ([plot.identifier isEqual:CEElectric] == YES) {
				NSNumber *yValue = [self.dataForChart objectAtIndex:index];
                
                return yValue;}
            else if ([plot.identifier isEqual:CEClear] == YES) {
				NSNumber *yValue = [self.dataForClearChart objectAtIndex:index];
                return yValue;
			}
			break;
        }
    }
    return [NSDecimalNumber zero];
    
}

#pragma mark - CEDataRetreiverDelegate methods
- (void)retriever:(CEDataRetriever *)retriever gotUsage:(NSArray *)usage ofType:(UsageType)usageType forBuilding:(CEBuilding *)building {
    [self.dataForChart removeAllObjects];
    for (CEDataPoint *point in usage) {
        [self.dataForChart addObject:@(point.weight * point.value)];
    }
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self reloadPlotData];
    });
}

- (void)reloadPlotData {
    
    self.x.axisLabels = nil;
    //    self.x = nil;
    self.y.axisLabels = nil;
    //    self.y = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd+HH:mm:ss"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit |NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    NSInteger day = [components day];
    NSInteger month = [components month];
    CGFloat dateCount = 24;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSUInteger numObjects = [self.dataForChart count];
    if (self.requestType == 0){
        self.x.title = @"Hour";
        NSString *kString;
        for (int k = 1; k <= numObjects; k++) {
            if (k % 6 == 3) {
                NSInteger newK = hour - (24 - k);
                if (newK < 0)
                    newK = 24 + newK;
                if (newK > 12){
                    newK = newK - 12;
                    kString = [NSString stringWithFormat:@"%li%@", (long)newK,@"pm"];
                }
                else if (newK == 0){
                    kString = @"12am";
                }
                else{
                    kString = [NSString stringWithFormat:@"%li%@", (long)newK,@"am"];
                }
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:kString  textStyle:self.x.labelTextStyle];
                CGFloat location = k;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = self.x.majorTickLength;
                if (label) {
                    [xLabels addObject:label];
                    [xLocations addObject:[NSNumber numberWithFloat:location]];
                }
            }
        }
    }
    else if (self.requestType == 1){
        self.x.title = @"Day";
        NSDate *now = [NSDate date];
        for (int k = 1; k <= numObjects; k++) {
            if (k%2 == 0){
                int daysToAdd = -(7-k);
                NSDate *newDate = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
                NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:newDate];
                NSString *myString = [NSString stringWithFormat:@"%li%s%li", (long)[components1 month], "/",(long)[components1 day]];
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:myString  textStyle:self.x.labelTextStyle];
                CGFloat location = k;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = self.x.majorTickLength;
                if (label) {
                    [xLabels addObject:label];
                    [xLocations addObject:[NSNumber numberWithFloat:location]];
                }
            }
        }
    }
    else if (self.requestType == 2){
        self.x.title = @"Day";
        NSDate *now = [NSDate date];
        for (int k = 1; k <= numObjects; k++) {
            if (k % 7 == 0) {
                int daysToAdd = (int) -(numObjects-k);
                NSDate *newDate = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
                NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:newDate];
                NSString *myString = [NSString stringWithFormat:@"%li%s%li", (long)[components1 month], "/",(long)[components1 day]];
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:myString  textStyle:self.x.labelTextStyle];
                CGFloat location = k;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = self.x.majorTickLength;
                if (label) {
                    [xLabels addObject:label];
                    [xLocations addObject:[NSNumber numberWithFloat:location]];
                }
            }
        }
    }
    else if (self.requestType == 3){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        self.x.title = @"Month";
        for (int k = 1; k <= numObjects; k++) {
            if (k % 2 == 1) {
                NSInteger newK = month - (12 - k);
                if (newK < 1){
                    newK = month + k;
                }
                NSString *monthName = [[df monthSymbols] objectAtIndex:(newK-1)];
                monthName = [monthName substringToIndex:3];
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:monthName  textStyle:self.x.labelTextStyle];
                CGFloat location = k;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = self.x.majorTickLength;
                if (label) {
                    [xLabels addObject:label];
                    [xLocations addObject:[NSNumber numberWithFloat:location]];
                }
            }
        }
    }
    
    
    NSNumber * max = [self.dataForChart valueForKeyPath:@"@max.intValue"];
    NSNumber * maxF = [self.dataForChart valueForKeyPath:@"@max.floatValue"];
    self.x.titleOffset = 15.0f;
    int maxInt = [max intValue];
    [self.lineGraph reloadData];
    if (self.energyType == kUsageTypeElectricity) {
        self.y.title = @"kW hours";
    }
    else if (self.energyType == kUsageTypeWater) {
        self.y.title = @"gallons";
    }
    else {
        self.y.title =@"kBTUs";
    }

    BOOL data = true;
    // account for no data available
    if (maxF == NULL) {
        self.x.title = @"No data available";
        self.x.titleOffset = -100.0f;
        self.y.title = @" ";
        data = false;
    }
    NSInteger majorIncrement = ceil(maxInt/5.);
    CGFloat yMax = maxInt;
    if (maxInt < 5){
        majorIncrement = 1;
    }
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    self.y.labelOffset = 18.0f;

    BOOL big = false;
    if (maxInt > 0){
        for (NSInteger j = majorIncrement; j <= yMax; j += majorIncrement) {
            long jRound = j;
            if (data == false){
                break;
            }
            if (j < 10){
                jRound = j;
                self.y.labelOffset = 15.0f;
            }
            else if (j < 100){
                jRound = (j/2) * 2;
                self.y.labelOffset = 15.0f;
            }
            else if (j < 1000){
                jRound = (j/10) * 10;
                self.y.labelOffset = 18.0f;
            }
            else if (j < 100000){
                jRound = (j/100) * 100;
                self.y.labelOffset = 23.0f;
            }
//            else if (j < 100000){
//                jRound = (j/100) * 100;
//                self.y.labelOffset = 23.0f;
//            }
            else if (j > 1000000){
                big = true;
                if (j > majorIncrement*4.5){
                    big = false;
                }
                jRound = (j/100) * 100;
                
            }
            //NSLog([NSString stringWithFormat:@"%li", (long)jRound]);
            NSString *strLabel = [NSString stringWithFormat:@"%li", (long)jRound];
            if (big == true){
                strLabel = @" ";
                self.y.labelOffset = 33.0f;
                big = false;
                
            }
            else if (jRound > 9999){
                NSMutableString *strLabel2 = [NSMutableString stringWithFormat:@"%li", (long)jRound];
                NSString *strLabel1 = [strLabel2 substringToIndex:[strLabel2 length]-3];
                strLabel = [NSMutableString stringWithFormat:@"%@%s", strLabel1, "k"];
            }
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:strLabel textStyle:self.y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -self.y.majorTickLength - self.y.labelOffset;
            if (label && data) {
                [yLabels addObject:label];
            }
            
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
            
        }
    }
    //Handles values less than one
    else if (maxInt == 0){
        NSLog(@"small");
        float maxFloat = [maxF floatValue];
        float majorIncrement = maxFloat/5;
        for (float j = majorIncrement; j <= maxFloat; j += majorIncrement) {
            float jRound = j;
            if (data == false){
                break;
            }
            else{
                jRound = j;
                self.y.labelOffset = 20.0f;
            }
            NSString *strLabel = [NSString stringWithFormat:@"%f", jRound];
            strLabel = [strLabel substringToIndex:4];
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:strLabel textStyle:self.y.labelTextStyle];
            NSDecimal location = CPTDecimalFromFloat(j);
            label.tickLocation = location;
            label.offset = -self.y.majorTickLength - self.y.labelOffset;
            if (label && data) {
                [yLabels addObject:label];
            }
            
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        }
    }
    self.x.axisLabels = xLabels;
    NSLog(@"%@", xLabels);
    self.x.majorTickLocations = xLocations;
    
    self.y.axisLabels = yLabels;
    self.y.majorTickLocations = yMajorLocations;
    
    
    
    [self.lineGraph.defaultPlotSpace scaleToFitPlots:[self.lineGraph allPlots]];
    
    // make sure top doesn't get chopped off
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.lineGraph.defaultPlotSpace;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.yRange = yRange;
    
    // test code for y axis problem
//    NSLog(@"%@", self.y.title);
//    NSLog(@"%lu", (unsigned long)[self.y.axisLabels count]);
//    NSLog(@"%lu", (unsigned long)[self.y.majorTickLocations count]);
//    NSArray *yArray = [self.y.axisLabels allObjects];
//    NSLog(@"%@", yArray);
//    NSArray *yArray2 = [self.y.majorTickLocations allObjects];
//    NSLog(@"%@", yArray2);
    
}
@end
