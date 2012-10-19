//
//  Question.h
//  new
//
//  Created by Daniel Goebel on 19.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * created_time;
@property (nonatomic, retain) NSString * from_id;
@property (nonatomic, retain) NSString * from_name;
@property (nonatomic, retain) NSString * place_id;
@property (nonatomic, retain) NSString * place_location_city;
@property (nonatomic, retain) NSNumber * place_location_latitude;
@property (nonatomic, retain) NSNumber * place_location_longitude;
@property (nonatomic, retain) NSString * place_location_street;
@property (nonatomic, retain) NSString * place_location_zip;
@property (nonatomic, retain) NSString * place_name;
@property (nonatomic, retain) NSString * tags_id;
@property (nonatomic, retain) NSString * tags_name;
@property (nonatomic, retain) NSString * person_name;
@property (nonatomic, retain) NSString * person_id;

@end
