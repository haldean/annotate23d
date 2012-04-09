//
//  ViewController.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceViewController.h"

@implementation WorkspaceViewController
@synthesize drawPreview;
@synthesize workspace;
@synthesize drawView, backgroundImageView;
@synthesize fileMenu, fileButton, popoverController, imagePickerController;
@synthesize meshGenerator;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UITapGestureRecognizer *tapGestureRecognizer =
      [[UITapGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleTap:)];
  [drawView addGestureRecognizer:tapGestureRecognizer];
  
  UITapGestureRecognizer *doubleTapGestureRecognizer =
  [[UITapGestureRecognizer alloc]
   initWithTarget:self action:@selector(handleDoubleTap:)];
  [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
  [[self view] addGestureRecognizer:doubleTapGestureRecognizer];
  
  UILongPressGestureRecognizer* longPressGestureRecognizer =
      [[UILongPressGestureRecognizer alloc]
       initWithTarget:workspace action:@selector(handleLongPress:)];
  [drawView addGestureRecognizer:longPressGestureRecognizer];
  
  [drawView setBackgroundColor:[UIColor clearColor]];
  
  self.imagePickerController = [[UIImagePickerController alloc] init];
  self.imagePickerController.delegate = self;
  self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  
  startView = [drawPreview frame];
  
  [drawPreview setDelegate:self];
  [workspace setFrame:drawPreview.frame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [workspace touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([workspace shapeWantsTouching]) {
    [workspace touchesMoved:touches withEvent:event];
  } else {
    if ([touches count] == 1) {
      UITouch* touch = [[touches objectEnumerator] nextObject];
      CGPoint start = [touch previousLocationInView:drawView];
      CGPoint end = [touch locationInView:drawView];
      
      float dx = end.x - start.x, dy = end.y - start.y;
      [drawView setCenter:
       CGPointMake(drawView.center.x + dx, drawView.center.y + dy)];
      
    } else if ([touches count] == 2) {
      NSEnumerator* touchEnumerator = [touches objectEnumerator];
      UITouch* touch1 = [touchEnumerator nextObject];
      UITouch* touch2 = [touchEnumerator nextObject];
      
      CGPoint touch1_start = [touch1 previousLocationInView:drawView];
      CGPoint touch2_start = [touch2 previousLocationInView:drawView];
      CGPoint touch1_end = [touch1 locationInView:drawView];
      CGPoint touch2_end = [touch2 locationInView:drawView];
      
      
      double start_length = sqrt(pow(touch1_start.x - touch2_start.x, 2) +
                                 pow(touch1_start.y - touch2_start.y, 2));
      double end_length = sqrt(pow(touch1_end.x - touch2_end.x, 2) +
                               pow(touch1_end.y - touch2_end.y, 2));
      double scale = end_length / start_length;
      
      CGAffineTransform currentTransform = [drawView transform];
      CGAffineTransform newTransform = CGAffineTransformTranslate(
        CGAffineTransformScale(currentTransform, scale, scale),
        touch1_end.x - touch1_start.x, touch1_end.y - touch1_start.y);
      [drawView setTransform:newTransform];
    }
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [workspace touchesEnded:touches withEvent:event];
}

- (void)viewDidUnload
{
  [self setDrawView:nil];
  [self setBackgroundImageView:nil];
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

- (void)handleTap:(UIGestureRecognizer *)sender {
  CGPoint loc = [sender locationInView:sender.view];
  if (currentTool == SELECT) {
    shapeIsSelected = [workspace tapAtPoint:loc];
  } else if (currentTool == SAME_SIZE) {
    [workspace sameSize:loc];
  } else if (currentTool == SAME_RADIUS) {
    [workspace sameRadius:loc];
  } else if (currentTool == SAME_TILT) {
    [workspace sameTilt:loc];
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
      
    case SAME_SIZE:
    case SAME_RADIUS:
    case SAME_TILT:
      enableGestures = true;
      [workspace clearSelection];
      [workspace resetAnnotationState];
      
    case SPLINE:
    case ELLIPSE:
      enableGestures = false;
      break;
      
    default:
      impl = false;
      enableGestures = true;
      break;
  }
  
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

- (IBAction)renderButton:(id)sender {
  meshGenerator = [[MeshGenerator alloc] initWithObjects:workspace];
  [self setModalPresentationStyle:UIModalPresentationFullScreen];
  [self presentViewController:[meshGenerator renderer] animated:TRUE completion:nil];
}

@end
