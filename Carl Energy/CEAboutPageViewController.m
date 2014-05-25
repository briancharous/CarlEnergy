//
//  CEAboutPageViewController.m
//  Carl Energy
//
//  Created by Michelle Chen on 5/23/14.
//  Copyright (c) 2014 Carleton College. All rights reserved.
//

#import "CEAboutPageViewController.h"

@interface CEAboutPageViewController ()

@end

@implementation CEAboutPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.welcomeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0]];
    [self.instructionsLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
    [self.developersLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];


    
    //UIScrollView *tempScrollView=(UIScrollView *)self.scrollView;
    //tempScrollView.contentSize=CGSizeMake(1280,960);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
