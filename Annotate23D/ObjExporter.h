//
//  ObjExporter.h
//  Annotate23D
//
//  Created by William Brown on 2012/05/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mesh.h"

@interface ObjExporter : NSObject
- (NSString*) export:(Mesh*)mesh asFile:(NSString*)name;
@end
