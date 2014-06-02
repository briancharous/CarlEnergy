//
//  CEBuildingMiniView.h
//  Carl Energy
//
//  Created by Brian Charous on 6/1/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEDashboardItemView.h"
#import "CEDataRetriever.h"

@interface CEBuildingMiniView : CEDashboardItemView <CEDataRetrieverDelegate> {
    BOOL gotElecUsage;
    BOOL gotWaterUsage;
    BOOL gotSteamUsage;
    
    NSInteger elecUsage;
    NSInteger waterUsage;
    NSInteger steamUsage;
    
    CEDataRetriever *elecRetreiver;
    CEDataRetriever *waterRetreiver;
    CEDataRetriever *steamRetreiver;
}

@property IBOutlet UILabel *elecLabel;
@property IBOutlet UILabel *waterLabel;
@property IBOutlet UILabel *steamLabel;
@property IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) CEBuilding *building;

- (void)updateUsageData;

@end
