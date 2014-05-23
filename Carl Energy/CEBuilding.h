//
//  CEBuilding.h
//  Carl Energy
//
//  Created by Brian Charous on 5/9/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEBuilding : NSObject

@property NSString *displayName;
@property NSString *imageName;
@property NSMutableArray *meters; // meters keyed by usage type (see CEMeter.h)
@property NSInteger area;

@end
