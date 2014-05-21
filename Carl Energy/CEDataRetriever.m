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

- (void)getUsage:(UsageType)usageType ForBuilding:(CEBuilding *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
    [self setRequestInProgress:YES];
    // format the start and end times
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd+HH:mm:ss"];
    NSString *startString = [formatter stringFromDate:start];
    NSString *endString = [formatter stringFromDate:end];
    
    // pick out the resolution string
    NSString *resolutionString;
    switch (res) {
        case kResolutionDay:
            resolutionString = @"day";
            break;
        case kResolutionHour:
            resolutionString = @"hour";
            break;
        case kResolutionMonth:
            resolutionString = @"month";
            break;
        default:
            resolutionString = @"";
            break;
    }
    
    // format the building energy type
    NSString *nameString;
    switch (usageType) {
        case kUsageTypeWater:
            nameString = [NSString stringWithFormat:@"carleton_%@_water_use", [building webName]];
            break;
        case kUsageTypeElectricity:
            nameString = [NSString stringWithFormat:@"carleton_%@_en_use", [building webName]];
            break;
        case kUsageTypeSteam:
            nameString = [NSString stringWithFormat:@"carleton_%@_steam_use", [building webName]];
            break;
        default:
            nameString = @"";
            break;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/reports/timeseries/?start=%@&end=%@&resolution=%@&name=%@", self.baseUrl, startString, endString, resolutionString, nameString];
    NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSLog(@"%@", [requestURL absoluteString]);
    NSURLResponse *response = nil;
    NSError *webError = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
    
    NSMutableArray *dataPoints = [[NSMutableArray alloc] init];
    
    // extract data from the JSON
    // TODO: more error handling
    if (webError == nil) {
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonError];
        if (jsonError == nil) {
            if (![[json objectForKey:@"results"] isEqual:[NSNull null]]) {
                NSDictionary *results = [json objectForKey:@"results"];
                NSDateFormatter *resultsFormatter = [[NSDateFormatter alloc] init];
                [resultsFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                
                for (NSDictionary *wrapper in results) {
                    NSDictionary *data = [wrapper objectForKey:nameString];
                    
                    // make sure that the data dictionary is not null
                    if (![[data valueForKey:nameString] isEqual:[NSNull null]]) {
                        CEDataPoint *point = [[CEDataPoint alloc] init];
                        NSDate *startTimestamp = [resultsFormatter dateFromString:[wrapper objectForKey:@"startTimestamp"]];
                        [point setTimestamp:startTimestamp];
                        [point setHoursElapsed:[[data valueForKey:@"hoursElapsed"] floatValue]];
                        [point setWeight:[[data valueForKey:@"weight"] floatValue]];
                        [point setValue:[[data valueForKey:@"value"] floatValue]];
                        [dataPoints addObject:point];
                    }
                }
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(retriever:gotUsage:ofType:forBuilding:)]) {
        [self.delegate retriever:self gotUsage:dataPoints ofType:usageType forBuilding:building];
    }
    [self setRequestInProgress:NO];
}

@end
