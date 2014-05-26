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
    
//    [self setRequestInProgress:YES];
//    
//    NSMutableArray *buildings = [[NSMutableArray alloc] init];
//    
//    // fire off a web request
//    NSString *urlString = [NSString stringWithFormat:@"%@/json/carleton/children", self.baseUrl];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSURLResponse *response = nil;
//    NSError *webError = nil;
//    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
//    
//    //TODO: Error handling
//    if (webError == nil) {
//        NSError *jsonError = nil;
//        NSArray *json = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonError];
//        if (jsonError == nil) {
//            for (NSDictionary *buildingJSON in json) {
//                CEBuilding *b = [[CEBuilding alloc] init];
//                [b setDisplayName:[buildingJSON objectForKey:@"displayName"]];
//                [b setWebName:[buildingJSON objectForKey:@"urlElement"]];
//                [b setImageURL:[buildingJSON objectForKey:@"profile"]];
//                [buildings addObject:b];
//            }
//        }
//    }
    
    
    // read from plist
    NSArray *buildingsDictionaries = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"plist"]];
    NSMutableArray *buildingsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in buildingsDictionaries) {
        CEBuilding *building = [self buildingFromDictionary:dict];
        [buildingsArray addObject:building];
    }
    
    if ([self.delegate respondsToSelector:@selector(retriever:gotBuildings:)]) {
        [self.delegate retriever:self gotBuildings:buildingsArray];
    }
    [self setRequestInProgress:NO];
}

- (CEBuilding *)buildingFromDictionary:(NSDictionary *)dict {
    CEBuilding *building = [[CEBuilding alloc] init];
    [building setDisplayName:[dict objectForKey:@"displayName"]];
    [building setImageName:[dict objectForKey:@"image"]];
    [building setArea:[[dict objectForKey:@"area"] integerValue]];
    
    NSMutableArray *meters = [[NSMutableArray alloc] init];
    
    NSArray *metersDictionaries = [dict objectForKey:@"meters"];
    for (NSDictionary *meterDict in metersDictionaries) {
        CEMeter *meter = [[CEMeter alloc] init];
        [meter setUsageType:[[meterDict objectForKey:@"type"] integerValue]];
        [meter setSystemName:[meterDict objectForKey:@"systemName"]];
        [meter setDisplayName:[meterDict objectForKey:@"displayName"]];
        [meters addObject:meter];
    }
    
    [building setMeters:meters];
    return building;
}

- (NSArray *)syncGetUsage:(UsageType)usageType ForBuilding:(CEBuilding *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd+HH:mm:ss"];
    NSString *startString = [formatter stringFromDate:start];
    NSString *endString = [formatter stringFromDate:end];
    
    // pick out the resolution string
    NSString *resolutionString;
    switch (res) {
        case kResolutionLive:
            resolutionString = @"live";
            break;
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
    
    // get the meter system name
    NSMutableArray *meters = [[NSMutableArray alloc] init];
    for (CEMeter *meter in [building meters]) {
        if (meter.usageType == usageType) {
            [meters addObject:meter];
        }
    }
    
    NSMutableArray *dataPoints = [[NSMutableArray alloc] init];
    
    for (CEMeter *meter in meters) {
        NSString *nameString = [meter systemName];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/reports/timeseries/?start=%@&end=%@&resolution=%@&name=%@", self.baseUrl, startString, endString, resolutionString, nameString];
        NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
//        NSLog(@"%@", [requestURL absoluteString]);
        NSURLResponse *response = nil;
        NSError *webError = nil;
        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
        
        
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
    }
    
    return dataPoints;
}

- (void)getUsage:(UsageType)usageType ForBuilding:(CEBuilding *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
    [self setRequestInProgress:YES];
    
    NSArray *dataPoints = [self syncGetUsage:usageType ForBuilding:building startTime:start endTime:end resolution:res];
    
    if ([self.delegate respondsToSelector:@selector(retriever:gotUsage:ofType:forBuilding:)]) {
        [self.delegate retriever:self gotUsage:dataPoints ofType:usageType forBuilding:building];
    }
    [self setRequestInProgress:NO];
}

- (void)getTotalWindProductionWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
    
    [self setRequestInProgress:YES];
    CEBuilding *mainCampus = nil;

    NSArray *buildingsDictionaries = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"plist"]];
    for (NSDictionary *dict in buildingsDictionaries) {
        if ([[dict objectForKey:@"displayName"] isEqualToString:@"Main Campus"]) {
            mainCampus = [self buildingFromDictionary:dict];
            break;
        }
    }
    
    // remove turbine 1 from the list of meters so that data does not get factored
    // into the total wind production because turbine 1 is hooked up to Xcel
    // and not the Carleton grid.
    NSMutableArray *metersNoTurbine1 = [[NSMutableArray alloc] init];
    for (CEMeter *meter in mainCampus.meters) {
        if (![meter.systemName isEqualToString:@"carleton_turbine1_produced_power"]) {
            [metersNoTurbine1 addObject:meter];
        }
    }
    [mainCampus setMeters:metersNoTurbine1];
    
    NSArray *points = [self syncGetUsage:kUsageTypeWindProduction ForBuilding:mainCampus startTime:start endTime:end resolution:res];
    
    if ([self.delegate respondsToSelector:@selector(retriever:gotWindProduction:)]) {
        [self.delegate retriever:self gotWindProduction:points];
    }
    
    [self setRequestInProgress:NO];
}

- (void)getTotalCampusElectricityUsageWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {

    [self setRequestInProgress:YES];
    CEBuilding *mainCampus = nil;
    
    NSArray *buildingsDictionaries = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"plist"]];
    for (NSDictionary *dict in buildingsDictionaries) {
        if ([[dict objectForKey:@"displayName"] isEqualToString:@"Main Campus"]) {
            mainCampus = [self buildingFromDictionary:dict];
            break;
        }
    }
    
    NSArray *points = [self syncGetUsage:kUsageTypeElectricity ForBuilding:mainCampus startTime:start endTime:end resolution:res];
    
    if ([self.delegate respondsToSelector:@selector(retriever:gotCampusElectricityUsage:)]) {
        [self.delegate retriever:self gotCampusElectricityUsage:points];
    }
    
    [self setRequestInProgress:NO];
    
}

// These use the wrong usageType
//- (void)getTotalCampusGasUsageWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
//    
//    [self setRequestInProgress:YES];
//    CEBuilding *mainCampus = nil;
//    
//    NSArray *buildingsDictionaries = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"plist"]];
//    for (NSDictionary *dict in buildingsDictionaries) {
//        if ([[dict objectForKey:@"displayName"] isEqualToString:@"Main Campus"]) {
//            mainCampus = [self buildingFromDictionary:dict];
//            break;
//        }
//    }
//    
//    NSArray *points = [self syncGetUsage:kUsageTypeElectricity ForBuilding:mainCampus startTime:start endTime:end resolution:res];
//    
//    if ([self.delegate respondsToSelector:@selector(retriever:gotCampusGasUsage:)]) {
//        [self.delegate retriever:self gotCampusGasUsage:points];
//    }
//    
//    [self setRequestInProgress:NO];
//    
//}
//
//- (void)getTotalCampusFuelUsageWithStartTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
//    
//    [self setRequestInProgress:YES];
//    CEBuilding *mainCampus = nil;
//    
//    NSArray *buildingsDictionaries = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"buildings" ofType:@"plist"]];
//    for (NSDictionary *dict in buildingsDictionaries) {
//        if ([[dict objectForKey:@"displayName"] isEqualToString:@"Main Campus"]) {
//            mainCampus = [self buildingFromDictionary:dict];
//            break;
//        }
//    }
//    
//    NSArray *points = [self syncGetUsage:kUsageTypeElectricity ForBuilding:mainCampus startTime:start endTime:end resolution:res];
//    
//    if ([self.delegate respondsToSelector:@selector(retriever:gotCampusFuelUsage:)]) {
//        [self.delegate retriever:self gotCampusFuelUsage:points];
//    }
//    
//    [self setRequestInProgress:NO];

//}

@end
