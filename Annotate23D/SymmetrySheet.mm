#import "MathDefs.h"
#import "Cylinderoid.h"

symmetrysheet getSymmetrySheet(Cylinderoid* alignTo, Drawable* other, float symmetryTilt) {
  bool isCyl = [other isKindOfClass:[Cylinderoid class]];
  
  CGPoint refPoint;
  if (isCyl) {
    Cylinderoid* cyl = (Cylinderoid*) other;
    refPoint = [[cyl connectionConstraint] location];
  } else {
    refPoint = [other com];
  }
  
  /* Find closest point on mirror-about cylindroid */
  float nearest_dist = INFINITY;
  int nearest_idx = -1;
  for (int i = 0; i < [[alignTo spine] count]; i++) {
    CGPoint pt = [[[alignTo spine] objectAtIndex:i] CGPointValue];
    float dist = squareDistance(pt, refPoint);
    if (dist < nearest_dist) {
      nearest_dist = dist;
      nearest_idx = i;
    }
  }
  
  NSMutableArray* spinevecs = [alignTo spineVecsWithConstraints];
  Vec3 spinept = [[spinevecs objectAtIndex:nearest_idx] vec3];
  Vec3 tangent = Vec3ForCGVec([alignTo tangentVectorAtIndex:nearest_idx onSpine:spinevecs]);
  Vec3 perp = Vec3ForCGVec([alignTo perpVectorAtIndex:nearest_idx onSpine:spinevecs]);
  perp = AngleAxisf(symmetryTilt, tangent) * perp;
  
  Vec3 plane_normal = tangent.cross(perp);
  plane_normal.normalize();
  
  symmetrysheet result;
  result.plane_normal = plane_normal;
  result.spine_point = spinept;
  return result;
}

Vec3 elevation(symmetrysheet ss, Vec3 point) {
  return (point - ss.spine_point).dot(ss.plane_normal) * ss.plane_normal;
}