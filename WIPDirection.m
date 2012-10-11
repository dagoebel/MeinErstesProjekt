//
//  WIPDirection.m
//  new
//
//  Created by Daniel Goebel on 30.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPDirection.h"

@implementation WIPDirection

@synthesize LocationLong = mLocationLong;
@synthesize LocationLatt = mLocationLatt;
@synthesize LocationName = mLocationName;


- (NSString*) performDirectionCalculation: (NSString*) pLocationName withLocationLong: (double) pLocationLong withLocationLatt: (double) pLocationLatt{
    
    

   // CLLocationCoordinate2D here =  location.coordinate;
    
    //float userAngle = [self calculateUserAngle:here];
    
    NSLog(@"pLocationName: %@ pLocationName: %g pLocationName: %g", pLocationName, pLocationLong, pLocationLatt);
    
    return @"0";
    
}


-(float) calculateUserAngle:(double) lat1 withLong1: (double) long1 withLat2: (double) lat2 withLong2: (double) long2 {


    float dy = lat2 - lat1;
    
    NSLog(@"RICHTUNG INTERN %f",dy);
    float dx = cosf(M_PI/180*lat1)*(long2 - long1);
    
     NSLog(@"RICHTUNG INTERN %f",dx);
    float angle = atan2f(dy, dx);
    
    
    NSLog(@"RICHTUNG INTERN %f",angle);
    
    NSLog(@"RICHTUNG INTERN %f",(angle*180/M_PI));
    
    return angle;
}

@end



