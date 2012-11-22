//
//  ANImageWheel.m
//  SpinWheel
//
//  Created by Alex Nichol on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANImageWheel.h"

@implementation ANImageWheel

- (void)setImage:(UIImage *)anImage {
    [imageView setImage:anImage];
}

- (UIImage *)image {
    return [imageView image];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:imageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)anImage {
    if ((self = [self initWithFrame:frame])) {
        [imageView setImage:anImage];
    }
    return self;
}

- (void)setAngle:(double)anAngle {
    [super setAngle:anAngle];
    [[imageView layer] setTransform:CATransform3DMakeRotation(angle, 0, 0, 1)];
    
}

- (double)getAngle {
    
    CALayer* layer = [imageView.layer presentationLayer];
    
    double rotationAngle = [[layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    /*
    rotationAngle = rotationAngle+(2*M_PI/360*globalHeading);
    
    if (rotationAngle>(2*M_PI)) {
        rotationAngle = rotationAngle - 2*M_PI;
    }

    */
    
    NSLog(@"FLASCHE ANGLE %f", rotationAngle);

    return rotationAngle;
    
}

- (void)resetAngle: (double) globalHeading {

 
    
    
    CABasicAnimation *animRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animRotate setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    //NSLog(@"globalHeading %f",globalHeading);
    
    if(globalHeading>180)
    {
        
        [animRotate setToValue:[NSNumber numberWithFloat:(M_PI/180*(360-globalHeading))]];

    }
    else{
        
        [animRotate setToValue:[NSNumber numberWithFloat:(M_PI/180*globalHeading)]];
    }
       
    [animRotate setAutoreverses:NO];
    [animRotate setDuration:2];
    animRotate.repeatCount = NO;
    animRotate.fillMode = kCAFillModeForwards;
    animRotate.cumulative=true;
    animRotate.removedOnCompletion = FALSE;
    [imageView.layer addAnimation:animRotate forKey:@"rotate"];
    [imageView.layer removeAllAnimations];


    

   
}


- (void) changeColor:(UIColor *)bottleColor {
    
    imageView.image= [self imageWithColor:imageView withAColor:bottleColor];
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
