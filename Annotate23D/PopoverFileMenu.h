//
//  PopoverFileMenu.h
//  Annotate23D
//
//  Created by William Brown on 2012/02/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FileMenuDelegate
-(void)loadNewBackgroundImage;
@end

@interface PopoverFileMenu : UIViewController
@property (nonatomic, assign) id<FileMenuDelegate> delegate;
-(IBAction)loadBackgroundImage:(id)sender;
@end


