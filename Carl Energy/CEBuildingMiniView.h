//
//  CEBuildingMiniView.h
//  Carl Energy
//
//  Created by Brian Charous on 6/1/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEDashboardItemView.h"
#import "CEDataRetriever.h"

@protocol CEBuildingMiniViewDelegate;

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
@property IBOutlet UIButton *bigButton;

@property (nonatomic, strong) CEBuilding *building;
@property (nonatomic, assign) id <CEBuildingMiniViewDelegate> miniViewDelegate;

- (void)updateUsageData;
- (void)bigButtonPressed;

@end

@protocol CEBuildingMiniViewDelegate <NSObject>

- (void)buildingMiniViewWasSelected:(CEBuildingMiniView *)miniView;

@end
