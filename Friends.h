//
//  Friends.h
//  new
//
//  Created by Daniel Goebel on 03.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FriendsMutualFriends;

@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * friend_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSSet *friendsmutualfriends;
@end

@interface Friends (CoreDataGeneratedAccessors)

- (void)addFriendsmutualfriendsObject:(FriendsMutualFriends *)value;
- (void)removeFriendsmutualfriendsObject:(FriendsMutualFriends *)value;
- (void)addFriendsmutualfriends:(NSSet *)values;
- (void)removeFriendsmutualfriends:(NSSet *)values;

@end
