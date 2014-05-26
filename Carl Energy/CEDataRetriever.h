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
#import "CEMeter.h"

typedef NS_ENUM(NSInteger, Resolution) {
    kResolutionLive,
    kResolutionHour,
    kResolutionDay,
    kResolutionMonth,
};

@protocol CEDataRetrieverDelegate;

@interface CEDataRetriever : NSObject
- (void)getBuildingsOnCampus;
- (void)getUsage:(UsageType)usageType ForBuilding:(CEBuilding *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res;
- (NSArray *)syncGetUsage:(UsageType)usageType ForBuilding:(CEBuilding *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res;
- (void)getTotalWindProductionWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res;
- (CEBuilding *)buildingFromDictionary:(NSDictionary *)dict;
- (void)getTotalCampusElectricityUsageWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res;
//- (void)getTotalCampusGasUsageWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res;
//- (void)getTotalCampusFuelUsageWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res;

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
- (void)retriever:(CEDataRetriever *)retriever gotUsage:(NSArray *)usage ofType:(UsageType)usageType forBuilding:(CEBuilding *)building;
- (void)retriever:(CEDataRetriever *)retreiver gotWindProduction:(NSArray *)production;
- (void)retriever:(CEDataRetriever *)retreiver gotCampusElectricityUsage:(NSArray *)usage;
//- (void)retriever:(CEDataRetriever *)retreiver gotCampusGasUsage:(NSArray *)usage;
//- (void)retriever:(CEDataRetriever *)retreiver gotCampusFuelUsage:(NSArray *)usage;

@end