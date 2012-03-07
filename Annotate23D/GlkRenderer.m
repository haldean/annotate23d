//
//  GlkRenderer.m
//  Annotate23D
//
//  Created by William Brown on 2012/02/09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GlkRenderer.h"
#import "monkey.h"

@implementation GlkRenderer
@synthesize effect;

- (id)init {
  self = [super init];
  
  self.effect = [[GLKBaseEffect alloc] init];
  
  return self;
}

- (void)setupViewMatrix:(GLKView *)view {
  float aspect = view.bounds.size.width / view.bounds.size.height;
  GLKMatrix4 projectionMatrix = 
      GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
  self.effect.transform.projectionMatrix = projectionMatrix;
  
  GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -3.5f);
  self.effect.transform.modelviewMatrix = modelViewMatrix;
  
  /*
  float aspect = view.bounds.size.width / view.bounds.size.height; 
  effect.transform.projectionMatrix =
      GLKMatrix4MakePerspective(1.22, aspect, 0.1, 1000);
  effect.transform.modelviewMatrix =
      GLKMatrix4MakeLookAt(10, 0, 0, 0, 0, 0, 0, 1, 0);
   [effect prepareToDraw]; */
}

- (void)initGeometry {
  self.effect = [[GLKBaseEffect alloc] init];
  self.effect.lightingType = GLKLightingTypePerPixel;
  
  // Turn on the first light
  self.effect.light0.enabled = GL_TRUE;
  self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
  self.effect.light0.position = GLKVector4Make(-5.f, -5.f, 10.f, 1.0f);
  self.effect.light0.specularColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
  
  // Turn on the second light
  self.effect.light1.enabled = GL_TRUE;
  self.effect.light1.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
  self.effect.light1.position = GLKVector4Make(15.f, 15.f, 10.f, 1.0f);
  self.effect.light1.specularColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
  
  // Set material
  self.effect.material.diffuseColor = GLKVector4Make(0.f, 0.5f, 1.0f, 1.0f);
  self.effect.material.ambientColor = GLKVector4Make(0.0f, 0.5f, 0.0f, 1.0f);
  self.effect.material.specularColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
  self.effect.material.shininess = 20.0f;
  self.effect.material.emissiveColor = GLKVector4Make(0.2f, 0.f, 0.2f, 1.0f);
  
  glEnable(GL_DEPTH_TEST);
  
  glGenVertexArraysOES(1, &vertexArray);
  glBindVertexArrayOES(vertexArray);
  
  glGenBuffers(1, &vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(MeshVertexData), MeshVertexData, GL_STATIC_DRAW);
  
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), 0);
  glEnableVertexAttribArray(GLKVertexAttribNormal);
  glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,  6 * sizeof(GLfloat), (char *)12);
  
  
  glBindVertexArrayOES(0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  [self setupViewMatrix:view];
  
  glClearColor(.50, .50, .50, 0.0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  glBindVertexArrayOES(vertexBuffer);
  
  // Render the object with GLKit
  [self.effect prepareToDraw];
  
  glDrawArrays(GL_TRIANGLES, 0, sizeof(MeshVertexData) / sizeof(vertexData));
  /*
  effect.useConstantColor = true;
  effect.constantColor = GLKVector4Make(1., 0., 0., 0.5);
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, triangleVertices);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);*/
}

@end
