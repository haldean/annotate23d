//
//  MeshGenerator.m
//  Annotate23D
//
//  Created by William Brown on 2012/03/07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MeshGenerator.h"

#define VALUES_PER_VERT 6

@implementation MeshGenerator
@synthesize renderer;

+ (Mesh*) globalMesh:(WorkspaceUIView *)workspace {
  int i;
  int N = [[workspace drawables] count];
  if (N == 0) {
    return [[Mesh alloc] init];
  }
  
  NSMutableArray *meshes = [NSMutableArray arrayWithCapacity:N];
  for (i = 0; i < N; i++) {
    Drawable* drawable = [[workspace drawables] objectAtIndex:i];
    [meshes addObject:[drawable generateMesh]];
    if ([drawable isKindOfClass:[Cylinderoid class]]) {
      Cylinderoid* cyl = (Cylinderoid*) drawable;
      if ([cyl mirrorAnnotation] != nil) {
        [meshes addObject:[[cyl mirrorAnnotation] mirrored]];
      }
    }
  }
  return [Mesh combine:meshes];
}

- (id) initWithObjects:(WorkspaceUIView *)workspace {
  self = [super init];
  
  int i, size, N = [[workspace drawables] count];
  if (N == 0) {
    renderer = [[GlkRenderViewController alloc] initWithMesh:NULL ofSize:0];
    return self;
  }
  
  NSMutableArray *data = [[MeshGenerator globalMesh:workspace] pointData];
  
  size = [data count];
  float* cdata = malloc(sizeof(GLfloat) * (size + 1));
  for (i = 0; i < size; i++) {
    cdata[i] = [[data objectAtIndex:i] floatValue];
  }
  
  /* Center the mesh */
  float minx = INFINITY, maxx = -INFINITY,
        miny = INFINITY, maxy = -INFINITY,
        minz = INFINITY, maxz = -INFINITY,
        x, y, z;
  for (i = 0; i < size / VALUES_PER_VERT; i++) {
    x = cdata[VALUES_PER_VERT * i + 0];
    y = cdata[VALUES_PER_VERT * i + 1];
    z = cdata[VALUES_PER_VERT * i + 2];
    
    if (x < minx) minx = x; if (x > maxx) maxx = x;
    if (y < miny) miny = y; if (y > maxy) maxy = y;
    if (z < minz) minz = z; if (z > maxz) maxz = z;
  }
  
  float xc = minx + (maxx - minx) / 2,
        yc = miny + (maxy - miny) / 2,
        zc = minz + (maxz - minz) / 2;
  for (i = 0; i < size / VALUES_PER_VERT; i++) {
    cdata[VALUES_PER_VERT * i + 0] -= xc;
    cdata[VALUES_PER_VERT * i + 1] -= yc;
    /* Quartz Graphics and OpenGL disagree as to where the origin is, so
     * correct that here. */
    cdata[VALUES_PER_VERT * i + 1] *= -1.f;
    cdata[VALUES_PER_VERT * i + 2] -= zc;
  }
  
  renderer = [[GlkRenderViewController alloc] initWithMesh:cdata ofSize:size/6];
  return self;
}

@end
