//
//  PlayerMutualFriends.h
//  new
//
//  Created by Daniel Goebel on 02.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends;

@interface PlayerMutualFriends : NSManagedObject

@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSString * fb_url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Friends *friends;

@end
