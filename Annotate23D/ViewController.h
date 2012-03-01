//
//  ViewController.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "PopoverFileMenu.h"
#import "DrawPreviewUIView.h"
#import "GlkRenderer.h"
#import "WorkspaceUIView.h"

typedef enum {
  SELECT,
  SPLINE,
  ELLIPSE,
  CONNECT,
  SAME_TILT,
  SAME_SIZE,
  SAME_RADIUS,
  MIRROR_SHAPE,
  ALIGN_SHAPE,
  CENTER_SHAPE,
  PAN
} ToolMode;

@interface ViewController : UIViewController <
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
FileMenuDelegate,
ReceivesDrawEvents> {
  
  GlkRenderer* renderer;
  CGFloat imageScale;
  CGFloat currentRotation;
  UIPanGestureRecognizer *panGestureRecognizer;
  UIPinchGestureRecognizer *pinchGestureRecognizer;
  UITapGestureRecognizer *tapGestureRecognizer;
  UITapGestureRecognizer *doubleTapGestureRecognizer;
  UIRotationGestureRecognizer *rotationGestureRecognizer;
  ToolMode currentTool;
  CGRect startView;
  bool shapeIsSelected;
}

@property (weak, nonatomic) IBOutlet UIView *drawView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) PopoverFileMenu *fileMenu;
@property (weak, nonatomic) UIButton *fileButton;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (strong, nonatomic) EAGLContext *context;
@property (weak, nonatomic) IBOutlet DrawPreviewUIView *drawPreview;
@property (weak, nonatomic) IBOutlet WorkspaceUIView *workspace;

-(IBAction)viewButton:(id)sender;
-(IBAction)showFileMenu:(id)sender;
-(IBAction)selectButton:(id)sender;
-(IBAction)splineButton:(id)sender;
-(IBAction)ellipseButton:(id)sender;
-(IBAction)connectButton:(id)sender;
-(IBAction)sameTiltButton:(id)sender;
-(IBAction)sameSizeButton:(id)sender;
-(IBAction)sameRadiusButton:(id)sender;
-(IBAction)mirrorShapeButton:(id)sender;
-(IBAction)alignShapeButton:(id)sender;
-(IBAction)centerShapeButton:(id)sender;

-(void)buttonClick:(ToolMode)tool;

-(void)handlePan:(UIGestureRecognizer*)sender;
-(void)handleTap:(UIGestureRecognizer*)sender;
-(void)handlePinch:(UIGestureRecognizer*)sender;
-(void)handleRotate:(UIGestureRecognizer*)sender;

-(void)newSketch;
-(void)resetView;
-(void)loadNewBackgroundImage;
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

@end
