//
//  ViewController.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize drawView, backgroundImageView;
@synthesize fileMenu, fileButton, popoverController, imagePickerController;
@synthesize glkView, context;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  renderer = [[GlkRenderer alloc] init];
  glkView.context = self.context;
  glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
  glkView.delegate = renderer;
  glkView.backgroundColor = [UIColor greenColor];
  
  UIPanGestureRecognizer *panGestureRecognizer = 
      [[UIPanGestureRecognizer alloc]
       initWithTarget:self action:@selector(handlePan:)];
  [drawView addGestureRecognizer:panGestureRecognizer];
  [drawView setBackgroundColor:[UIColor clearColor]];
  
  self.imagePickerController = [[UIImagePickerController alloc] init];
  self.imagePickerController.delegate = self;
  self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)viewDidUnload
{
  [self setDrawView:nil];
  [self setBackgroundImageView:nil];
  [self setGlkView:nil];
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

- (void)handlePan:(UIPanGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan ||
      sender.state == UIGestureRecognizerStateChanged) {
    UIView *view = sender.view;
    CGPoint translation = [sender translationInView:view.superview];
    [view setCenter:
     CGPointMake(view.center.x + translation.x,
                 view.center.y + translation.y)];
    [sender setTranslation:CGPointZero inView:view.superview];
  }
}

- (void)showFileMenu:(id)sender {
  if ([popoverController isPopoverVisible]){
    [popoverController dismissPopoverAnimated:YES];
  } else {
		fileMenu = [[PopoverFileMenu alloc]
                initWithNibName:@"PopoverFileMenu" bundle:nil];
    fileMenu.delegate = self;
    
		popoverController = [[UIPopoverController alloc]
                          initWithContentViewController:fileMenu];
		[popoverController setPopoverContentSize:CGSizeMake(422.0, 44.0)];
    [popoverController
     presentPopoverFromRect:CGRectMake(20, 20, 101, 37)
     inView:self.view
     permittedArrowDirections:UIPopoverArrowDirectionAny
     animated:YES];
	}
}

- (void)loadNewBackgroundImage {
  // Hide file menu first.
  [popoverController dismissPopoverAnimated:YES];
  popoverController = [[UIPopoverController alloc]
                       initWithContentViewController:imagePickerController];
  [popoverController
   presentPopoverFromRect:CGRectMake(20, 20, 101, 37)
   inView:self.view
   permittedArrowDirections:UIPopoverArrowDirectionLeft
   animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  [self.backgroundImageView setImage:image];
}
  
- (void)buttonClick:(NSString*)toolName {
  UIAlertView *message =
  [[UIAlertView alloc]
   initWithTitle:@"Tool selected"
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
