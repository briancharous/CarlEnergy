//
//  customSegueBack.m
//  Carl Energy
//
//  Created by Larkin Flodin on 6/1/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "customSegueBack.h"

@implementation customSegueBack

- (void) perform
{
    UIView *preV = ((UIViewController *)self.sourceViewController).view;
    UIView *newV = ((UIViewController *)self.destinationViewController).view;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    newV.center = CGPointMake(preV.center.x + preV.frame.size.width, newV.center.y);
    [window insertSubview:newV aboveSubview:preV];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         newV.center = CGPointMake(preV.center.x, newV.center.y);
                         preV.center = CGPointMake(0- preV.center.x, newV.center.y);}
                     completion:^(BOOL finished){
                         [preV removeFromSuperview];
                         window.rootViewController = self.destinationViewController;
                     }];
}

@end
