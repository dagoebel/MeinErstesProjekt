//
//  WIPGameController.m
//  new
//
//  Created by Daniel Goebel on 11.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPGameController.h"
#import "Player.h"
#import "CoreDataHelper.h"
#import "WIPAppDelegate.h"

@implementation WIPGameController

static double playerCount;



- (void) newGame: (double) anzahlSpieler{
    
    playerCount = anzahlSpieler;
    
}
- (void) nextPlayer{
    
    
    
}
- (void) calculateWinner{
    
}

- (void) deletePlayer
{
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    double playerCount = [CoreDataHelper countForEntity:@"Player" andContext:mainDelegate.managedObjectContext];
    
    if(playerCount>0)
    {
      [CoreDataHelper deleteAllObjectsForEntity:@"Player" andContext:mainDelegate.managedObjectContext];
        NSLog(@"Bestehende Spieler gelöscht!");
    }
    
    //
    
}


- (void)insertPlayer:(NSString *)playerName withId:(NSNumber *) playerId: (NSInteger)fb_id: (NSString *)fb_url
{
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    Player *player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:mainDelegate.managedObjectContext];
    
    player.name = playerName;
    player.id = playerId;
    player.fb_id = [NSString stringWithFormat:@"%d", fb_id];
    player.fb_url = fb_url;
    
    
    [mainDelegate.managedObjectContext save:nil];
    
}

@end
