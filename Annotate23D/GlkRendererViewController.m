//
//  GlkRendererViewController.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GlkRendererViewController.h"

@interface GlkRendererViewController () {
  GlkRenderer* renderer;
}
@property (strong, nonatomic) EAGLContext *context;
@end

@implementation GlkRendererViewController

@synthesize context = _context;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  renderer = [[GlkRenderer alloc] init];
  
  if (!self.context) {
    NSLog(@"Failed to create ES context");
  }
  
  GLKView *view = (GLKView *)self.view;
  view.context = self.context;
  view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
  view.delegate = renderer;
  
}

@end
