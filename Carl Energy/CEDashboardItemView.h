//
//  CEDashboardItemView.h
//  Carl Energy
//
//  Created by Brian Charous on 5/28/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CEDashboardItemViewDelegate;

@interface CEDashboardItemView : UIView
// NEVER MAKE AN OBJECT OF THIS CLASS
// ALWAYS MAKE SUBCLASSES OF THIS CLASS

@property (nonatomic, assign) id <CEDashboardItemViewDelegate> delegate;

- (void)refreshData;
- (NSInteger)preferredHeightForPortrait;
+ (NSInteger)preferredHeightForPortrait;
- (NSInteger)preferredHeightForLandscape;
+ (NSInteger)preferredHeightForLandscape;
- (void)restartAnimation;

@end

@protocol CEDashboardItemViewDelegate <NSObject>

@optional

-(void)dashboardItemViewRefreshedData:(CEDashboardItemView *)view;

@end
