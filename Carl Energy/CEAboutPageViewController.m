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
    [self.textView setFrame:self.view.frame];
//    [self.textView setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"aboutPage"
                                                         ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    self.textView.text = content;
    // Do any additional setup after loading the view.
    
//    [self.welcomeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0]];
//    [self.instructionsLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
//    [self.developersLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
//    [self.textView setFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"aboutPage"
//                                                     ofType:@"txt"];
//    NSString *content = [NSString stringWithContentsOfFile:filePath
//                                                  encoding:NSUTF8StringEncoding
//                                                     error:NULL];
//    self.textView.text = content;
//    CGRect frame = self.textView.frame;
//    frame.size.height = self.textView.contentSize.height;
//    self.textView.frame = frame;
//    [self.scrollView setContentSize:self.textView.contentSize];
    //UIScrollView *tempScrollView=(UIScrollView *)self.scrollView;
    //tempScrollView.contentSize=CGSizeMake(1280,960);

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.textView setFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
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
