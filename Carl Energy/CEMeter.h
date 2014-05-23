//
//  CEMeter.h
//  Carl Energy
//
//  Created by Brian Charous on 5/20/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UsageType) {
    // this is how BuildingOS defines the usage types
    kUsageTypeWater = 3,
    kUsageTypeElectricity = 1,
    kUsageTypeSteam = 4,
    kUsageTypeWindProduction = 11
};

@interface CEMeter : NSObject

@property NSString *systemName;
@property (nonatomic, assign) UsageType usageType;
@property NSString *displayName;

@end
