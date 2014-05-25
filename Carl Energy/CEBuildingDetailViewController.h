//
//  CEBuildingDetailViewController.h
//  Carl Energy
//
//  Created by Michelle Chen on 5/10/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEDataRetriever.h"
#import "CorePlot-CocoaTouch.h"
#import "CEMeter.h"
#import "CELineGraphMaker.h"

//typedef NS_ENUM(NSInteger, CETimeScale) {
//    kTimeScaleDay,
//    kTimeScaleWeek,
//    kTimeScaleMonth,
//    kTimeScaleYear
//};


//extern NSString * const CEClear;
//extern NSString * const CEElectric;


@interface CEBuildingDetailViewController : UIViewController //<CEDataRetrieverDelegate, CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;
//@property (readwrite, strong, nonatomic) NSMutableArray *dataForElectricityChart;
//@property (readwrite, strong, nonatomic) NSMutableArray *dataForClearChart;
@property IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property CEBuilding *building;
@property CPTGraphHostingView *electricityLineGraphView;
@property CELineGraphMaker *graphMaker;

//- (void)requestDataOfType:(UsageType)type forTimeScale:(CETimeScale)timeScale;
//- (IBAction)timeChanged:(UISegmentedControl *)sender;
//- (void)reloadPlotData;


@end

