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
#import "WIPViewController.h"

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

- (void)queryFacebook: (NSString*) query {
    
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];

    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        [self processLocations:connection result:result error:error];
    };
    
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:query];
    
    [newConnection addRequest:request completionHandler:handler];    
    [self.requestConnection cancel];    
    self.requestConnection = newConnection;
    [newConnection start];
}


- (void)processLocations:(FBRequestConnection *)connection result:(id)result error:(NSError *)error {
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [CoreDataHelper deleteAllObjectsForEntity:@"Question" andContext:mainDelegate.managedObjectContext];


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

   //NSLog(@"%@",result);
    NSArray* friends = [result objectForKey:@"data"];
    
    
    [self processParsedObject:friends];
  
}

- (void)saveQuestion:(NSDictionary*) newQuestion {
             
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:mainDelegate.managedObjectContext];
    
    question.person_name=[newQuestion valueForKey:@"person_name"];
    question.person_id=[newQuestion valueForKey:@"person_id"];
    question.place_name=[newQuestion valueForKey:@"place_name"];
    question.place_id=[newQuestion valueForKey:@"place_id"];
    question.tags_name=[newQuestion valueForKey:@"tags_name"];
    question.tags_id=[newQuestion valueForKey:@"tags_id"];
    question.place_location_city=[newQuestion valueForKey:@"place_location_city"];
    question.place_location_latitude=[newQuestion valueForKey:@"place_location_latitude"];
    question.place_location_longitude=[newQuestion valueForKey:@"place_location_longitude"];
    question.place_location_street=[newQuestion valueForKey:@"place_location_street"];
    question.place_location_zip=[newQuestion valueForKey:@"place_location_zip"];
    question.created_time=[newQuestion valueForKey:@"created_time"];
    question.from_id=[newQuestion valueForKey:@"from_id"];
    question.from_name=[newQuestion valueForKey:@"from_name"];
    
     NSLog(@"%@",question);
    
    [mainDelegate.managedObjectContext save:nil];
    
}

-(void)processParsedObject:(id)object{
    [self processParsedObject:object depth:0 parent:nil];
}

-(void)processParsedObject:(id)object depth:(int)depth parent:(id)parent{
    
   if([object isKindOfClass:[NSArray class]]){
        
        for(id child in object){
            
            NSString *person_name= nil;
            NSString *person_id= nil;
            
            person_name = [child valueForKey:@"name"];
            person_id = [child valueForKey:@"id"];
            
            if([child objectForKey:@"locations"] !=nil)
            {
                
                NSString *place_name= nil;
                NSString *place_id= nil;
                NSString *tags_name= nil;
                NSString *tags_id= nil;
                NSString *place_location_city= nil;
                NSNumber *place_location_latitude= nil;
                NSNumber *place_location_longitude= nil;
                NSString *place_location_street= nil;
                NSString *place_location_zip= nil;
                NSString *created_time= nil;
                NSString *from_id= nil;
                NSString *from_name= nil;
               
                id locations = [child objectForKey:@"locations"];
                
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
                
                    for (id tag in tags) {
                        ////////// MIT LEUTEN //////////////
                        tags_id = [tag valueForKey:@"id"];
                        tags_name = [tag valueForKey:@"name"];
                    }
                    
                    NSDictionary *newQuestion = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 person_name, @"person_name",
                                                 person_id, @"person_id",
                                                 place_name, @"place_name",
                                                 place_id, @"place_id",
                                                 tags_name, @"tags_name",
                                                 tags_id, @"tags_id",
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


- (void)showQuestion{

    
        WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
        Question *question = [CoreDataHelper getRandomObjectsForEntity:@"Question" withSortKey:@"place_id" andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
        NSLog(@"question.locationname %@",question );

    
}



































- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; n ote that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        
        NSLog(@"ads %@",user.name);
        [text appendString:user.name];
        
        self.friendPickerController = [[FBRequest alloc] init];
        
        // Do not set current API as this is commonly called by other methods
        WIPFacebook *delegate = (WIPFacebook *)[[UIApplication sharedApplication] delegate];
        
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@"<Cancelled>"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    //self.selectedFriendsView.text = text;
    
    [self.friendPickerController.parentViewController  dismissViewControllerAnimated:YES completion:nil];
}



- (UIViewController *)pickFriendsButtonClick {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        }
    }];
    
    [self.friendPickerController clearSelection];
    
    // iOS 5.0+ apps should use [UIViewController presentViewController:animated:completion:]
    // rather than this deprecated method, but we want our samples to run on iOS 4.x as well.
    //[self presentModalViewController:self.friendPickerController animated:YES];
    return self.friendPickerController;
    
}



#pragma mark -


@end
