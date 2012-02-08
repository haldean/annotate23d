//
//  ViewController.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

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
@end
