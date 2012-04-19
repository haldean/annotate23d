#import <Foundation/Foundation.h>
#import "MathDefs.h"
#include <iostream>

#define PT(x) [[meshData objectAtIndex:x] floatValue]

Intersection intersect(Vec3 origin, Vec3 direction, Mesh* mesh) {
  NSMutableArray* meshData = [mesh pointData];
  
  float min_s = -1;  
  Intersection isect;
  isect.intersects = false;
  
  /* Each triangle has three verts, each of which has a location and a normal,
   * each of which has three components. Therefore, each triangle has 3 * 2 * 3
   * = 18 components. */
  for (int i = 0; i < [meshData count]; i += 18) {
    /* The following three statements are due to the representation
     * of triangles in the mesh object which is required by the lovely,
     * beautiful and wonderful OpenGL ES. */
    Vec3 p1(PT(i), PT(i+1), PT(i+2));
    Vec3 p2(PT(i+6), PT(i+7), PT(i+8));
    Vec3 p3(PT(i+12), PT(i+13), PT(i+14));
    
    //std::cout << p1.transpose() << ", " << p2.transpose() << ", " << p3.transpose() << std::endl;
    
    Vec3 e1 = p2 - p1
    , e2 = p3 - p1
    , t  = origin - p1
    , p  = direction.cross(e2)
    , q  = t.cross(e1);
    
    float det = e1.dot(p);
    if (det > -1e-7 && det < 1e-7) {
      //std::cout << "low determinant\n";
      continue;
    }
    
    float scale = 1 / det;
    float u = scale * p.dot(t);
    if (u < 0 || u > 1) {
      //std::cout << "u outside 0, 1\n";
      continue;
    }
    
    float v = scale * q.dot(direction);
    if (v < 0 || u + v > 1) {
      //std::cout << "v < 0 or u + v > 1\n";
      continue;
    }
    
    float s = scale * q.dot(e2);
    if (s < 0) {
      //std::cout << "s < 0\n";
      continue;
    }
    
    //std::cout << "s is " << s << std::endl;
    if (min_s < 0 || s < min_s) {
      isect.intersects = true;
      isect.intersection = origin + s * direction;
    }
  }
  
  //std::cout << "intersects: " << isect.intersects << " at " << isect.intersection.transpose() << std::endl;
  return isect;
}