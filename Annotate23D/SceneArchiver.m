//
//  SceneArchiver.m
//  Annotate23D
//
//  Created by William Brown on 2012/05/02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SceneArchiver.h"
#import "Drawable.h"
#import "Cylinderoid.h"
#import "Ellipsoid.h"

@implementation SceneArchiver

+ (NSDictionary*) encodeDrawable:(Drawable*) drawable {
  NSMutableDictionary* encoding = [[NSMutableDictionary alloc] init];
  if ([[drawable class] isSubclassOfClass:[Cylinderoid class]]) {
    Cylinderoid* cyl = (Cylinderoid*) drawable;
    [encoding setValue:@"cylinderoid" forKey:@"type"];
    
    NSMutableArray* spinex = [[NSMutableArray alloc] initWithCapacity:[[cyl spine] count]];
    NSMutableArray* spiney = [[NSMutableArray alloc] initWithCapacity:[[cyl spine] count]];
    for (int i = 0; i < [[cyl spine] count]; i++) {
      CGPoint pt = [[[cyl spine] objectAtIndex:i] CGPointValue];
      [spinex addObject:[NSNumber numberWithFloat:pt.x]];
      [spiney addObject:[NSNumber numberWithFloat:pt.y]];
    }
    [encoding setValue:spinex forKey:@"spinex"];
    [encoding setValue:spiney forKey:@"spiney"];
    [encoding setValue:[cyl radii] forKey:@"radii"];
    [encoding setValue:[cyl tilt] forKey:@"tilt"];
    [encoding setValue:[NSNumber numberWithFloat:[cyl capRadius1]] forKey:@"cap1"];
    [encoding setValue:[NSNumber numberWithFloat:[cyl capRadius2]] forKey:@"cap2"];
  } else {
    Ellipsoid* ell = (Ellipsoid*) drawable;
    [encoding setValue:@"ellipsoid" forKey:@"type"];
    
    [encoding setValue:[NSNumber numberWithFloat:[ell com].x] forKey:@"comx"];
    [encoding setValue:[NSNumber numberWithFloat:[ell com].y] forKey:@"comy"];
    [encoding setValue:[NSNumber numberWithFloat:[ell a]] forKey:@"a"];
    [encoding setValue:[NSNumber numberWithFloat:[ell b]] forKey:@"b"];
  }
  
  return encoding;
}

+ (Drawable*) decodeDrawable:(NSDictionary*) dict{
  if ([[dict objectForKey:@"type"] isEqualToString:@"cylinderoid"]) {
    Cylinderoid *cyl = [[Cylinderoid alloc] init];
    NSMutableArray *spinex = [dict objectForKey:@"spinex"];
    NSMutableArray *spiney = [dict objectForKey:@"spiney"];
    NSMutableArray *spine = [[NSMutableArray alloc] initWithCapacity:[spinex count]];
    for (int i = 0; i < [spinex count]; i++) {
      /* This line is why ObjC is awful. This is spine.append(spinex[i], spiney[i])*/
      [spine addObject:[NSValue valueWithCGPoint:CGPointMake([[spinex objectAtIndex:i] floatValue], [[spiney objectAtIndex:i] floatValue])]];
    }
    
    cyl.spine = spine;
    cyl.radii = [dict objectForKey:@"radii"];
    cyl.tilt = [dict objectForKey:@"tilt"];
    cyl.capRadius1 = [[dict objectForKey:@"cap1"] floatValue];
    cyl.capRadius2 = [[dict objectForKey:@"cap2"] floatValue];
    
    [cyl setLengthConstraint:nil];
    [cyl setRadiusConstraints:[[NSMutableArray alloc] initWithCapacity:1]];
    [cyl setTiltConstraints:[[NSMutableArray alloc] initWithCapacity:1]];
    
    [cyl calculateSurfacePoints];
    return cyl;
  } else {
    Ellipsoid *ell = [[Ellipsoid alloc] init];
    ell.com = CGPointMake([[dict objectForKey:@"comx"] floatValue], [[dict objectForKey:@"comy"] floatValue]);
    ell.a = [[dict objectForKey:@"a"] floatValue];
    ell.b = [[dict objectForKey:@"b"] floatValue];
    return ell;
  }
}

+ (void) saveDrawables:(NSMutableArray *)drawables withName:(NSString *)name {
  NSMutableArray* encodings = [[NSMutableArray alloc] init];
  for (Drawable* drawable in drawables) {
    [encodings addObject:[self encodeDrawable:drawable]];
  }
  
  NSArray *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [[dir objectAtIndex:0] stringByAppendingPathComponent:name];
  NSData *xmlData;
  NSString *error;
  
  xmlData = [NSPropertyListSerialization 
             dataFromPropertyList:encodings
             format:NSPropertyListXMLFormat_v1_0
             errorDescription:&error];
  if (xmlData) {
    NSLog(@"No error creating XML data for %@.", path);
    [xmlData writeToFile:path atomically:YES];
  }
  else {
    NSLog(@"Error in saving: %@", error);
  }
}

+ (NSArray*) savedScenes {
  NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSFileManager* manager = [NSFileManager defaultManager];
  NSArray* fileList = [manager contentsOfDirectoryAtPath:dir error:nil];
  for (NSString* f in fileList) NSLog(@"%@", f);
  return fileList;
}

+ (NSMutableArray*) loadDrawablesWithName:(NSString *)name {
  NSArray *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [[dir objectAtIndex:0] stringByAppendingPathComponent:name];
  NSData *plistData = [NSData dataWithContentsOfFile:path];
  NSString *error;
  NSPropertyListFormat format;
  id plist;
  
  plist = [NSPropertyListSerialization 
           propertyListFromData:plistData
           mutabilityOption:NSPropertyListImmutable
           format:&format
           errorDescription:&error];
  if (!plist){
    NSLog(@"Error in loading: %@", error);
    return nil;
  }
  
  NSMutableArray* drawables = [[NSMutableArray alloc] init];
  for (NSDictionary* drawdata in plist) {
    [drawables addObject:[SceneArchiver decodeDrawable:drawdata]];
    NSLog(@"load %@ = %@", [drawdata objectForKey:@"type"], [drawables objectAtIndex:[drawables count] - 1]);
  }
  return drawables;
}

+ (void) deleteScene:(NSString *)name {
  NSLog(@"deleting %@", name);
  NSFileManager *fman = [NSFileManager defaultManager];
  NSError *err;
  NSArray *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [[dir objectAtIndex:0] stringByAppendingPathComponent:name];
  if ([fman removeItemAtPath:path error:&err] != YES) {
    NSLog(@"Could not delete file: %@", [err localizedDescription]);
  }
}

@end
