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
#import "CEElectricityUsageView.h"

@interface CEDashboardViewController : UIViewController <CEDataRetrieverDelegate> {

    CEWindView *windView;
    CEElectricityUsageView *elecView;
}

- (void)makeTurbine;
- (void)restartBladeAnimation;
- (void)makeUsageView;

@property IBOutlet UIScrollView *scrollView;

@end
