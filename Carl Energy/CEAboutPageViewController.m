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
    
    UIScrollView *tempScrollView=(UIScrollView *)self.scrollView;
    tempScrollView.contentSize=CGSizeMake(1280,960);

}

- (void)makeLabel
{
    self.label.text = @"Instructions: The Dashboard displays information on current campus energy usage. You may select one of the buildings on the Buildings list to view the individual building's energy usage. You may change the time reference to see daily, weekly, monthly, and yearly energy usage.";
    
    [self.scrollView setFrame:self.view.bounds];
    [self.scrollView addSubview:self.label];
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
