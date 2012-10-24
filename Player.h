//
//  Player.h
//  new
//
//  Created by Daniel Goebel on 24.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSString * fb_url;

@end
