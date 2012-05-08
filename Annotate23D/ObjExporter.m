//
//  ObjExporter.m
//  Annotate23D
//
//  Created by William Brown on 2012/05/08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjExporter.h"
#define PT(x) [[meshData objectAtIndex:x] floatValue]

@implementation ObjExporter

- (NSString*) vertToString:(float)x y:(float)y z:(float)z {
  return [NSString stringWithFormat:@"v %f %f %f", x, y, z];
}

- (NSString*) normToString:(float)x y:(float)y z:(float)z {
  return [NSString stringWithFormat:@"vn %f %f %f", x, y, z];
}

- (NSString*) export:(Mesh*)mesh asFile:(NSString*)name {
  int nextVertId = 1;
  int nextNormId = 1;
  NSMutableDictionary *vertToId = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *normToId = [[NSMutableDictionary alloc] init];
  NSMutableArray *verts = [[NSMutableArray alloc] init];
  NSMutableArray *norms = [[NSMutableArray alloc] init];
  NSMutableArray *faces = [[NSMutableArray alloc] init];
  
  NSMutableArray *meshData = [mesh pointData];
  NSLog(@"meshData %d", [meshData count]);
  for (int i = 0; i < [meshData count]; i += 18) {
    NSString *vid1, *vid2, *vid3, *nid1, *nid2, *nid3;
    
    NSString *v1 = [self vertToString:PT(i) y:PT(i+1) z:PT(i+2)];
    //NSLog(@"%@", v1);
    NSString *n1 = [self normToString:PT(i+3) y:PT(i+4) z:PT(i+5)];
    if ([vertToId objectForKey:v1]) {
      vid1 = [vertToId objectForKey:v1];
    } else {
      vid1 = [NSString stringWithFormat:@"%d", nextVertId];
      //NSLog(@"vid %@", vid1);
      [vertToId setValue:v1 forKey:vid1];
      [verts addObject:v1];
      nextVertId++;
    }
    if ([normToId objectForKey:n1]) {
      nid1 = [normToId objectForKey:n1];
    } else {
      nid1 = [NSString stringWithFormat:@"%d", nextNormId];
      [normToId setValue:n1 forKey:nid1];
      [norms addObject:n1];
      nextNormId++;
    }
    
    NSString *v2 = [self vertToString:PT(i+6) y:PT(i+7) z:PT(i+8)];
    NSString *n2 = [self normToString:PT(i+9) y:PT(i+10) z:PT(i+11)];
    if ([vertToId objectForKey:v2]) {
      vid2 = [vertToId objectForKey:v2];
    } else {
      vid2 = [NSString stringWithFormat:@"%d", nextVertId];
      [vertToId setValue:v2 forKey:vid2];
      [verts addObject:v2];
      nextVertId++;
    }
    if ([normToId objectForKey:n2]) {
      nid2 = [normToId objectForKey:n2];
    } else {
      nid2 = [NSString stringWithFormat:@"%d", nextNormId];
      [normToId setValue:n2 forKey:nid2];
      [norms addObject:n2];
      nextNormId++;
    }
    
    NSString *v3 = [self vertToString:PT(i+12) y:PT(i+13) z:PT(i+14)];
    NSString *n3 = [self normToString:PT(i+15) y:PT(i+16) z:PT(i+17)];
    if ([vertToId objectForKey:v3]) {
      vid3 = [vertToId objectForKey:v3];
    } else {
      vid3 = [NSString stringWithFormat:@"%d", nextVertId];
      [vertToId setValue:v3 forKey:vid3];
      [verts addObject:v3];
      nextVertId++;
    }
    if ([normToId objectForKey:n3]) {
      nid3 = [normToId objectForKey:n3];
    } else {
      nid3 = [NSString stringWithFormat:@"%d", nextNormId];
      [normToId setValue:n3 forKey:nid3];
      [norms addObject:n3];
      nextNormId++;
    }
    
    /*NSString *face = [NSString stringWithFormat:@"f %@//%@ %@//%@ %@//%@",
                      vid1, nid1, vid2, nid2, vid3, nid3]; */
    NSString *face = [NSString stringWithFormat:@"f %@ %@ %@",
                      vid1, vid2, vid3];
    [faces addObject:face];
  }
  
  NSString *output = [NSString stringWithFormat:@"%@\n%@\n%@",
                      [verts componentsJoinedByString:@"\n"],
                      [norms componentsJoinedByString:@"\n"],
                      [faces componentsJoinedByString:@"\n"]];
//  NSLog(@"%@", output);
  
  NSArray *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [[dir objectAtIndex:0] stringByAppendingPathComponent:name];
  [output writeToFile:path atomically:false encoding:NSUTF8StringEncoding error:nil];
  return path;
}

@end
