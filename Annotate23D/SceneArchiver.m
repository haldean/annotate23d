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
    
    if ([cyl mirrorAnnotation] != nil && [[cyl mirrorAnnotation] alignTo] != cyl) {
      [encoding setValue:[NSNumber numberWithInt:[[[cyl mirrorAnnotation] alignTo] ident]] forKey:@"mirror"];
      [encoding setValue:[NSNumber numberWithFloat:[[cyl mirrorAnnotation] symmetryTilt]] forKey:@"mirror_phi"];
    }
  
    if ([cyl alignmentConstraint] != nil && [[cyl alignmentConstraint] alignTo] != cyl) {
      [encoding setValue:[NSNumber numberWithInt:[[[cyl alignmentConstraint] alignTo] ident]] forKey:@"align"];
      [encoding setValue:[NSNumber numberWithFloat:[[cyl alignmentConstraint] symmetryTilt]] forKey:@"align_phi"];
    }
    
    if ([cyl connectionConstraint] != nil && [[cyl connectionConstraint] first] != cyl) {
      [encoding setValue:[NSNumber numberWithInt:[[[cyl connectionConstraint] first] ident]] forKey:@"connection"];
      CGPoint connectionPoint = [[cyl connectionConstraint] location];
      [encoding setValue:[NSNumber numberWithFloat:connectionPoint.x] forKey:@"connection_x"];
      [encoding setValue:[NSNumber numberWithFloat:connectionPoint.y] forKey:@"connection_y"];
    }
    
    if ([cyl lengthConstraint] != nil && [[cyl lengthConstraint] first] != cyl) {
      [encoding setValue:[NSNumber numberWithInt:[[[cyl lengthConstraint] first] ident]] forKey:@"length"];
    }
    
  } else {
    Ellipsoid* ell = (Ellipsoid*) drawable;
    [encoding setValue:@"ellipsoid" forKey:@"type"];
    
    [encoding setValue:[NSNumber numberWithFloat:[ell com].x] forKey:@"comx"];
    [encoding setValue:[NSNumber numberWithFloat:[ell com].y] forKey:@"comy"];
    [encoding setValue:[NSNumber numberWithFloat:[ell a]] forKey:@"a"];
    [encoding setValue:[NSNumber numberWithFloat:[ell b]] forKey:@"b"];
    [encoding setValue:[NSNumber numberWithFloat:[ell phi]] forKey:@"phi"];
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
    ell.phi = [[dict objectForKey:@"phi"] floatValue];
    
    [ell calculatePath];
    return ell;
  }
}

+ (void) createAnnotations:(Cylinderoid*)cyl forDict:(NSDictionary*)dict withDrawables:(NSDictionary*)drawables {
  NSNumber *mirrorIdent = [dict objectForKey:@"mirror"];
  if (mirrorIdent) {
    MirrorAnnotation *ma = [[MirrorAnnotation alloc] init];
    [ma setSymmetryTilt:[[dict objectForKey:@"mirror_phi"] floatValue]];
    [ma setAlignTo:[drawables objectForKey:mirrorIdent]];
    [ma setMirror:cyl];
    [cyl setMirrorAnnotation:ma];
    [[drawables objectForKey:mirrorIdent] setMirrorAnnotation:ma];
  }
  
  NSNumber *alignIdent = [dict objectForKey:@"mirror"];
  if (alignIdent) {
    AlignToSheetAnnotation *aa = [[AlignToSheetAnnotation alloc] init];
    [aa setSymmetryTilt:[[dict objectForKey:@"align_phi"] floatValue]];
    [aa setAlignTo:[drawables objectForKey:alignIdent]];
    [aa setObject:cyl];
    [cyl setAlignmentConstraint:aa];
    [[drawables objectForKey:alignIdent] setAlignmentConstraint:aa];
  }
  
  NSNumber *connectIdent = [dict objectForKey:@"connection"];
  if (connectIdent) {
    ConnectionAnnotation *ca = [[ConnectionAnnotation alloc] init];
    [ca setLocation:CGPointMake([[dict objectForKey:@"connection_x"] floatValue], [[dict objectForKey:@"connection_y"] floatValue])];
    [ca setFirst:[drawables objectForKey:connectIdent]];
    [ca setSecond:cyl];
    [cyl setConnectionConstraint:ca];
    [[drawables objectForKey:connectIdent] setConnectionConstraint:ca];
  }
  
  NSNumber *lengthIdent = [dict objectForKey:@"length"];
  if (lengthIdent) {
    SameLengthAnnotation *sla = [[SameLengthAnnotation alloc] init];
    [sla setFirst:[drawables objectForKey:lengthIdent]];
    [sla setSecond:cyl];
    [cyl setLengthConstraint:sla];
    [[drawables objectForKey:lengthIdent] setLengthConstraint:sla];
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
  NSMutableDictionary *identToDrawdata = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *identToDrawable = [[NSMutableDictionary alloc] init];
  for (NSDictionary* drawdata in plist) {
    Drawable *draw = [SceneArchiver decodeDrawable:drawdata];
    [drawables addObject:draw];
    if ([[drawdata objectForKey:@"type"] isEqualToString:@"cylinderoid"]) {
      [identToDrawdata setValue:drawdata forKey:[NSString stringWithFormat:@"%d", draw.ident]];
      [identToDrawable setValue:draw forKey:[NSString stringWithFormat:@"%d", draw.ident]];
    }
    NSLog(@"load %@ = %@", [drawdata objectForKey:@"type"], [drawables objectAtIndex:[drawables count] - 1]);
  }
  
  for (Drawable* dr in drawables) {
    NSString *ident = [NSString stringWithFormat:@"%d", dr.ident];
    if ([identToDrawdata objectForKey:ident]) {
      [SceneArchiver createAnnotations:(Cylinderoid*)dr forDict:[identToDrawdata objectForKey:ident] withDrawables:identToDrawable];
    }
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
