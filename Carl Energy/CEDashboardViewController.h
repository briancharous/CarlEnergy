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


@interface CEDashboardViewController : UIViewController <CEDataRetrieverDelegate, CPTPlotDataSource>

@property (readwrite, strong, nonatomic) NSMutableArray *dataForChart;
@property IBOutlet UIScrollView *scrollView;

@end
