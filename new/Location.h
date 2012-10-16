//
//  Location.h
//  new
//
//  Created by Daniel Goebel on 05.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * longi;
@property (nonatomic, retain) NSNumber * latti;

@end
