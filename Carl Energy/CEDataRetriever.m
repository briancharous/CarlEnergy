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
    }
    return self;
}

- (void)getBuildingsOnCampus {
    NSString *urlString = [NSString stringWithFormat:@"%@/json/carleton/children/", self.baseUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error == nil) {
        
    }
}

- (void)getUsage:(UsageType)usageType ForBuilding:(NSString *)building startTime:(NSDate *)start endTime:(NSDate *)end resolution:(Resolution)res {
    
}

@end
