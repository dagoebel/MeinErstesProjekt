//
//  WIPFacebook.m
//  new
//
//  Created by Daniel Goebel on 14.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPAppDelegate.h"
#import "WIPFacebook.h"
#import "CoreDataHelper.h"
#import "Question.h"
#import "Tags.h"
#import "Friends.h"

// FBSample logic
// We need to handle some of the UX events related to friend selection, and so we declare
// that we implement the FBFriendPickerDelegate here; the delegate lets us filter the view
// as well as handle selection events
@interface WIPFacebook ()

@property (strong, nonatomic) IBOutlet UITextView *selectedFriendsView;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) FBRequestConnection *requestConnection;

- (void)fillTextBoxAndDismiss:(NSString *)text;

- (IBAction)buttonRequestClickHandler:(id)sender;

- (void)sendRequests;

- (void)requestCompleted:(FBRequestConnection *)connection
                 forFbID:(NSString *)fbID
                  result:(id)result
                   error:(NSError *)error;

@end

@implementation WIPFacebook

@synthesize selectedFriendsView = _friendResultText;
@synthesize friendPickerController = _friendPickerController;
@synthesize requestConnection = _requestConnection;

int limit, offset, querycount;

int limit = 50;
int offset = 0;
int querycount = 1;

- (void)sendRequestToFacebook:(NSString*) query{
    
    
    if([self checkFBSession])
    {
        [self queryFacebook:query];
  
    }
}

- (BOOL)checkFBSession {
    
    static bool conectionEnabled = nil;
    
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_location",
                            @"user_birthday",
                            @"user_likes",
                            @"user_checkins",
                            @"friends_location",
                            @"friends_hometown",
                            @"friends_checkins",
                            nil];
    
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
         {
             if (error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
                 conectionEnabled = false;
             } else if (FB_ISSESSIONOPENWITHSTATE(status))
             {
                 conectionEnabled = true;
             }
         }];
    }
    return conectionEnabled;
}

- (void)queryFacebook:(NSString*) query{
    
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self processResponse:connection result:result error:error];
    };
    
    FBRequest *request = nil;
    
    if (query==nil) {
        request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me/friends?fields=name,locations,checkins.fields(id,tags,place,created_time)&limit=50&offset=0"];
    }
    else{
        request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:query];
    }
    
    [newConnection addRequest:request completionHandler:handler];
    [self.requestConnection cancel];
    self.requestConnection = newConnection;
    [newConnection start];
}


- (void)processResponse:(FBRequestConnection *)connection result:(id)result error:(NSError *)error{
    
    if (self.requestConnection &&
        connection != self.requestConnection) {
        return;
    }
    self.requestConnection = nil;
    
    NSString *text;
    
    if (error) {
        text = error.localizedDescription;
    } else {
        
        NSArray* friends = [result objectForKey:@"data"];
        if(friends.count>0)
        {
            offset = limit * querycount;
            NSString * query = @"me/friends?fields=name,locations,checkins.fields(id,tags,place,created_time)&limit=";
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%i",limit]];
            query = [query stringByAppendingString:@"&offset="];
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%i",offset]];
            [self sendRequestToFacebook:query];
            [self processParsedLocations:friends];
            querycount = querycount+1;
        }
        
        //NSLog(@"%@",result);
        
        
        //NSArray* checkFriends = [result objectForKey:@"friends"];
        
        
        
        
        
    }
    
    
}

- (void)saveQuestion:(NSMutableDictionary*) newQuestion {
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:mainDelegate.managedObjectContext];
    
    question.person_name=[newQuestion valueForKey:@"person_name"];
    question.person_id=[newQuestion valueForKey:@"person_id"];
    question.place_name=[newQuestion valueForKey:@"place_name"];
    question.place_id=[newQuestion valueForKey:@"place_id"];
    question.place_location_city=[newQuestion valueForKey:@"place_location_city"];
    question.place_location_latitude=[newQuestion valueForKey:@"place_location_latitude"];
    question.place_location_longitude=[newQuestion valueForKey:@"place_location_longitude"];
    question.place_location_street=[newQuestion valueForKey:@"place_location_street"];
    question.place_location_zip=[newQuestion valueForKey:@"place_location_zip"];
    question.created_time=[newQuestion valueForKey:@"created_time"];
    question.from_id=[newQuestion valueForKey:@"from_id"];
    question.from_name=[newQuestion valueForKey:@"from_name"];
    
    
    NSMutableSet *mySet = [[NSMutableSet alloc] init];
    NSMutableArray *tagsName = [NSMutableArray array];
    
    //  NSLog(@"[newQuestion valueForKey:tags_id%@",[newQuestion valueForKey:@"tags_id"]);
    //  NSLog(@"[newQuestion valueForKey:tags_name%@",[newQuestion valueForKey:@"tags_name"]);
    
    tagsName = [newQuestion valueForKey:@"tags_name"];
    
    int i = 0;
    
    for (id tag_id in [newQuestion valueForKey:@"tags_id"]){
        
        Tags *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tags" inManagedObjectContext:mainDelegate.managedObjectContext];
        
        tag.id = tag_id;
        tag.name = [tagsName objectAtIndex:i];
        
        NSLog(@"QUESTION TAG ID%@", tag.id);
        NSLog(@"QUESTION TAG NAME%@", tag.name);
        
        [mySet addObject:tag];
        
        i++;
        
    }
    
    
    [question setTags:mySet];
    
    //NSLog(@"TAGS: %@",tags);
    NSLog(@"QUESTION%@",question);
    
    [mainDelegate.managedObjectContext save:nil];
    
}

-(void)processParsedLocations:(id)object{
    [self processParsedLocations:object depth:0 parent:nil];
}

-(void)processParsedLocations:(id)object depth:(int)depth parent:(id)parent{
    
    if([object isKindOfClass:[NSArray class]]){
        
        for(id child in object){
            
            NSString *person_name= nil;
            NSString *person_id= nil;
            
            person_name = [child valueForKey:@"name"];
            person_id = [child valueForKey:@"id"];
            
            if([child objectForKey:@"locations"] !=nil||[child objectForKey:@"checkins"] !=nil)
            {
                
                NSString *place_name= nil;
                NSString *place_id= nil;
                NSString *place_location_city= nil;
                NSNumber *place_location_latitude= nil;
                NSNumber *place_location_longitude= nil;
                NSString *place_location_street= nil;
                NSString *place_location_zip= nil;
                NSString *created_time= nil;
                NSString *from_id= nil;
                NSString *from_name= nil;
                
                id locations = nil;
                
                if([child objectForKey:@"locations"]!=nil){
                    locations = [child objectForKey:@"locations"];
                }
                else if ([child objectForKey:@"checkins"]!=nil)
                {
                    locations = [child objectForKey:@"checkins"];
                }
                
                
                NSArray* data = [locations objectForKey:@"data"];
                
                for (id checkin in data) {
                    
                    ////////// LOCATION NAME //////////////
                    NSDictionary<FBGraphPlace> *place = [checkin objectForKey:@"place"];
                    
                    
                    place_name = place.name;
                    place_id = place.id;
                    created_time = [checkin valueForKey:@"created_time"];
                    
                    
                    ///// LOCATION city property, country property, latitude property, longitude property,  state property, street property, zip proper
                    id placeRaw = [checkin objectForKey:@"place"];
                    NSDictionary<FBGraphLocation> *location = [placeRaw objectForKey:@"location"];
                    if(![location isKindOfClass:[NSString class]]){
                        
                        place_id = [placeRaw valueForKey:@"id"];
                        place_location_city = location.city;
                        place_location_latitude = location.latitude;
                        place_location_longitude = location.longitude;
                        place_location_street = location.street;
                        place_location_zip = location.zip;
                    }
                    
                    
                    id tagsData = [checkin objectForKey:@"tags"];
                    NSArray* tags  = [tagsData objectForKey:@"data"];
                    NSMutableArray *tags_id_arr = [[NSMutableArray alloc] init];
                    NSMutableArray *tags_name_arr = [[NSMutableArray alloc] init];
                    
                    for (id tag in tags) {
                        ////////// MIT LEUTEN //////////////
                        
                        [tags_id_arr addObject:[tag valueForKey:@"id"]];
                        [tags_name_arr addObject:[tag valueForKey:@"name"]];
                    }
                    
                    
                    NSMutableDictionary *newQuestion = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        person_name, @"person_name",
                                                        person_id, @"person_id",
                                                        place_name, @"place_name",
                                                        place_id, @"place_id",
                                                        tags_name_arr, @"tags_name",
                                                        tags_id_arr, @"tags_id",
                                                        place_location_city, @"place_location_city",
                                                        place_location_latitude, @"place_location_latitude",
                                                        place_location_longitude, @"place_location_longitude",
                                                        place_location_street, @"place_location_street",
                                                        place_location_zip, @"place_location_zip",
                                                        created_time, @"created_time",
                                                        from_id, @"from_id",
                                                        from_name, @"from_name", nil];
                    
                    
                    if (place_location_latitude!=nil&&place_location_longitude!=nil&&place_name!=nil) {
                        [self saveQuestion: newQuestion];
                    }
                    
                    
                }
                
                
                // [self processParsedObject:child depth:depth+1 parent:object];
                
                
                
                
                
            }
            
            
            
        }
        
    }
    else{
        //This object is not a container you might be interested in it's value
        //NSLog(@"OBJECT: %@  depth: %d",object,depth);
    }
    
    
}










-(void)processParsedFriends:(id)object andTableView: (NSArray*) tableView{
    [self processParsedFriends:object depth:0 parent:nil andTableView: tableView];
}

-(void)processParsedFriends:(id)object depth:(int)depth parent:(id)parent andTableView: (NSArray*) tableView{
    
    if([object isKindOfClass:[NSArray class]]){
        
        
        
        for(id friend in object){
            
            NSString *person_name= nil;
            NSString *person_id= nil;
            
            person_name = [friend valueForKey:@"name"];
            person_id = [friend valueForKey:@"id"];
            
            NSLog(@"%@",person_name);
            
            
            
        }
        
    }
    
    
    
    
}



- (void)saveFriends:(NSDictionary*) newFriend {
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    Friends *friends= [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:mainDelegate.managedObjectContext];
    
    friends.name=[newFriend valueForKey:@"name"];
    friends.friend_id=[newFriend valueForKey:@"id"];
    friends.picture=[newFriend valueForKey:@"picture"];
    
    NSLog(@"%@", friends);
    [mainDelegate.managedObjectContext save:nil];
    
}






- (void)getFacebookFriends:(UITableView*) tableView {
    
    if([self checkFBSession])
    {
        FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
        
        FBRequestHandler handler =
        ^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (self.requestConnection &&
                connection != self.requestConnection) {
                return;
            }
            self.requestConnection = nil;
            
            NSString *text;
            
            if (error) {
                text = error.localizedDescription;
            } else {
                NSDictionary *dictionary = (NSDictionary *)result;
                text = (NSString *)[dictionary objectForKey:@"data"];
            }
            
            NSLog(@"%@",result);
            id friendsObj = [result objectForKey:@"friends"];
            
            NSArray* friends = [friendsObj objectForKey:@"data"];
            
            
            
            
            if([friends isKindOfClass:[NSArray class]]){
                
                WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
                
                
                [CoreDataHelper deleteAllObjectsForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
                [CoreDataHelper deleteAllObjectsForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
                
                NSString *person_name= [result valueForKey:@"name"];
                NSString *person_id= [result objectForKey:@"id"];
                id picObj = [result objectForKey:@"picture"];
                id dataObj = [picObj objectForKey:@"data"];
                NSString *person_picture = [dataObj valueForKey:@"url"];
                
                NSString *person_pictureBase64 = nil;
                
                NSDictionary *newFriend = [NSDictionary dictionaryWithObjectsAndKeys:
                                           person_name, @"name",
                                           person_id, @"id",
                                           person_picture, @"picture",
                                           nil];
                
                
                [self saveFriends:newFriend];
                
                
                
                for(id friend in friends){
                    
                    person_name= nil;
                    person_id= nil;
                    person_picture= nil;
                    person_pictureBase64= nil;
                    
                    person_name = [friend valueForKey:@"name"];
                    person_id = [friend valueForKey:@"id"];
                    
                    id picObj = [friend objectForKey:@"picture"];
                    id dataObj = [picObj objectForKey:@"data"];
                    person_picture = [dataObj valueForKey:@"url"];
                    
                    
                    NSDictionary *newFriend = [NSDictionary dictionaryWithObjectsAndKeys:
                                               person_name, @"name",
                                               person_id, @"id",
                                               person_picture, @"picture",
                                               nil];
                    
                    
                    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
                    
                    Friends *friends= [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:mainDelegate.managedObjectContext];
                    
                    friends.name=[newFriend valueForKey:@"name"];
                    friends.friend_id=[newFriend valueForKey:@"id"];
                    friends.picture=[newFriend valueForKey:@"picture"];
      
                    NSString *imageUrlString = @"http://graph.facebook.com/";
                    imageUrlString = [imageUrlString stringByAppendingString:[newFriend valueForKey:@"id"]];
                    imageUrlString = [imageUrlString stringByAppendingString:@"/picture?type=large"];
                    
                    NSURL *imageURL = [NSURL URLWithString: imageUrlString];
                    

                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Update the UI
                            
                            UIImage* new = [UIImage imageWithData:imageData];
                            friends.pictureBase64 =  new;
                            NSLog(@"%@", friends);
                            [mainDelegate.managedObjectContext save:nil];
                            
                        });
                    });
                
                }
                
                
                [self getFacebookMutualFriends];
                [tableView reloadData];
                
            }
            
            
        };
        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"me?fields=id,friends.fields(picture,name),name,picture"];
        
        [newConnection addRequest:request completionHandler:handler];
        [self.requestConnection cancel];
        self.requestConnection = newConnection;
        [newConnection start];
        
        
        
    };
    
}






- (void)getFacebookMutualFriends {
    
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSPredicate *query_emtpy = [NSPredicate predicateWithFormat:@"friendsmutualfriends.@count == 0"];
    
    friends = [CoreDataHelper searchObjectsForEntity:@"Friends" withPredicate:query_emtpy andSortKey:@"friend_id" andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    if (friends.count!=0) {
        
        Friends *friend = [friends objectAtIndex:0];
        
        
        FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
        
        
        FBRequestHandler handler =
        ^(FBRequestConnection *connection, id result, NSError *error) {
            
            
            //////////////////////
            
            if (self.requestConnection &&
                connection != self.requestConnection) {
                return;
            }
            self.requestConnection = nil;
            
            NSString *text;
            
            if (error) {
                text = error.localizedDescription;
                //return nil;
            } else {
                NSDictionary *dictionary = (NSDictionary *)result;
                text = (NSString *)[dictionary objectForKey:@"data"];
            }
            
            NSLog(@"%@",result);
            id friendsObj = [result objectForKey:@"mutualfriends"];
            
            NSArray* friendsraw = [friendsObj objectForKey:@"data"];
            NSMutableSet *mySet = [[NSMutableSet alloc] init];
            
            if([friendsraw  isKindOfClass:[NSArray class]]){
                
                for(id friendraw in friendsraw ){
                    
                    NSString* person_name= nil;
                    NSString* person_id= nil;
                    NSString* person_picture= nil;
                    
                    person_name = [friendraw valueForKey:@"name"];
                    person_id = [friendraw valueForKey:@"id"];
                    
                    id picObj = [friendraw objectForKey:@"picture"];
                    id dataObj = [picObj objectForKey:@"data"];
                    person_picture = [dataObj valueForKey:@"url"];
                    
                    
                    FriendsMutualFriends *FriendsMutualFriends = [NSEntityDescription insertNewObjectForEntityForName:@"FriendsMutualFriends" inManagedObjectContext:mainDelegate.managedObjectContext];
                    
                    FriendsMutualFriends.fb_id = person_id;
                    FriendsMutualFriends.name = person_name;
                    FriendsMutualFriends.fb_url = person_picture;
                    
                    [mySet addObject:FriendsMutualFriends];
                    
                }
                
                
                
            }
            else{
                
                FriendsMutualFriends *FriendsMutualFriends = [NSEntityDescription insertNewObjectForEntityForName:@"FriendsMutualFriends" inManagedObjectContext:mainDelegate.managedObjectContext];
                
                FriendsMutualFriends.fb_id = nil;
                FriendsMutualFriends.name = nil;
                FriendsMutualFriends.fb_url = nil;
                
                [mySet addObject:FriendsMutualFriends];
                
            }
            
            [friend setFriendsmutualfriends:mySet];
            
            [mainDelegate.managedObjectContext save:nil];
            NSLog(@"%@",friend);
            [self getFacebookMutualFriends];
            
            //////////////////////
        };
        
        NSString* query = @"me?fields=id,name,mutualfriends.user(";
        query = [query stringByAppendingString:friend.friend_id];
        query = [query stringByAppendingString:@").fields(name,picture)"];
        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:query];
        
        
        
        [newConnection addRequest:request completionHandler:handler];
        [self.requestConnection cancel];
        self.requestConnection = newConnection;
        [newConnection start];
        
    }
    
    
}



@end
