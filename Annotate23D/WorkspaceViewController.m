//
//  ViewController.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceViewController.h"
#import "SceneArchiver.h"

@implementation SavedScenesDataSource

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray* files = [SceneArchiver savedScenes];
  NSString* file = [files objectAtIndex:indexPath.row];
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:file];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:file];
  }
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.textLabel.text = file;
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  int count = [[SceneArchiver savedScenes] count];
  return count;
}

- (NSString *) pathAtIndex:(NSIndexPath *)indexPath {
  return [[SceneArchiver savedScenes] objectAtIndex:indexPath.row];
}

- (bool)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"delete!");
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [SceneArchiver deleteScene:[self pathAtIndex:indexPath]];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

@end

@implementation WorkspaceViewController
@synthesize drawPreview;
@synthesize workspace;
@synthesize drawView, backgroundImageView;
@synthesize fileMenu, fileButton, popoverController, imagePickerController;
@synthesize meshGenerator;
@synthesize instructionLabel;

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
  
  [self nextTapWill:nil];
  [self.backgroundImageView setImage:nil];
  
  [drawPreview setDelegate:self];
  [workspace setFrame:drawPreview.frame];
  [workspace setExplainer:self];
  
  ssds = [[SavedScenesDataSource alloc] init];
  tableViewController = [[UITableViewController alloc] init];
  tableNavController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
  tableViewController.navigationItem.leftBarButtonItem = tableViewController.editButtonItem;
  tableViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissPopovers)];
}

- (void)dismissPopovers {
  [tableNavController dismissModalViewControllerAnimated:true];
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
  [self setInstructionLabel:nil];
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

- (void)nextTapWill:(NSString *)doThis {
  if (doThis != nil) {
    [instructionLabel setText:doThis];
  } else {
    [self showToolHelp];
  }
}

- (void)handleTap:(UIGestureRecognizer *)sender {
  CGPoint loc = [sender locationInView:sender.view];
  bool switchToSelect = false;
  if (currentTool == SELECT) {
    shapeIsSelected = [workspace tapAtPoint:loc];
  } else if (currentTool == SAME_SIZE) {
    switchToSelect = [workspace sameSize:loc];
  } else if (currentTool == SAME_RADIUS) {
    switchToSelect = [workspace sameRadius:loc];
  } else if (currentTool == SAME_TILT) {
    switchToSelect = [workspace sameTilt:loc];
  } else if (currentTool == CONNECT) {
    switchToSelect = [workspace connection:loc];
  } else if (currentTool == MIRROR_SHAPE) {
    switchToSelect = [workspace mirror:loc];
  } else if (currentTool == ALIGN_SHAPE) {
    switchToSelect = [workspace alignto:loc];
  }
  if (switchToSelect) {
    [self selectTool:SELECT];
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

- (void)saveSketch:(NSString*)name {
  [SceneArchiver saveDrawables:[workspace drawables] withName:name];
}

- (void) loadSketch {
  [popoverController dismissPopoverAnimated:true];
  
  if ([[SceneArchiver savedScenes] count] == 0) {
    UIAlertView *message =
    [[UIAlertView alloc]
     initWithTitle:@"No Saved Scenes"
     message:@"You haven't saved any scenes yet. You can save a scene by selecting File > Save"
     delegate:nil
     cancelButtonTitle:@"Close"
     otherButtonTitles:nil];
    [message show];
    return;
  }
  
  [tableViewController.tableView setDataSource:ssds];
  [tableViewController.tableView setDelegate:self];
  
  [self setModalPresentationStyle:UIModalPresentationFullScreen];
  [self presentViewController:tableNavController animated:TRUE completion:nil];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  NSString *name = [ssds pathAtIndex:indexPath];
  workspace.drawables = [SceneArchiver loadDrawablesWithName:name];
  [tableNavController dismissModalViewControllerAnimated:true];
  [workspace setNeedsDisplay];
}

- (void)showToolHelp {
  switch (currentTool) {
    case SELECT:
      [self nextTapWill:@"Next tap will select a shape"];
      break;
      
    case PAN:
      [self nextTapWill:@"Swipe to pan view, pinch to zoom view"];
      break;
      
    case SAME_SIZE:
      [self nextTapWill:@"Select the first shape to make of equal size"];
      break;
      
    case SAME_TILT:
      [self nextTapWill:@"Select the first shape to make of equal tilt"];
      break;
      
    case SAME_RADIUS:
      [self nextTapWill:@"Select the first shape to make of equal radius"];
      break;
      
    case CONNECT:
      [self nextTapWill:@"Select the stationary shape to connect to"];
      break;
      
    case MIRROR_SHAPE:
      [self nextTapWill:@"Select the shape to reflect"];
      break;
      
    case ALIGN_SHAPE:
      [self nextTapWill:@"Select the shape to align"];
      break;
      
    case SPLINE:
      [self nextTapWill:@"Draw the spine of a cylinder"];
      break;
      
    case ELLIPSE:
      [self nextTapWill:@"Draw the outline of an ellipse"];
      break;
      
    default:
      break;
  }
}

- (void)selectTool:(ToolMode)tool {
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
    case CONNECT:
    case MIRROR_SHAPE:
    case ALIGN_SHAPE:
      enableGestures = true;
      
    case SPLINE:
    case ELLIPSE:
      enableGestures = false;
      break;
      
    default:
      impl = false;
      enableGestures = true;
      break;
  }
  
  [workspace clearSelection];
  [workspace resetAnnotationState];
  [drawPreview setCanHandleClicks:!enableGestures];
  
  [self showToolHelp];
  
  if (!impl) {
    NSLog(@"Selected unimplemented tool %d", currentTool);
  }
}

- (IBAction)viewButton:(id)sender {
  [self selectTool:PAN];
}

-(IBAction)selectButton:(id)sender {
  [self selectTool:SELECT];
}

-(IBAction)splineButton:(id)sender {
  [self selectTool:SPLINE];
}

-(IBAction)ellipseButton:(id)sender {
  [self selectTool:ELLIPSE];
}

-(IBAction)connectButton:(id)sender {
  [self selectTool:CONNECT];
}

-(IBAction)sameTiltButton:(id)sender {
  [self selectTool:SAME_TILT];
}

-(IBAction)sameSizeButton:(id)sender {
  [self selectTool:SAME_SIZE];
}

-(IBAction)sameRadiusButton:(id)sender {
  [self selectTool:SAME_RADIUS];
}

-(IBAction)mirrorShapeButton:(id)sender {
  [self selectTool:MIRROR_SHAPE];
}

-(IBAction)alignShapeButton:(id)sender {
  [self selectTool:ALIGN_SHAPE];
}

-(IBAction)centerShapeButton:(id)sender {
  [self selectTool:CENTER_SHAPE];
}

- (IBAction)renderButton:(id)sender {
  meshGenerator = [[MeshGenerator alloc] initWithObjects:workspace];
  [self setModalPresentationStyle:UIModalPresentationFullScreen];
  [self presentViewController:[meshGenerator renderer] animated:TRUE completion:nil];
}

@end
