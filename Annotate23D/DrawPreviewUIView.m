//
//  DrawPreviewUIView.m
//  Annotate23D
//

#import "DrawPreviewUIView.h"

@implementation DrawPreviewUIView
@synthesize canHandleClicks, delegate;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    points = [[NSMutableArray alloc] init];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    points = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!canHandleClicks) return;
  
  [points removeAllObjects];
  lastPoint = [[touches anyObject] locationInView:self];
  [points addObject:[NSValue valueWithCGPoint:lastPoint]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!canHandleClicks) return;
  
  CGPoint currentPoint = [[touches anyObject] locationInView:self];
  [points addObject:[NSValue valueWithCGPoint:currentPoint]];
  [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!canHandleClicks) return;
  
  if (delegate != NULL) {
    [delegate onPathDraw:points];
  }
  [points removeAllObjects];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  if ([points count] < 2) return;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 10);
  CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
  for (int i = 0; i < [points count]; i++) {
    CGPoint point = [[points objectAtIndex:i] CGPointValue];
    if (i == 0) {
      CGContextMoveToPoint(context, point.x, point.y);
    } else {
      CGContextAddLineToPoint(context, point.x, point.y);
    }
  }
  CGContextStrokePath(context);
}

@end
