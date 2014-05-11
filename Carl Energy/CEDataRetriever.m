//
//  CEDataRetriever.m
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEDataRetriever.h"

@implementation CEDataRetriever

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBaseUrl:@"https://rest.buildingos.com"];
        [self setRequestInProgress:NO];
    }
    return self;
}

- (void)getBuildingsOnCampus {
//    NSString *urlString = [NSString stringWithFormat:@"%@/json/carleton/children/", self.baseUrl];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if (error == nil) {
//        
//    }
    [self setRequestInProgress:YES];
    CEBuilding *burton = [[CEBuilding alloc] init];
    [burton setWebName:@"burton"];
    [burton setDisplayName:@"Burton"];
    [burton setBuildingImage:nil];
    CEBuilding *Sayles = [[CEBuilding alloc] init];
    [burton setWebName:@"syles"];
    [burton setDisplayName:@"Sayles-Hill Campus Center"];
    [burton setBuildingImage:nil];
    CEBuilding *Weitz = [[CEBuilding alloc] init];
    [burton setWebName:@"weitz"];
    [burton setDisplayName:@"Weitz Center for Creativity"];
    [burton setBuildingImage:nil];
    NSArray *dummyBuildings = @[burton, Sayles, Weitz];
    [self.delegate retreiver:self gotBuildings:dummyBuildings];
    [self setRequestInProgress:NO];
}

- (void)getUsage:(UsageType)usageType ForBuilding:(NSString *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
    [self setRequestInProgress:YES];
    NSDate *dummyDate1 = [[NSDate alloc] initWithTimeIntervalSince1970:0];
    CEDataPoint *point1 = [[CEDataPoint alloc] initWithTimestamp:dummyDate1 hoursElapsed:24 weight:24 value:10];
    NSDate *dummyDate2 = [[NSDate alloc] initWithTimeIntervalSince1970:1440];
    CEDataPoint *point2 = [[CEDataPoint alloc] initWithTimestamp:dummyDate2 hoursElapsed:1 weight:24 value:51];
    NSDate *dummyDate3 = [[NSDate alloc] initWithTimeIntervalSince1970:2880];
    CEDataPoint *point3 = [[CEDataPoint alloc] initWithTimestamp:dummyDate3 hoursElapsed:1 weight:24 value:23];
    NSArray *dummyData = @[point1, point2, point3];
    [self.delegate retreiver:self gotUsage:dummyData ofType:usageType forBuilding:building];
    [self setRequestInProgress:NO];
}

@end
