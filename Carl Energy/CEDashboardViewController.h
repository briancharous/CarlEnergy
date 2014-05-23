//
//  SecondViewController.h
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEDataRetriever.h"
#import "CorePlot-CocoaTouch.h"


@interface CEDashboardViewController : UIViewController <CEDataRetrieverDelegate, CPTPlotDataSource> {
    NSNumber *windProduction;
    NSNumber *energyConsumption;
    BOOL gotWindProduction;
    BOOL gotElectricityUsage;
    CPTXYGraph *pieChart;
}

- (void)makePieChart;
- (void)getElectricProducionAndUsage;
- (void)updatePieChart;

@property (readwrite, strong, nonatomic) NSMutableArray *dataForChart;
@property IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;

@end
