//
//  CEBuildingMiniView.m
//  Carl Energy
//
//  Created by Brian Charous on 6/1/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEBuildingMiniView.h"

@implementation CEBuildingMiniView

@synthesize building = _building;

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CEBuildingMiniView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        [self.elecLabel setText:@""];
        [self.waterLabel setText:@""];
        [self.steamLabel setText:@""];
    }
    return self;
}

- (void)setBuilding:(CEBuilding *)building {
    _building = building;
    [self.titleLabel setText:building.displayName];
}

- (void)refreshData {
    if (!elecRetreiver) {
        elecRetreiver = [[CEDataRetriever alloc] init];
        [elecRetreiver setDelegate:self];
    }
    if (!waterRetreiver) {
        waterRetreiver = [[CEDataRetriever alloc] init];
        [waterRetreiver setDelegate:self];
    }
    if (!steamRetreiver) {
        steamRetreiver = [[CEDataRetriever alloc] init];
        [steamRetreiver setDelegate:self];
    }

    NSDate *now = [NSDate date];
    NSDate *before = [now dateByAddingTimeInterval:-60*60*24];
    
    gotElecUsage = NO;
    dispatch_async(dispatch_queue_create("com.carlenergy.minibuilding", NULL), ^ {
        [elecRetreiver getUsage:kUsageTypeElectricity ForBuilding:self.building startTime:before endTime:now resolution:kResolutionHour];
    });
    gotWaterUsage = NO;
    dispatch_async(dispatch_queue_create("com.carlenergy.minibuilding", NULL), ^ {
        [waterRetreiver getUsage:kUsageTypeWater ForBuilding:self.building startTime:before endTime:now resolution:kResolutionHour];
    });
    gotSteamUsage = NO;
    dispatch_async(dispatch_queue_create("com.carlenergy.minibuilding", NULL), ^ {
        [steamRetreiver getUsage:kUsageTypeSteam ForBuilding:self.building startTime:before endTime:now resolution:kResolutionHour];
    });
    
    [self.elecLabel setText:@"Updating..."];
    [self.waterLabel setText:@""];
    [self.steamLabel setText:@""];
}

- (void)updateUsageData {
    if (!gotElecUsage || !gotSteamUsage || !gotWaterUsage) {
        return;
    }
    NSString *elecString = [NSString stringWithFormat:@"%li kWh of electricity", (long)elecUsage];
    NSString *waterString = [NSString stringWithFormat:@"%li gallons of water", (long)waterUsage];
    NSString *steamString = [NSString stringWithFormat:@"%li BTUs of steam", (long)steamUsage];
    [self.elecLabel setText:elecString];
    [self.waterLabel setText:waterString];
    [self.steamLabel setText:steamString];

    [self.delegate dashboardItemViewRefreshedData:self];
}

- (NSInteger)preferredHeightForPortrait {
    return [CEBuildingMiniView preferredHeightForPortrait];
}

+ (NSInteger)preferredHeightForPortrait {
    return 175;
}

- (NSInteger)preferredHeightForLandscape {
    return [CEBuildingMiniView preferredHeightForLandscape];
}

+ (NSInteger)preferredHeightForLandscape {
    return 175;
}

#pragma mark CEDataRetreiverDelegate 
- (void)retriever:(CEDataRetriever *)retriever gotUsage:(NSArray *)usage ofType:(UsageType)usageType forBuilding:(CEBuilding *)building {

    float total = 0;
    for (CEDataPoint *point in usage) {
        total += point.value * point.weight;
    }

    if (retriever == elecRetreiver) {
        elecUsage = (NSInteger)total;
        gotElecUsage = YES;
    }
    else if (retriever == waterRetreiver) {
        waterUsage = (NSInteger)total;
        gotWaterUsage = YES;
    }
    else if (retriever == steamRetreiver) {
        steamUsage = (NSInteger)total;
        gotSteamUsage = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self updateUsageData];
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
