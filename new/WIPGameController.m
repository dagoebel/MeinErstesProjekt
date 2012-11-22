//
//  WIPGameController.m
//  new
//
//  Created by Daniel Goebel on 11.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPGameController.h"
#import "Player.h"
#import "Friends.h"
#import "FriendsMutualFriends.h"
#import "CoreDataHelper.h"
#import "WIPAppDelegate.h"
#import "WIPFacebook.h"

@implementation WIPGameController

static double playerCount;



- (void) newGame: (double) anzahlSpieler{
    
    playerCount = anzahlSpieler;
    
}

- (NSArray*) calculateWinner:(double)locationAngle: (double)startPlayer{
    
    NSString *playerIDStr = @"id";
    NSString *distance = @"distance";
    NSString *startplayer = @"startplayer";
    NSString *name = @"name";
    NSString *playerName = nil;

    
    // A dictionary object
    NSDictionary *dict;
    
    // Create array to hold dictionaries
    NSMutableArray *arrayOfDictionaries = [NSMutableArray array];

    
    
    int winner = 1;
    double diffAngle = 0.0;
    double bestDiffAngle = 0.0;
    
    NSMutableArray *spieler = [[NSMutableArray alloc] init];
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    spieler = [CoreDataHelper getObjectsForEntity:@"Player" withSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    
    
    for(Player *player in spieler)
    {
        double playerAngle = [player.angle doubleValue];
        double globalHeading = [player.angleGlobalHeading doubleValue];
        
        if (playerAngle>=0) {
            playerAngle = 180 / M_PI * playerAngle;
        }
        else{
            playerAngle = 180 / M_PI * (M_PI+playerAngle)+180;
        }
        
        playerAngle = playerAngle + globalHeading;
        
        playerAngle = fmod(playerAngle, 360);
        
        
        NSLog(@"flascheAngle %f",playerAngle);
        NSLog(@"headingAngle %f",globalHeading);
         NSLog(@"locationAngle %f",locationAngle);

        double playerID = [player.id doubleValue];
        double playerStart = 0;
        
        if([player.id doubleValue] >= startPlayer){
            
            playerStart= [player.id doubleValue] - startPlayer;
            
        }
        else{
             playerStart= spieler.count - (startPlayer - [player.id doubleValue]);
        }
        
        playerName = player.name;
  
        
        
        
        if(locationAngle>playerAngle)
        {
            if ((locationAngle-playerAngle)>=180) {
                diffAngle  = 360 - locationAngle + playerAngle;
            }
            else{
                diffAngle = locationAngle - playerAngle;
            }
            
        }
        else
        {
            if((playerAngle - locationAngle) >= 180)
            {
                diffAngle  = 360 - playerAngle + locationAngle;
            }
            else{
                diffAngle = playerAngle - locationAngle;
            }
        }
        
        
        
        
        
        
        
        if(playerID==1)
        {
            bestDiffAngle = diffAngle;
            winner = playerID;
        }
        else{
            if(diffAngle<bestDiffAngle){
                bestDiffAngle = diffAngle;
                winner = playerID;
            }
        }
            
        
        // Create three dictionaries
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                // Key value pairs
                playerName, name,
                [NSString stringWithFormat:@"%f",playerID], playerIDStr,
                [NSNumber numberWithDouble:playerStart], startplayer,
                [NSNumber numberWithDouble:diffAngle], distance, nil];
        [arrayOfDictionaries addObject:dict];
        
 
    }
    

    NSSortDescriptor *distancesort =
    [[NSSortDescriptor alloc] initWithKey:distance
                                ascending:YES];
    
    NSSortDescriptor *startplayersort =
    [[NSSortDescriptor alloc] initWithKey:startplayer
                                ascending:YES];
    
    NSArray *descriptors = [NSArray arrayWithObjects:distancesort, startplayersort, nil];
    NSArray *sortedArrayOfDictionaries = [arrayOfDictionaries sortedArrayUsingDescriptors:descriptors];
    
    NSLog(@"sorted array of dictionaries: %@", sortedArrayOfDictionaries);
    
    return sortedArrayOfDictionaries;

  
}


- (NSArray*) getResults{
    
    NSString *playerIDStr = @"id";
    NSString *distance = @"distance";
    NSString *startplayer = @"startplayer";
    NSString *name = @"name";
    
    NSMutableArray *arrayOfDictionaries = [NSMutableArray array];
    
    NSMutableArray *spieler = [[NSMutableArray alloc] init];
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    spieler = [CoreDataHelper getObjectsForEntity:@"Player" withSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];

    for(Player *player in spieler)
    {
        double playerTotalAngle = [player.angle_total doubleValue];
       
        double playerID = [player.id doubleValue];
    
        NSString *playerName = player.name;

         // Create three dictionaries
       NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                // Key value pairs
                playerName, name,
                [NSString stringWithFormat:@"%f",playerID], playerIDStr,
                [NSNumber numberWithDouble:playerTotalAngle], distance, nil];
        [arrayOfDictionaries addObject:dict];
  
    }
    
    NSSortDescriptor *distancesort =
    [[NSSortDescriptor alloc] initWithKey:distance
                                ascending:YES];
    
    NSSortDescriptor *startplayersort =
    [[NSSortDescriptor alloc] initWithKey:startplayer
                                ascending:YES];
    
    NSArray *descriptors = [NSArray arrayWithObjects:distancesort, startplayersort, nil];
    NSArray *sortedArrayOfDictionaries = [arrayOfDictionaries sortedArrayUsingDescriptors:descriptors];

       
   return sortedArrayOfDictionaries; 
}

- (void) saveAngle:(int)playerID:(double)angle:(double) globalHeading{
    
      NSMutableArray *spieler = [[NSMutableArray alloc] init];

     WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
                   
     NSPredicate *query_aktiver_spieler = [NSPredicate predicateWithFormat:@"id == %@", [NSString stringWithFormat:@"%d", playerID]];
                           
     spieler = [CoreDataHelper searchObjectsForEntity:@"Player" withPredicate:query_aktiver_spieler andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    Player *player = [spieler objectAtIndex:0];
    
    player.angle = [NSNumber numberWithDouble:angle];
    
    player.angleGlobalHeading = [NSNumber numberWithDouble:globalHeading];
    
    double angle_total = [player.angle_total doubleValue];
    
    double anglein = [player.angle doubleValue];
    
    player.angle_total = [NSNumber numberWithDouble:(angle_total + anglein)];
    
    [mainDelegate.managedObjectContext save:nil];

}

- (void) savePoints:(int)playerID:(double)points{
    
    NSMutableArray *spieler = [[NSMutableArray alloc] init];
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSPredicate *query_aktiver_spieler = [NSPredicate predicateWithFormat:@"id == %@", playerID];
    
    spieler = [CoreDataHelper searchObjectsForEntity:@"Player" withPredicate:query_aktiver_spieler andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    Player *player = [spieler objectAtIndex:0];
    
    player.points = [NSString stringWithFormat:@"%f", points];
    
    [mainDelegate.managedObjectContext save:nil];
    
}


- (void) deletePlayer
{
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    double playerCount = [CoreDataHelper countForEntity:@"Player" andContext:mainDelegate.managedObjectContext];
    
    if(playerCount>0)
    {
      [CoreDataHelper deleteAllObjectsForEntity:@"Player" andContext:mainDelegate.managedObjectContext];
        NSLog(@"====================== ALTE SPIELER GELÖSCHT");
    }
    
}


- (void)insertPlayer:(NSString *)playerName withId:(NSNumber *) playerId: (NSString *)fb_id;
{
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    Player *player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:mainDelegate.managedObjectContext];
    
    Friends *friend = nil;
    
    if(fb_id!=nil)
    {
        NSMutableArray *friends = [[NSMutableArray alloc] init];
                
        NSPredicate *query_emtpy = [NSPredicate predicateWithFormat:@"friend_id==%@",fb_id];
    
        friends = [CoreDataHelper searchObjectsForEntity:@"Friends" withPredicate:query_emtpy andSortKey:@"friend_id" andSortAscending:false andContext:mainDelegate.managedObjectContext];
        
        if (friends.count!=0) {
            
            friend = [friends objectAtIndex:0];
            player.fb_id = fb_id;
        }
    }
    else if (fb_id==nil)
    {
        player.fb_id = 0;
    }
    
    player.name = playerName;
    player.id = playerId;
   

    [mainDelegate.managedObjectContext save:nil];
    
       
}
     

@end
