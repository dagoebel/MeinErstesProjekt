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
- (NSArray*) calculateWinner:(double)angle;
- (void) deletePlayer;
- (void)insertPlayer:(NSString *)playerName withId:(NSNumber *) playerId: (NSString *)fb_id: (NSString *)fb_url;

- (void) saveAngle:(int)playerID:(double)angle;
- (void) savePoints:(int)playerID:(double)points;

@end
