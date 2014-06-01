//
//  CEWindView.m
//  Carl Energy
//
//  Created by Brian Charous on 5/25/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEWindView.h"

@implementation CEWindView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CEWindView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        [self setFrame:frame];
        [self.producedLabel setText:@""];
        [self.consumedLabel setText:@""];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

}
*/

+ (NSInteger)preferredHeight {
    return 300;
}

- (void)restartAnimation {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * .3];
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    
    [self.bladesView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self.bladesView2.layer addAnimation:rotationAnimation forKey:@"roationAnimation2"];
}

- (void)updateUsageData {
    if (!gotWindProduction || !gotElectricityUsage) {
        return;
    }
    
    NSString *producedString = [NSString stringWithFormat:@"%lu kWh produced", (long)[windProduction integerValue]];
    
    float percentageWind = [windProduction floatValue]/([windProduction floatValue]+ [energyConsumption floatValue]) * 100;
    NSString *consumedString = [NSString stringWithFormat:@"%i%% campus electricity from wind", (int)percentageWind];
    [[self producedLabel] setText:producedString];
    [[self consumedLabel] setText:consumedString];
    
    if ([self.delegate respondsToSelector:@selector(dashboardItemViewRefreshedData:)]) {
        [self.delegate dashboardItemViewRefreshedData:self];
    }
}

#pragma mark Data Retrieval
- (void)refreshData {
    // get wind production and main campus consumption
    // between now and one hour ago
    
    CEDataRetriever *windRetreiver = [[CEDataRetriever alloc] init];
    CEDataRetriever *electricRetreiver = [[CEDataRetriever alloc] init];
    [windRetreiver setDelegate:self];
    [electricRetreiver setDelegate:self];
    
    NSDate *now = [NSDate date];
    NSDate *oneDayAgo = [now dateByAddingTimeInterval:-60*60*24];
    
    gotWindProduction = NO;
    windProduction = @(0);
    dispatch_async(dispatch_queue_create("com.carlenergy.dashboard", NULL), ^ {
        [windRetreiver getTotalWindProductionWithStartTime:oneDayAgo endTime:now resolution:kResolutionHour];
    });
    
    gotElectricityUsage = NO;
    energyConsumption = @(0);
    dispatch_async(dispatch_queue_create("com.carlenergy.dashboard", NULL), ^ {
        [electricRetreiver getTotalCampusElectricityUsageWithStartTime:oneDayAgo endTime:now resolution:kResolutionHour];
    });
    
    [self.producedLabel setText:@"Updating..."];
    [self.consumedLabel setText:@""];
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

//- (void)dealloc {
////    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDid object:<#(id)#>]
//}



@end
