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

@interface CEBuildingDetailViewController : UIViewController //<CEDataRetrieverDelegate, CPTPlotDataSource>

@property IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property CEBuilding *building;
@property CPTGraphHostingView *electricityLineGraphView;
@property CPTGraphHostingView *waterLineGraphView;
@property CPTGraphHostingView *steamLineGraphView;
@property CPTGraph *elecLineGraph;
@property CPTGraph *waterLineGraph;
@property CPTGraph *steamLineGraph;
@property CELineGraphMaker *elecGraphMaker;
@property CELineGraphMaker *waterGraphMaker;
@property CELineGraphMaker *steamGraphMaker;

@end

