//
//  WIPBottle.h
//  new
//
//  Created by Daniel Goebel on 26.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WIPViewControllerDelegate;

@interface WIPBottle : UIControl{
    double angle;
    double angularVelocity;
    double drag;
    
    NSDate * lastTimerDate;
    CADisplayLink * displayTimer;
    
    CGPoint initialPoint;
    double initialAngle;
    CGPoint previousPoints[2];
    NSDate * previousDates[2];
}

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIImageView *bottleAsImage;
@property int numberOfSections;

@property CGAffineTransform startTransform;



- (id) initWithFrame:(CGRect)frame andDelegate:(id)del;


- (void) changeColor: (UIColor*) bottleColor;















@end


