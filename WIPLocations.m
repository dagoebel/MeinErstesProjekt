//
//  WIPLocations.m
//  new
//
//  Created by Daniel Goebel on 02.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPLocations.h"
#import "CoreDataHelper.h"
#import "Question.h"
#import "WIPAppDelegate.h"
#import "WIPViewController.h"


@implementation WIPLocations




- (Question*) selectLocation:(NSInteger)aktiverSpieler
{
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
 
    NSString *id_aktiver_spieler = [NSString stringWithFormat:@"%d", aktiverSpieler];
    NSString *fb_id_aktiver_spieler = [[NSString  alloc] init];
    NSString *fb_id_nicht_aktiver_spieler = [[NSString  alloc] init];
    NSMutableArray *nicht_aktive_spieler = [[NSMutableArray alloc] init];
    NSMutableArray *aktiver_spieler = [[NSMutableArray alloc] init];


    
    
    /// GET MITSPIELER
    
    
    NSPredicate *query_aktiver_spieler = [NSPredicate predicateWithFormat:@"id CONTAINS %@", id_aktiver_spieler];
    
    aktiver_spieler = [CoreDataHelper searchObjectsForEntity:@"Player" withPredicate:query_aktiver_spieler andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    NSPredicate *query_nicht_aktive_spieler = [NSPredicate predicateWithFormat:@"NOT id CONTAINS %@", fb_id_aktiver_spieler];
    
    nicht_aktive_spieler = [CoreDataHelper searchObjectsForEntity:@"Player" withPredicate:query_nicht_aktive_spieler andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    for (id single_aktiver_spieler in aktiver_spieler) {
        fb_id_aktiver_spieler = [single_aktiver_spieler valueForKey:@"fb_id"];
        NSLog(@"fb_id_aktiver_spieler %@", fb_id_aktiver_spieler);
    }
    
    for (id single_nicht_aktive_spieler in nicht_aktive_spieler) {
        fb_id_nicht_aktiver_spieler = [single_nicht_aktive_spieler valueForKey:@"fb_id"];
        NSLog(@"fb_id_nicht_aktiver_spieler %@", fb_id_nicht_aktiver_spieler);
    }
    
    //NSLog(@"fb_id_aktiver_spieler %@", fb_id_aktiver_spieler);
   
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(place_location_latitude != nil) AND (place_location_longitude != nil) AND (person_id != %@) AND (person_id contains[c] %@) AND ANY tags.id like %@", fb_id_aktiver_spieler, nicht_aktive_spieler, @"100000772131786" ];

    Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    if(question==nil)
    {
        NSLog(@"KEINE 1. LOCATION GEFUNDEN");
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(place_location_latitude != nil) AND (place_location_longitude != nil) AND (person_id != %@) AND (person_id contains[c] %@)", @"100001282720584", @"100001339740089"];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        return question;

    }
    
    return question;
       
}


- (void)insertLocation:(NSString *)locationName withLatti:(NSNumber *) locationLatti andLocationLongi: (NSNumber *) locationLongi
{
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];

    Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:mainDelegate.managedObjectContext];
    
    location.name = locationName;
    location.latti = locationLatti;
    location.longi = locationLongi;
    
    [mainDelegate.managedObjectContext save:nil];
    
        
}


@end
