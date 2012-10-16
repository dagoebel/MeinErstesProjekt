//
//  WIPLocationController.h
//  new
//
//  Created by Daniel Goebel on 30.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol WIPLocationControllerDelegate

@required
- (void)locationUpdate:(CLLocation *)location; // Our location updates are sent here
- (void)headingUpdate:(CLHeading *)heading; // Any errors are sent here
- (void)locationError:(NSError *)error; // Any errors are sent here
@end

@interface WIPLocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locMgr;
	__unsafe_unretained id delegate;
}

@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, assign) id delegate;

@end
