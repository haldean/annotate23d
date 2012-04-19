//
//  Mesh.m
//  Annotate23D
//
//  Created by William Brown on 2012/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Mesh.h"

#define VALUES_PER_TRI 6

@implementation Mesh

- (id) init {
  self = [super init];
  
  _data = [[NSMutableArray alloc] init];
  _size = 0;
  
  return self;
}

- (id) initWithSize:(uint)size {
  self = [super init];
  
  _data = [[NSMutableArray alloc]
           initWithCapacity:size * VALUES_PER_TRI];
  _size = size;
  
  return self;
}

- (void) put:(float)value at:(uint)index {
  while (index >= [_data count]) {
    [_data addObject:[NSNumber numberWithFloat:0]];
  }
  [_data replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:value]];
}

- (NSMutableArray*) pointData {
  return _data;
}

@end
