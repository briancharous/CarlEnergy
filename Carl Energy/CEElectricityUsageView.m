//
//  CEPeakUsageView.m
//  Carl Energy
//
//  Created by Brian Charous on 5/31/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEElectricityUsageView.h"

@implementation CEElectricityUsageView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CEElectricityUsageView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        [self setFrame:frame];
        [self.currentLabel setText:@""];
        [self.peakLabel setText:@""];
    }
    return self;
}

- (void)refreshData {
    CEDataRetriever *instantRetreiver = [[CEDataRetriever alloc] init];
    [instantRetreiver setDelegate:self];
    CEDataRetriever *peakRetreiver = [[CEDataRetriever alloc] init];
    [peakRetreiver setDelegate:self];
    
    NSDate *now = [NSDate date];
    NSDate *shorlyBeforeNow = [now dateByAddingTimeInterval:-60*60*1.1]; // two hour ago (really only need the server to return 1 data point)
    
    gotInstantUsage = NO;
    dispatch_async(dispatch_queue_create("com.carlenergy.dashboard", NULL), ^ {
        [instantRetreiver getTotalCampusElectricityUsageWithStartTime:shorlyBeforeNow endTime:now resolution:kResolutionHour];
    });
    
    gotPeakUsage = NO;
    dispatch_async(dispatch_queue_create("com.carlenergy.dashboard", NULL), ^ {
        [peakRetreiver getPeakCampusConsumptionForPeriod:kResolutionMonth];
    });
    
    [self.currentLabel setText:@"Updating..."];
    [self.peakLabel setText:@""];
}

- (void)updateUsage {
    if (!gotPeakUsage || ! gotInstantUsage) {
        return;
    }
    
    NSString *instantString = [NSString stringWithFormat:@"%li kW currently being used", (long)instantUsage];
    NSString *maxString = [NSString stringWithFormat:@"%li kW was the peak consumption for this month", (long)peakUsage];
    [self.currentLabel setText:instantString];
    [self.peakLabel setText:maxString];
}

#pragma mark CEDataRetreiverDelegate methods

- (void)retriever:(CEDataRetriever *)retreiver gotCampusElectricityUsage:(NSArray *)usage {
    
    // get instantaneous usage
    CEDataPoint *p = [usage objectAtIndex:0];
    instantUsage = (NSInteger)(p.value * p.weight);
    gotInstantUsage = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUsage];
    });
}

- (void)retriever:(CEDataRetriever *)retreiver gotPeakConsumption:(float)consumption {
    peakUsage = (NSInteger)consumption;
    gotPeakUsage = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUsage];
    });
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
