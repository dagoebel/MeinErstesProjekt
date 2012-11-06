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
    

    NSMutableArray *IDinaktiv_arr = [[NSMutableArray alloc] init];
    
    NSMutableArray *IDalle_arr = [[NSMutableArray alloc] init];


    /// GET MITSPIELER
    
    
    NSPredicate *query_aktiver_spieler = [NSPredicate predicateWithFormat:@"id == %@", id_aktiver_spieler];
    
    aktiver_spieler = [CoreDataHelper searchObjectsForEntity:@"Player" withPredicate:query_aktiver_spieler andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    NSPredicate *query_nicht_aktive_spieler = [NSPredicate predicateWithFormat:@"NOT (id == %@)", fb_id_aktiver_spieler];
    
    nicht_aktive_spieler = [CoreDataHelper searchObjectsForEntity:@"Player" withPredicate:query_nicht_aktive_spieler andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    

    for (id single_aktiver_spieler in aktiver_spieler) {
        fb_id_aktiver_spieler = [single_aktiver_spieler valueForKey:@"fb_id"];
        NSLog(@"fb_id_aktiver_spieler %@", fb_id_aktiver_spieler);
    }
    
    for (id single_nicht_aktive_spieler in nicht_aktive_spieler) {
        fb_id_nicht_aktiver_spieler = [single_nicht_aktive_spieler valueForKey:@"fb_id"];
        [IDalle_arr  addObject:fb_id_nicht_aktiver_spieler];
        if (fb_id_nicht_aktiver_spieler!=fb_id_aktiver_spieler) {
            [IDinaktiv_arr addObject:fb_id_nicht_aktiver_spieler];
                        NSLog(@"fb_id_nicht_aktiver_spieler %@", fb_id_nicht_aktiver_spieler);
        }
    }
    
    ///// GET MUTUAL FRIENDS //////////////
    
    
    NSMutableArray *nicht_aktive_friends = [[NSMutableArray alloc] init];

    
    NSPredicate *query_nicht_aktive_friends = [NSPredicate predicateWithFormat:@"friend_id in %@", IDalle_arr];
    
    nicht_aktive_friends = [CoreDataHelper searchObjectsForEntity:@"Friends" withPredicate:query_nicht_aktive_friends andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
   
    NSMutableArray *player1 = [[NSMutableArray alloc] init];
    NSMutableArray *player2 = [[NSMutableArray alloc] init];
    NSMutableArray *player3 = [[NSMutableArray alloc] init];
    NSMutableArray *player4 = [[NSMutableArray alloc] init];

    
    int anzahl = 1;
    
    for (id single_nicht_aktive_friends in nicht_aktive_friends) {
        id test = [single_nicht_aktive_friends valueForKey:@"friendsmutualfriends"];
        for (FriendsMutualFriends *single_mutualfriend in test) {
            if(anzahl==1)
                [player1  addObject:single_mutualfriend.fb_id ];
            
            if(anzahl==2)
                [player2  addObject:single_mutualfriend.fb_id ];

            if(anzahl==3)
                [player3  addObject:single_mutualfriend.fb_id ];

            if(anzahl==4)
                [player4  addObject:single_mutualfriend.fb_id ];

            
            
            NSLog(@"MUTUALFRIENDS %@", single_mutualfriend.fb_id );
        }
        anzahl++;
        
    }
    
    NSMutableSet * set1 = [[NSMutableSet alloc] init];
    NSMutableSet * set2 = [[NSMutableSet alloc] init];
    NSMutableSet * set3 = [[NSMutableSet alloc] init];
    NSMutableSet * set4 = [[NSMutableSet alloc] init];
    
    if (anzahl>1) {
        set1 = [NSMutableSet setWithArray:player1];
    }
    
    if (anzahl>2) {
        
        set1 = [NSMutableSet setWithArray:player1];
        NSMutableSet * set22= [NSMutableSet setWithArray:player2];
        [set1 intersectSet:set22];
        
        set2 = [NSMutableSet setWithArray:player1];
        [set2 unionSet:set22];

    }
    
    if (anzahl>3) {
        
        set1 = [NSMutableSet setWithArray:player1];
        NSMutableSet * set31= [NSMutableSet setWithArray:player1];
        NSMutableSet * set32= [NSMutableSet setWithArray:player2];
        NSMutableSet * set33= [NSMutableSet setWithArray:player3];
        [set1 intersectSet:set32];
        [set1 intersectSet:set33];
        
         NSMutableSet * set1i2= [NSMutableSet setWithArray:player1];
         NSMutableSet * set2i3= [NSMutableSet setWithArray:player2];
         NSMutableSet * set3i1= [NSMutableSet setWithArray:player3];
        
        [set1i2 intersectSet:set32];
        [set2i3 intersectSet:set33];
        [set3i1 intersectSet:set31];
        
        [set1i2 unionSet:set2i3];
        
        [set1i2 unionSet:set3i1];
        
        set2 = set1i2;
        
        [set31 unionSet:set32];
        
        [set31 unionSet:set33];
        
        set3 = set31;


    }
    
    if (anzahl>4) {
        set1 = [NSMutableSet setWithArray:player1];
        NSMutableSet * set41= [NSMutableSet setWithArray:player1];
        NSMutableSet * set42= [NSMutableSet setWithArray:player2];
        NSMutableSet * set43= [NSMutableSet setWithArray:player3];
        NSMutableSet * set44= [NSMutableSet setWithArray:player4];
        
        [set1 intersectSet:set42];
        [set1 intersectSet:set43];
        [set1 intersectSet:set44];
        
        NSMutableSet * set1i2= [NSMutableSet setWithArray:player1];
        NSMutableSet * set1i3= [NSMutableSet setWithArray:player2];
        NSMutableSet * set1i4= [NSMutableSet setWithArray:player3];
        
        NSMutableSet * set2i3= [NSMutableSet setWithArray:player2];
        NSMutableSet * set2i4= [NSMutableSet setWithArray:player2];
        
        NSMutableSet * set3i4= [NSMutableSet setWithArray:player3];
        

        [set1i4 intersectSet:set44];
        [set2i3 intersectSet:set43];
        
        
        [set1i3 intersectSet:set43];
        [set2i4 intersectSet:set44];
        
        [set1i2 intersectSet:set42];
        [set3i4 intersectSet:set44];
        
        
        [set1i4 intersectSet:set2i3];
        [set1i3 intersectSet:set2i4];
        [set1i2 intersectSet:set3i4];
        
        [set1i4 unionSet:set1i3];
        [set1i4 unionSet:set1i2];
        
        set2 = set1i4;
        
        set1i2= [NSMutableSet setWithArray:player1];
        set1i3= [NSMutableSet setWithArray:player2];
        set1i4= [NSMutableSet setWithArray:player3];
        
        set2i3= [NSMutableSet setWithArray:player2];
        set2i4= [NSMutableSet setWithArray:player2];
        
        set3i4= [NSMutableSet setWithArray:player3];
        
        [set1i4 intersectSet:set44];
        [set2i3 intersectSet:set43];
        
        
        [set1i3 intersectSet:set43];
        [set2i4 intersectSet:set44];
        
        [set1i2 intersectSet:set42];
        [set3i4 intersectSet:set44];
        
        [set1i2 unionSet:set1i3];
        [set1i2 unionSet:set1i4];
        
        [set1i2 unionSet:set2i3];
        [set1i2 unionSet:set2i3];
        
        [set1i2 unionSet:set3i4];
        
        set3 = set1i2;
        
        [set41 unionSet:set42];
        [set41 unionSet:set43];
        [set41 unionSet:set44];
        
        set4 = set41;
        
    }
    
    //// PERSON SELBER UND MITSPIELER IN DEN TAGS!
    NSPredicate *predicate_asked = [NSPredicate predicateWithFormat:@"(asked == 0)"];
    
    NSMutableArray *questionArray = [CoreDataHelper searchObjectsForEntity:@"Question" withPredicate:predicate_asked andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    NSLog(@"COUNT: ASKED=0%u", questionArray.count);

    predicate_asked = [NSPredicate predicateWithFormat:@"(asked == 1)"];
    
    questionArray = [CoreDataHelper searchObjectsForEntity:@"Question" withPredicate:predicate_asked andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    NSLog(@"COUNT: ASKED=1%u", questionArray.count);


    //// PERSON SELBER UND MITSPIELER IN DEN TAGS!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (person_id == %@) AND (ANY tags.id in %@)", fb_id_aktiver_spieler, IDinaktiv_arr];
    
    Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    

    ////// MIND 1. MITSPIELR MITSPIELER PERSON UND TAGS
    if(question==nil)
    {
        NSLog(@"1. KEINE - PERSON SELBER UND MITSPIELER IN DEN TAGS! ");
 
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@) AND (ANY tags.id in %@)", IDalle_arr, IDalle_arr];

        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
        return question;

    }
    
    ////// MIND. 1 MITSPIELER MIT SET1 IN TAGS
    if(question==nil)
    {
         NSLog(@"2. KEINE - MIND 1. MITSPIELR MITSPIELER PERSON UND TAGS");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@) AND (ANY tags.id in %@)", IDalle_arr, set1];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            
        return question;
        
    }
    
    ////// MIND. 1 MITSPIELER MIT SET2 IN TAGS
    if(question==nil&&anzahl>2)
    {
        NSLog(@"3. KEINE - MIND. 1 MITSPIELER MIT SET1 IN TAGS");
         
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@) AND (ANY tags.id in %@)", IDalle_arr, set2];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
        return question;
        
    }
    
    ////// MIND. 1 MITSPIELER MIT SET3 IN TAGS
    if(question==nil&&anzahl>3)
    {
        NSLog(@"4. KEINE - MIND. 1 MITSPIELER MIT SET2 IN TAGS");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@) AND (ANY tags.id in %@)", IDalle_arr, set3];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 MITSPIELER MIT SET4 IN TAGS
    if(question==nil&&anzahl>4)
    {
        NSLog(@"5. KEINE - MIND. 1 MITSPIELER MIT SET3 IN TAGS");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@) AND (ANY tags.id in %@)", IDalle_arr, set4];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET1
    if(question==nil&&anzahl>1)
    {
        NSLog(@"6. KEINE - MIND. 1 MITSPIELER MIT SET4 IN TAGS");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@)", set1];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET2
    if(question==nil&&anzahl>2)
    {
        NSLog(@"7. KEINE - SET1");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@)", set2];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET3
    if(question==nil&&anzahl>3)
    {
        NSLog(@"8. KEINE - SET2");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@)", set3];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET4
    if(question==nil&&anzahl>4)
    {
        NSLog(@"8. KEINE - SET3");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY person_id in %@)", set4];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET1 TAGS
    if(question==nil&&anzahl>1)
    {
        NSLog(@"9. KEINE - SET4");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY tags.id in %@)", set1];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET2 TAGS
    if(question==nil&&anzahl>2)
    {
        NSLog(@"10. KEINE - TAG SET1");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY tags.id in %@)", set2];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET3 TAGS
    if(question==nil&&anzahl>3)
    {
        NSLog(@"11. KEINE - SET2");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY tags.id in %@)", set3];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// MIND. 1 SET4 TAGS
    if(question==nil&&anzahl>4)
    {
        NSLog(@"12. KEINE - SET3 TAGS");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil) AND (ANY tags.id in %@)", set4];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
            return question;
        
    }
    
    ////// IRGENDJEMAND
    if(question==nil)
    {
        NSLog(@"KEINE 5. IRGENDJEMAND");
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(asked == 0) AND (place_location_latitude != nil) AND (place_location_longitude != nil)"];
        
        Question *question = [CoreDataHelper searchRandomObjectsForEntity:@"Question" withPredicate:predicate andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
        if(question!=nil)
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
