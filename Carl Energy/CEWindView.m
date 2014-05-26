//
//  CEWindView.m
//  Carl Energy
//
//  Created by Brian Charous on 5/25/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEWindView.h"

@implementation CEWindView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)startBladeAnimation {
    NSLog(@"animate!!");
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * .5];
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    
    [self.bladesView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self.bladesView2.layer addAnimation:rotationAnimation forKey:@"roationAnimation2"];
}

//- (void)dealloc {
////    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDid object:<#(id)#>]
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
