//
//  WIPFacebook.h
//  new
//
//  Created by Daniel Goebel on 14.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Question.h"
#import "FriendsMutualFriends.h"
#import "Player.h"



@interface WIPFacebook : NSObject


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (BOOL) checkFBSession;
- (void)sendRequestToFacebook:(NSString*) query;
- (void)getFacebookFriends:(UITableView*) tableView;
- (void)getFacebookMutualFriends;


@end


