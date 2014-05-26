//
//  CEAboutPageViewController.h
//  Carl Energy
//
//  Created by Michelle Chen on 5/23/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEAboutPageViewController : UIViewController
@property IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *developersLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
