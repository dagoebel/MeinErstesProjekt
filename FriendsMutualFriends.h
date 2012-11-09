//
//  FriendsMutualFriends.h
//  new
//
//  Created by Daniel Goebel on 09.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friends;

@interface FriendsMutualFriends : NSManagedObject

@property (nonatomic, retain) NSString * fb_id;
@property (nonatomic, retain) NSString * fb_url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id pictureBase64;
@property (nonatomic, retain) Friends *friends;

@end
