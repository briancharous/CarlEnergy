//
//  CEPeakUsageView.h
//  Carl Energy
//
//  Created by Brian Charous on 5/31/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEDataRetriever.h"
#import "CEDashboardItemView.h"

@interface CEElectricityUsageView : CEDashboardItemView <CEDataRetrieverDelegate> {
    NSInteger instantUsage;
    NSInteger peakUsage;
    BOOL gotInstantUsage;
    BOOL gotPeakUsage;
}

@property IBOutlet UILabel *currentLabel;
@property IBOutlet UILabel *peakLabel;


- (void)updateUsage;

@end
