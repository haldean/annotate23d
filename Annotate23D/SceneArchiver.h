//
//  SceneArchiver.h
//  Annotate23D
//
//  Created by William Brown on 2012/05/02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneArchiver : NSObject

+ (void) saveDrawables:(NSMutableArray*)drawables withName:(NSString*)name;
+ (NSMutableArray*) loadDrawablesWithName:(NSString*)name;
+ (NSArray*) savedScenes;
+ (void) deleteScene:(NSString*)name;
@end
