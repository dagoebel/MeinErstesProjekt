//
//  Question.h
//  new
//
//  Created by Daniel Goebel on 24.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tags;

@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * created_time;
@property (nonatomic, retain) NSString * from_id;
@property (nonatomic, retain) NSString * from_name;
@property (nonatomic, retain) NSString * person_id;
@property (nonatomic, retain) NSString * person_name;
@property (nonatomic, retain) NSString * place_id;
@property (nonatomic, retain) NSString * place_location_city;
@property (nonatomic, retain) NSNumber * place_location_latitude;
@property (nonatomic, retain) NSNumber * place_location_longitude;
@property (nonatomic, retain) NSString * place_location_street;
@property (nonatomic, retain) NSString * place_location_zip;
@property (nonatomic, retain) NSString * place_name;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Question (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tags *)value;
- (void)removeTagsObject:(Tags *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
