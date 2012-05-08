//
//  Drawable.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Drawable.h"

@implementation Drawable
@synthesize com, ident;

int last_ident = 0;
+ (int) nextIdent {
  last_ident++;
  return last_ident;
}

- (Mesh*)generateMesh {
  [NSException raise:@"Drawable is abstract" format:@"Cannot create mesh for Drawable directly."];
  return NULL;
}

- (CGMutablePathRef)getPath {
  return path;
}

+ (Drawable*)withPoints:(NSArray*)points {
  [NSException raise:@"Drawable is abstract" format:@"Cannot instantiate Drawable directly."];
  return NULL;
}

@end
