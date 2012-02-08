//
//  ViewController.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  UIPanGestureRecognizer *panGestureRecognizer = 
      [[UIPanGestureRecognizer alloc]
       initWithTarget:self action:@selector(handlePan:)];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return YES;
}

- (void)handlePan:(UIGestureRecognizer *)sender {
  NSLog(@"Detected pan gesture.");
}

- (void)buttonClick:(NSString*)toolName {
  UIAlertView *message =
  [[UIAlertView alloc]
   initWithTitle:@"Tool clicked"
   message:[NSString stringWithFormat:@"You selected the %@ tool.", toolName]
   delegate:nil
   cancelButtonTitle:@"Thanks!"
   otherButtonTitles:nil];
  [message show];
}

- (IBAction)selectButton:(id)sender {
  [self buttonClick:@"select"];
}

-(IBAction)splineButton:(id)sender {
  [self buttonClick:@"spline"];
}

-(IBAction)cuboidButton:(id)sender {
  [self buttonClick:@"cuboid"];
}

-(IBAction)ellipseButton:(id)sender {
  [self buttonClick:@"ellipse"];
}

-(IBAction)connectButton:(id)sender {
  [self buttonClick:@"connection"];
}

-(IBAction)sameTiltButton:(id)sender {
  [self buttonClick:@"same-tilt annotation"];
}

-(IBAction)sameSizeButton:(id)sender {
  [self buttonClick:@"same-size annotation"];
}

-(IBAction)sameRadiusButton:(id)sender {
  [self buttonClick:@"same-radius annotation"];
}

-(IBAction)mirrorShapeButton:(id)sender {
  [self buttonClick:@"mirror shape"];
}

-(IBAction)alignShapeButton:(id)sender {
  [self buttonClick:@"align shape"];
}

-(IBAction)centerShapeButton:(id)sender {
  [self buttonClick:@"center shape"];
}

@end
