//
//  CEDataPoint.h
//  Carl Energy
//
//  Created by Brian Charous on 5/9/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEDataPoint : NSObject

- (instancetype)initWithTimestamp:(NSDate *)timestamp hoursElapsed:(float)hoursElapsed weight:(float)weight value:(float)value;

@property NSDate *timestamp;
@property float hoursElapsed;
@property float weight;
@property float value;

@end
