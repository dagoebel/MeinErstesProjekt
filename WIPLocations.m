//
//  WIPLocations.m
//  new
//
//  Created by Daniel Goebel on 02.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPLocations.h"
#import "CoreDataHelper.h"
#import "Location.h"
#import "WIPAppDelegate.h"
#import "WIPViewController.h"


@implementation WIPLocations



- (void) createLocations
{
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [CoreDataHelper deleteAllObjectsForEntity:@"Location" andContext:mainDelegate.managedObjectContext];
   
    [self insertLocation:@"Paula Amling war bei Dresden Holi Open Air Festival" withLatti:[NSNumber numberWithDouble:51.050588328159000000000000000000] andLocationLongi:[NSNumber numberWithDouble:13.731794743445000000000000000000]];
    [self insertLocation:@"Kayser Hartmud war bei Arteum, Am Brauhaus 3, Dresden" withLatti:[NSNumber numberWithDouble:51.068614454596000000000000000000] andLocationLongi:[NSNumber numberWithDouble:13.778622449588000000000000000000]];
    [self insertLocation:@"Phoenix Wu war bei Fitness Fitness First Prager Spitze, Prager Str. 2" withLatti:[NSNumber numberWithDouble:51.041324183460000000000000000000] andLocationLongi:[NSNumber numberWithDouble:	13.734192362666000000000000000000]];
    [self insertLocation:@"Phoenix Wu war bei Park Sanssouci, Potsdam" withLatti:[NSNumber numberWithDouble:52.401182950000000000000000000000] andLocationLongi:[NSNumber numberWithDouble:13.017415320000000000000000000000]];
    [self insertLocation:@"Phoenix Wu war bei Katy's Garage, Alaunstraße 48" withLatti:[NSNumber numberWithDouble:51.066740252249000000000000000000] andLocationLongi:[NSNumber numberWithDouble:13.751660787179000000000000000000]];
    [self insertLocation:@"Sven Hemm war bei Griechisches Restaurant Delphi, Blasewitzer Str. 41" withLatti:[NSNumber numberWithDouble:51.053334970014000000000000000000] andLocationLongi:[NSNumber numberWithDouble:	13.779330444863000000000000000000]];
    [self insertLocation:@"Nicole Mäding war bei Zoo Dresden" withLatti:[NSNumber numberWithDouble:51.037469420426000000000000000000] andLocationLongi:[NSNumber numberWithDouble:13.752768848078000000000000000000]];

}

- (Location*) selectLocation
{
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];

    Location *location = [CoreDataHelper getRandomObjectsForEntity:@"Location" withSortKey:@"name" andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    return location;
       
}





- (void)insertLocation:(NSString *)locationName withLatti:(NSNumber *) locationLatti andLocationLongi: (NSNumber *) locationLongi
{
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];

    Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:mainDelegate.managedObjectContext];
    
    location.name = locationName;
    location.latti = locationLatti;
    location.longi = locationLongi;
    
    [mainDelegate.managedObjectContext save:nil];
    
        
}


@end
