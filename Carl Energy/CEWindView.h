//
//  CEWindView.h
//  Carl Energy
//
//  Created by Brian Charous on 5/25/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CEDataRetriever.h"
#import "CEDashboardItemView.h"

@interface CEWindView : CEDashboardItemView <CEDataRetrieverDelegate> {
    
    NSNumber *windProduction;
    NSNumber *energyConsumption;
    BOOL gotWindProduction;
    BOOL gotElectricityUsage;
}


@property IBOutlet UIImageView *baseView;
@property IBOutlet UIImageView *bladesView;
@property IBOutlet UIImageView *baseView2;
@property IBOutlet UIImageView *bladesView2;
@property IBOutlet UILabel *producedLabel;
@property IBOutlet UILabel *consumedLabel;

- (void)startBladeAnimation;
- (void)updateUsageData;

@end
