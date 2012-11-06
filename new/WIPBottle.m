//
//  WIPBottle.m
//  new
//
//  Created by Daniel Goebel on 26.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPBottle.h"
#import <QuartzCore/QuartzCore.h>

@interface WIPBottle()
- (void)drawWheel;
@end

@implementation WIPBottle

static float deltaAngle;

UIView *container;

@synthesize numberOfSections,bottleAsImage;
@synthesize startTransform;


- (id) initWithFrame:(CGRect)frame andDelegate:(id)del {
    // 1 - Call super init
    if ((self = [super initWithFrame:frame])) {
        // 3 - Draw wheel
        [self drawWheel];
        
	}
    return self;
}

- (void) drawWheel {
    container = [[UIView alloc] initWithFrame:self.frame];
    bottleAsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottle.png"]];
    bottleAsImage.tag =999;
    bottleAsImage.contentMode = UIViewContentModeScaleAspectFit;
    bottleAsImage.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, 768, 768);
    [container addSubview:bottleAsImage];
    container.userInteractionEnabled = NO;
    [self addSubview:container];
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // 1 - Get touch position
    CGPoint touchPoint = [touch locationInView:self];
    // 1.1 - Get the distance from the center
    //float dist = [self calculateDistanceFromCenter:touchPoint];
    // 1.2 - Filter out touches too close to the center
  
    // 2 - Calculate distance from center
    float dx = touchPoint.x - container.center.x;
    float dy = touchPoint.y - container.center.y;
    // 3 - Calculate arctangent value
    deltaAngle = atan2(dy,dx);
    // 4 - Save current transform
    startTransform = container.transform;
    return YES;
    
    
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    CGPoint pt = [touch locationInView:self];
    float dx = pt.x  - container.center.x;
    float dy = pt.y  - container.center.y;
    float ang = atan2(dy,dx);
    float angleDifference = deltaAngle - ang;
    container.transform = CGAffineTransformRotate(startTransform, -angleDifference);
    
   
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    
 
}






- (float) calculateDistanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}


- (void) changeColor:(UIColor *)bottleColor {
    
    UIImageView *getImageView1 = (UIImageView*)[container viewWithTag:999];
    
    getImageView1.image = [self imageWithColor:getImageView1 withAColor:bottleColor];
    //getImageView1.alpha = 0;
    
}


- (UIImage *)imageWithColor:(UIImageView*) view withAColor: (UIColor *)color
{
    // load the image
   // NSString *name = view.image;
    UIImage *img = view.image;
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}


@end
