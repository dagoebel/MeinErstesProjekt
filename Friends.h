//
//  Friends.h
//  new
//
//  Created by Daniel Goebel on 21.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * friend_id;
@property (nonatomic, retain) NSString * picture;

@end
