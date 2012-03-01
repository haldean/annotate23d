//
//  ViewController.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize drawPreview;
@synthesize workspace;
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
  
  panGestureRecognizer = 
      [[UIPanGestureRecognizer alloc]
       initWithTarget:self action:@selector(handlePan:)];
  [drawView addGestureRecognizer:panGestureRecognizer];
  
  pinchGestureRecognizer =
      [[UIPinchGestureRecognizer alloc]
       initWithTarget:self action:@selector(handlePinch:)];
  [drawView addGestureRecognizer:pinchGestureRecognizer];
  
  tapGestureRecognizer =
      [[UITapGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleTap:)];
  [drawView addGestureRecognizer:tapGestureRecognizer];
  
  doubleTapGestureRecognizer =
  [[UITapGestureRecognizer alloc]
   initWithTarget:self action:@selector(handleDoubleTap:)];
  [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
  [drawView addGestureRecognizer:doubleTapGestureRecognizer];
  
  rotationGestureRecognizer =
      [[UIRotationGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleRotate:)];
  [drawView addGestureRecognizer:rotationGestureRecognizer];
  
  [drawView setBackgroundColor:[UIColor clearColor]];
  
  self.imagePickerController = [[UIImagePickerController alloc] init];
  self.imagePickerController.delegate = self;
  self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  
  startView = [drawPreview frame];
  CGPoint center = [drawPreview center];
  startView.size.width *= 5;
  startView.size.height *= 5;
  
  [drawView setFrame:startView];
  [drawView setCenter:center];
  startView = [drawView frame];
  [self resetView];
  
  
  [drawPreview setDelegate:self];
  [workspace setFrame:drawPreview.frame];
}

- (void)viewDidUnload
{
  [self setDrawView:nil];
  [self setBackgroundImageView:nil];
  [self setGlkView:nil];
  [self setDrawPreview:nil];
  [self setWorkspace:nil];
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

- (void)resetView {
  [drawView setFrame:startView];
  [drawPreview setFrame:startView];
  [workspace setFrame:startView];
}

- (void)handleDoubleTap:(UITapGestureRecognizer*)sender {
  [self resetView];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan ||
      sender.state == UIGestureRecognizerStateChanged) {
    UIView *view = sender.view;
    CGPoint translation = [sender translationInView:view.superview];
    
    if (shapeIsSelected) {
      [workspace translateSelectedShape:translation];
    } else {
      [view setCenter:
       CGPointMake(view.center.x + translation.x,
                   view.center.y + translation.y)];
    }
    
    [sender setTranslation:CGPointZero inView:view.superview];
  }
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender {
  if ([(UIPinchGestureRecognizer*) sender state] == UIGestureRecognizerStateEnded) {
		imageScale = 1.0;
		return;
	}
  
  CGFloat raw = [(UIPinchGestureRecognizer*)sender scale];
  CGFloat scale = 1.0 - (imageScale - raw);
  
  if (shapeIsSelected) {
    [workspace scaleSelectedShape:scale];
  } else {
    CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
	  [[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
  }
  
  imageScale = raw;
}

- (void)handleRotate:(UIGestureRecognizer *)sender {
  if (!shapeIsSelected || 
      [(UIRotationGestureRecognizer*) sender state] == UIGestureRecognizerStateEnded) {
		currentRotation = 0.0;
		return;
	}
  
  CGFloat raw = [(UIRotationGestureRecognizer*)sender rotation];
  CGFloat angle = raw - currentRotation;
  [workspace rotateSelectedShape:angle];
  currentRotation = raw;
}

- (void)handleTap:(UIGestureRecognizer *)sender {
  if (currentTool == SELECT) {
    shapeIsSelected = [workspace selectAtPoint:[sender locationInView:sender.view]];
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

- (void)newSketch {
  [[workspace drawables] removeAllObjects];
  [workspace setNeedsDisplay];
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

- (void)onPathDraw:(NSMutableArray *)points {
  if (currentTool == SPLINE) {
    Drawable* cyl = [Cylinderoid withPoints:points];
    [workspace addDrawable:cyl];
  } else if (currentTool == ELLIPSE) {
    Drawable* el = [Ellipsoid withPoints:points];
    [workspace addDrawable:el];
  }
}

- (void)buttonClick:(ToolMode)tool {
  currentTool = tool;
  
  bool enableGestures;
  bool impl = true;
  
  switch (currentTool) {
    case SELECT:
    case PAN:
      enableGestures = true;
      break;
      
    case SPLINE:
    case ELLIPSE:
      enableGestures = false;
      break;
      
    default:
      impl = false;
      enableGestures = true;
      break;
  }
  
  [panGestureRecognizer setEnabled:enableGestures];
  [pinchGestureRecognizer setEnabled:enableGestures];
  [rotationGestureRecognizer setEnabled:enableGestures];
  [drawPreview setCanHandleClicks:!enableGestures];
  
  if (!impl) {
    NSLog(@"Selected unimplemented tool %d", currentTool);
  }
}

- (IBAction)viewButton:(id)sender {
  [self buttonClick:PAN];
}

-(IBAction)selectButton:(id)sender {
  [self buttonClick:SELECT];
}

-(IBAction)splineButton:(id)sender {
  [self buttonClick:SPLINE];
}

-(IBAction)ellipseButton:(id)sender {
  [self buttonClick:ELLIPSE];
}

-(IBAction)connectButton:(id)sender {
  [self buttonClick:CONNECT];
}

-(IBAction)sameTiltButton:(id)sender {
  [self buttonClick:SAME_TILT];
}

-(IBAction)sameSizeButton:(id)sender {
  [self buttonClick:SAME_SIZE];
}

-(IBAction)sameRadiusButton:(id)sender {
  [self buttonClick:SAME_RADIUS];
}

-(IBAction)mirrorShapeButton:(id)sender {
  [self buttonClick:MIRROR_SHAPE];
}

-(IBAction)alignShapeButton:(id)sender {
  [self buttonClick:ALIGN_SHAPE];
}

-(IBAction)centerShapeButton:(id)sender {
  [self buttonClick:CENTER_SHAPE];
}

@end
