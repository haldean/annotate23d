//
//  Annotate23dUnitTests.m
//  Annotate23dUnitTests
//
//  Created by William Brown on 2012/02/29.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Annotate23dUnitTests.h"
#import "Ellipsoid.h"

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
  NSLog(@"Start test");
  NSMutableArray* points = [[NSMutableArray alloc] init];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(1, 0)]];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, -0.5)]];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(-1, 0)]];
  [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0.5)]];
  [Ellipsoid withPoints:points];
}

@end
