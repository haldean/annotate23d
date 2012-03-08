//
//  MeshGenerator.h
//  Annotate23D
//
//  Created by William Brown on 2012/03/07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlkRenderViewController.h"
#import "WorkspaceUIView.h"
#import "Drawable.h"

@interface MeshGenerator : NSObject

@property (strong) GlkRenderViewController* renderer;

- (id) initWithObjects:(WorkspaceUIView*)workspace;

@end
