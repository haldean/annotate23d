//
//  Annotate23dUnitTests.m
//  Annotate23dUnitTests
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Annotate23dUnitTests.h"
#import "Ellipsoid.h"
#import "Mesh.h"
#import "MathDefs.h"

@implementation Annotate23dUnitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEllipseFit {
  NSMutableArray* points = [[NSMutableArray alloc] init];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(1, 0)]];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, -0.5)]];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(-1, 0)]];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0.5)]];
  [Ellipsoid withPoints:points];
}

- (void)testIntersection {
  Mesh* testMesh = [[Mesh alloc] initWithSize:6];
  
  /* Initialize to zero */
  for (int i = 0; i < 6*6; i++) [testMesh put:0 at:i];
  
  /* Set vertex positions (normals not needed) */
  [testMesh put:0 at:0]; [testMesh put:1 at:1]; [testMesh put:2 at:2];
  [testMesh put:1 at:6]; [testMesh put:-1 at:7]; [testMesh put:2 at:8];
  [testMesh put:1 at:12]; [testMesh put:1 at:13]; [testMesh put:-2 at:14];

  [testMesh put:0 at:18]; [testMesh put:1 at:19]; [testMesh put:2 at:20];
  [testMesh put:1 at:24]; [testMesh put:-1 at:25]; [testMesh put:2 at:26];
  [testMesh put:-1 at:30]; [testMesh put:-1 at:31]; [testMesh put:-2 at:32];
  
  Intersection isect = intersect(Vec3(0, 0, -9001), Vec3(0, 0, 1), testMesh);
  if (isect.intersects) {
    NSLog(@"Intersection: %@", VecToStr(isect.intersection));
  } else {
    NSLog(@"No intersection.");
  }
}

@end
