//
//  WIPGameController.h
//  new
//
//  Created by Daniel Goebel on 11.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"



@interface WIPGameController : NSObject{
    
    NSMutableArray *secondArr;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



- (void) newGame: (double) playerCount;
- (void) nextPlayer;
- (void) calculateWinner;
- (void) deletePlayer;
- (void)insertPlayer:(NSString *)playerName withId:(NSNumber *) playerId: (NSInteger)fb_id: (NSString *)fb_url;

@end
