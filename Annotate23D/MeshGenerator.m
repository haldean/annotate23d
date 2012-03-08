//
//  MeshGenerator.m
//  Annotate23D
//
//  Created by William Brown on 2012/03/07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MeshGenerator.h"

@implementation MeshGenerator

- (GlkRenderViewController*) rendererForObjects:(WorkspaceUIView*)workspace {
  Mesh mesh;
  if ([[workspace drawables] count] > 0) {
    mesh = [[[workspace drawables] objectAtIndex:0] generateMesh];
  } else {
    mesh.data = nil;
    mesh.size = 0;
  }
  
  /* Center the mesh */
  float minx = INFINITY, maxx = -INFINITY,
        miny = INFINITY, maxy = -INFINITY,
        minz = INFINITY, maxz = -INFINITY,
        x, y, z;
  
  for (int i = 0; i < mesh.size; i++) {
    x = mesh.data[6*i]; y = mesh.data[6*i+1]; z = mesh.data[6*i+2];
    if (x < minx) minx = x; if (x > maxx) maxx = x;
    if (y < miny) miny = y; if (y > maxy) maxy = y;
    if (z < minz) minz = z; if (z > maxz) maxz = z;
  }
  
  float xc = minx + (maxx - minx) / 2,
        yc = miny + (maxy - miny) / 2,
        zc = minz + (maxz - minz) / 2;
  NSLog(@"Midpoint: %f %f %f", xc, yc, zc);
  for (int i = 0; i < mesh.size; i++) {
    mesh.data[6*i+0] -= xc;
    mesh.data[6*i+1] -= yc;
    mesh.data[6*i+2] -= zc;
  }
  
  return [[GlkRenderViewController alloc] initWithMesh:mesh.data ofSize:mesh.size];
}

@end
