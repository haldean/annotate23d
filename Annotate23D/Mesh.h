//
//  Mesh.h
//  Annotate23D
//
//  Created by William Brown on 2012/03/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mesh : NSObject {
  uint _size;
  NSMutableArray* _data;
}

- (id) initWithSize:(uint)size;
- (void) put:(float)value at:(uint)index;
- (NSMutableArray*) pointData;

@end
