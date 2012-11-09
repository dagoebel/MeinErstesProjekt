//
//  Location.h
//  new
//
//  Created by Daniel Goebel on 09.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latti;
@property (nonatomic, retain) NSNumber * longi;
@property (nonatomic, retain) NSString * name;

@end
