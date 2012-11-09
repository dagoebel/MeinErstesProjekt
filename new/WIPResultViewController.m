//
//  WIPResultViewController.m
//  new
//
//  Created by Daniel Goebel on 09.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPResultViewController.h"
#import "WIPGameController.h"
#import "WIPAppDelegate.h"
#import "CoreDataHelper.h"

@interface WIPResultViewController ()

@end

@implementation WIPResultViewController
@synthesize result1,result2,result3,result4;
@synthesize i1,i2,i3,i4;


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"AS ");
    result1.text = @"AS ";
    
    NSMutableArray *spieler = [[NSMutableArray alloc] init];
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    mWIPGameController = [[WIPGameController alloc]init];
    
    NSArray *liste = [mWIPGameController getResults];
        
        int i = 1;
        NSString *name = nil;
        NSString *distance = nil;
        NSString *playerid = nil;
    
        
        //// SELECT KREIS IMG
        
        for (NSDictionary *listeneintrag in liste)
        {
            

            name = [listeneintrag valueForKey:@"name"];
            distance = [listeneintrag valueForKey:@"distance"];
            playerid = [listeneintrag valueForKey:@"id"];
            double dis = [distance doubleValue];
            dis =  180 / M_PI  * dis;
            
            NSPredicate *query = [NSPredicate predicateWithFormat:@"id == %@", playerid];
            spieler = [CoreDataHelper searchObjectsForEntity:@"Player" withPredicate:query andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
            Player *player = [spieler objectAtIndex:0];

        if (i==1) {
                
            result1.text = [NSString stringWithFormat:@"- %.0f°",dis];
            i1.image = player.pictureBase64;
            i1.hidden = false;
            
            
            }
        if (i==2) {
            
            result2.text = [NSString stringWithFormat:@"- %.0f°",dis];
            i2.image = player.pictureBase64;
            i2.hidden = false;
            
        }
        
        if (i==3) {
            
           result3.text = [NSString stringWithFormat:@"- %.0f°",dis];
            i3.image = player.pictureBase64;
            i3.hidden = false;
            
        }
        
        if (i==4) {
            
            result4.text = [NSString stringWithFormat:@"- %.0f°",dis];
            i4.image = player.pictureBase64;
            i4.hidden = false;
            
        }
   
        
            i++;
        
    } 


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    
   
    [self dismissViewControllerAnimated:false completion:nil];
 
}


- (IBAction)closeInstruction:(id)sender {
    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WIPViewController"];
    
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    [self presentViewController:vc
                       animated:YES completion:nil];

}
@end

