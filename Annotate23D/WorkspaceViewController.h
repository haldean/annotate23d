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
#import "GlkRenderViewController.h"
#import "WorkspaceUIView.h"
#import "MeshGenerator.h"

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

@interface WorkspaceViewController : UIViewController <
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
FileMenuDelegate,
ReceivesDrawEvents> {
  CGFloat imageScale;
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
@property (weak, nonatomic) IBOutlet DrawPreviewUIView *drawPreview;
@property (weak, nonatomic) IBOutlet WorkspaceUIView *workspace;
@property (strong) MeshGenerator *meshGenerator;

- (IBAction)viewButton:(id)sender;
- (IBAction)showFileMenu:(id)sender;
- (IBAction)selectButton:(id)sender;
- (IBAction)splineButton:(id)sender;
- (IBAction)ellipseButton:(id)sender;
- (IBAction)connectButton:(id)sender;
- (IBAction)sameTiltButton:(id)sender;
- (IBAction)sameSizeButton:(id)sender;
- (IBAction)sameRadiusButton:(id)sender;
- (IBAction)mirrorShapeButton:(id)sender;
- (IBAction)alignShapeButton:(id)sender;
- (IBAction)centerShapeButton:(id)sender;
- (IBAction)renderButton:(id)sender;

- (void)buttonClick:(ToolMode)tool;
- (void)handleTap:(UIGestureRecognizer*)sender;

- (void)newSketch;
- (void)resetView;
- (void)loadNewBackgroundImage;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

@end
