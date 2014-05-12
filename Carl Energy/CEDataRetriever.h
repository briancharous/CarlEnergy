//
//  CEDataRetriever.h
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEBuilding.h"
#import "CEDataPoint.h"

typedef enum {
    kResolutionHour,
    kResolutionDay,
    kResolutionMonth
} Resolution;

typedef enum {
    kUsageTypeWater,
    kUsageTypeElectricity,
    kUsageTypeSteam
} UsageType;


@protocol CEDataRetrieverDelegate;

@interface CEDataRetriever : NSObject
- (void)getBuildingsOnCampus;

- (void)getUsage:(UsageType)usageType ForBuilding:(NSString *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res;

@property (nonatomic, assign) id <CEDataRetrieverDelegate> delegate;
@property NSString *baseUrl;
@property UsageType currentRequestUsageType;
@property Resolution currentRequestResolution;
@property NSString *currentRequestBuilding;
@property NSDate *currentRequestStartTime;
@property NSDate *currentRequestEndTime;
@property BOOL requestInProgress;


@end

@protocol CEDataRetrieverDelegate <NSObject>

@optional

- (void)retriever:(CEDataRetriever *)retriever gotBuildings:(NSArray *)buildings;
- (void)retriever:(CEDataRetriever *)retriever gotUsage:(NSArray *)usage ofType:(UsageType)usageType forBuilding:(NSString *)building;

@end