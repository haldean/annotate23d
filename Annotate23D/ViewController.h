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
#import "GlkRenderer.h"

@interface ViewController : UIViewController <
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    FileMenuDelegate> {
  GlkRenderer* renderer;
}

@property (weak, nonatomic) IBOutlet UIView *drawView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) PopoverFileMenu *fileMenu;
@property (weak, nonatomic) UIButton *fileButton;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (strong, nonatomic) EAGLContext *context;

-(IBAction)showFileMenu:(id)sender;
-(IBAction)selectButton:(id)sender;
-(IBAction)splineButton:(id)sender;
-(IBAction)cuboidButton:(id)sender;
-(IBAction)ellipseButton:(id)sender;
-(IBAction)connectButton:(id)sender;
-(IBAction)sameTiltButton:(id)sender;
-(IBAction)sameSizeButton:(id)sender;
-(IBAction)sameRadiusButton:(id)sender;
-(IBAction)mirrorShapeButton:(id)sender;
-(IBAction)alignShapeButton:(id)sender;
-(IBAction)centerShapeButton:(id)sender;

-(void)buttonClick:(NSString*)toolName;

-(void)handlePan:(UIGestureRecognizer*)sender;

-(void)loadNewBackgroundImage;
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

@end
