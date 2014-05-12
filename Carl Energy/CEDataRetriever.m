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
    // RUN THIS IN A SEPARATE THREAD OTHERWISE IT WILL LOCK UP THE UI
    
    [self setRequestInProgress:YES];
    
    NSMutableArray *buildings = [[NSMutableArray alloc] init];
    
    // fire off a web request
    NSString *urlString = [NSString stringWithFormat:@"%@/json/carleton/children/", self.baseUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *webError = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
    
    //TODO: Error handling
    if (webError == nil) {
        NSError *jsonError = nil;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonError];
        if (jsonError == nil) {
            for (NSDictionary *buildingJSON in json) {
                CEBuilding *b = [[CEBuilding alloc] init];
                [b setDisplayName:[buildingJSON objectForKey:@"displayName"]];
                [b setWebName:[buildingJSON objectForKey:@"urlElement"]];
                [b setImageURL:[buildingJSON objectForKey:@"profile"]];
                [buildings addObject:b];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(retriever:gotBuildings:)]) {
        [self.delegate retriever:self gotBuildings:buildings];
    }
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
    if ([self.delegate respondsToSelector:@selector(retriever:gotUsage:ofType:forBuilding:)]) {
        [self.delegate retriever:self gotUsage:dummyData ofType:usageType forBuilding:building];
    }
    [self setRequestInProgress:NO];
}

@end
