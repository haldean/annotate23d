//
//  PopoverFileMenu.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FileMenuDelegate
-(void)newSketch;
-(void)loadNewBackgroundImage;
-(void)saveSketch:(NSString*)name;
-(void)loadSketch;
-(void)exportObj:(NSString*)name;
@end

@interface PopoverFileMenu : UIViewController
@property (nonatomic, assign) id<FileMenuDelegate> delegate;
- (IBAction)loadBackgroundImage:(id)sender;
- (IBAction)newSketch:(id)sender;
- (IBAction)saveSketch:(id)sender;
- (IBAction)loadSketch:(id)sender;
- (IBAction)exportObj:(id)sender;
@end


