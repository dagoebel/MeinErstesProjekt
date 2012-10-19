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

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

- (double) performDirectionCalculation: (Question*) pLocation withMyPosition:(CLLocationCoordinate2D)pMyPosition{
    
    NSLog(@"PERFORM DIRECTION CALCULATION FOR: %@ %@ %@", pLocation.place_name, pLocation.place_location_latitude, pLocation.place_location_latitude);
    NSLog(@"IN REGARDS TO MY POSITION: %f %f",  pMyPosition.latitude,  pMyPosition.longitude);
   
    float fLat = degreesToRadians(pMyPosition.latitude);
    float fLng = degreesToRadians(pMyPosition.longitude);
    float tLat = degreesToRadians([pLocation.place_location_latitude doubleValue]);
    float tLng = degreesToRadians([pLocation.place_location_longitude doubleValue]);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
    
}


@end



