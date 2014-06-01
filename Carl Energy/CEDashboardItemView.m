//
//  CEDashboardItemView.m
//  Carl Energy
//
//  Created by Brian Charous on 5/28/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]

#import "CEDashboardItemView.h"

@implementation CEDashboardItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)refreshData {}

- (NSInteger)preferredHeightForPortrait {
    return 350;
}

+ (NSInteger)preferredHeightForPortrait {
    return 350;
}

- (NSInteger)preferredHeightForLandscape {
    return 350;
}

+ (NSInteger)preferredHeightForLandscape {
    return 350;
}

- (void)restartAnimation {}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
