//
//  SecondViewController.h
//  Carl Energy
//
//  Created by Brian Charous on 5/7/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEDataRetriever.h"
#import "CEWindView.h"

@interface CEDashboardViewController : UIViewController <CEDataRetrieverDelegate> {
    NSNumber *windProduction;
    NSNumber *energyConsumption;
    NSNumber *gasConsumption;
    NSNumber *fuelConsumption;
    BOOL gotWindProduction;
    BOOL gotElectricityUsage;
<<<<<<< HEAD
    BOOL gotGasUsage;
    BOOL gotFuelUsage;
    CPTXYGraph *pieChart;
}

- (void)makePieChart;
- (void)getElectricProductionAndUsage;
- (void)updatePieChart;
=======
    CEWindView *windView;
}

- (void)getElectricProducionAndUsage;
- (void)updateUsageData;
- (void)makeTurbine;
- (void)restartBladeAnimation;
>>>>>>> no-coreplot

@property (readwrite, strong, nonatomic) NSMutableArray *dataForChart;
@property IBOutlet UIScrollView *scrollView;

@end
