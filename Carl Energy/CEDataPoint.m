//
//  CEDataPoint.m
//  Carl Energy
//
//  Created by Brian Charous on 5/9/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEDataPoint.h"

@implementation CEDataPoint

- (instancetype)initWithTimestamp:(NSDate *)timestamp hoursElapsed:(float)hoursElapsed weight:(float)weight value:(float)value {
    self = [super init];
    if (self) {
        [self setTimestamp:timestamp];
        [self setHoursElapsed:hoursElapsed];
        [self setWeight:weight];
        [self setValue:value];
    }
    return self;
}

@end
