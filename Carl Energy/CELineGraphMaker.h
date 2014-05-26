//
//  CELineGraphMaker.h
//  Carl Energy
//
//  Created by Larkin Flodin on 5/25/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEDataRetriever.h"
#import "CorePlot-CocoaTouch.h"
#import "CEMeter.h"

typedef NS_ENUM(NSInteger, CETimeScale) {
    kTimeScaleDay,
    kTimeScaleWeek,
    kTimeScaleMonth,
    kTimeScaleYear
};

extern NSString * const CEClear;
extern NSString * const CEElectric;

@interface CELineGraphMaker : NSObject <CEDataRetrieverDelegate, CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForElectricityChart;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForClearChart;
@property CEBuilding *building;
@property CPTXYGraph *electricityLineGraph;
@property CPTAxis *x;
@property CPTAxis *y;
@property int requestType;
- (void)requestDataOfType:(UsageType)type forBuilding:(CEBuilding*)building forTimeScale:(CETimeScale)timeScale;
- (void)reloadPlotData;
-(CPTGraph *)makeLineGraphForTime:(NSInteger)timeframeIndex forBuilding:(CEBuilding*)building;

@end
