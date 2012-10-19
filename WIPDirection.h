//
//  WIPDirection.h
//  new
//
//  Created by Daniel Goebel on 30.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h> 
#import "Question.h"

@interface WIPDirection : NSObject{
    Question *mLocation;
}

@property double LocationLong;
@property double LocationLatt;
@property (nonatomic,retain) NSString *LocationName;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (double) performDirectionCalculation: (Question*) location withMyPosition:(CLLocationCoordinate2D) myPosition;

@end


