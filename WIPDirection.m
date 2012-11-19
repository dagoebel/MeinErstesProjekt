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
    
    NSLog(@"====================== BERECHNE RICHTUNG FÜR FRAGE %@ %@ %@", pLocation.place_name, pLocation.place_location_latitude, pLocation.place_location_latitude);
    NSLog(@"====================== FÜR MEINE POSITION: %f %f",  pMyPosition.latitude,  pMyPosition.longitude);
   
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

- (double) performDistanceCalculation: (Question*) pLocation withMyPosition:(CLLocationCoordinate2D)pMyPosition{
    
    NSLog(@"====================== BERECHNE ENTFERNUNG FÜR FRAGE %@ %@ %@", pLocation.place_name, pLocation.place_location_latitude, pLocation.place_location_latitude);
    NSLog(@"====================== FÜR MEINE POSITION: %f %f",  pMyPosition.latitude,  pMyPosition.longitude);
    
    double nRadius = 6371; // Earth's radius in Kilometers
    // Get the difference between our two points
    // then convert the difference into radians
    
    
    float fLat = degreesToRadians(pMyPosition.latitude);
    float fLng = degreesToRadians(pMyPosition.longitude);
    float tLat = degreesToRadians([pLocation.place_location_latitude doubleValue]);
    float tLng = degreesToRadians([pLocation.place_location_longitude doubleValue]);
    
    
    double nDLat = fLat - tLat;
    double nDLon = fLng- tLng;
    
    
    double nA = pow ( sin(nDLat/2), 2 ) + cos(fLng) * cos(tLat) * pow ( sin(nDLon/2), 2 );
    
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    
    return nD; // Return our calculated distance
    
    
}


@end



