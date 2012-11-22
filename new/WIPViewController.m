//
//  WIPViewController.m
//  new
//
//  Created by Daniel Goebel on 26.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPViewController.h"
#import "WIPAppDelegate.h"
#import "Friends.h"
#import "Tags.h"
#import "CoreDataHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "WIPResultViewController.h"
#import "QuestionAsked.h"

@interface WIPViewController ()


@end


static double kompassScheibeHeight, kompassScheibeWidth;
static double globalHeading, bottleHeading;
static double anzahlPlayer, currentPlayer, startPlayer, countPlayer;
static bool spielAktiv;
static double spielerAktiv;
static Question *locationAktiv;
static CLLocationCoordinate2D globalPosition;
static double globalLocationHeading;

@implementation WIPViewController{
    
    NSArray *tableData;
}

@synthesize glass1, glass2, glass3, glass4, glassOutlet2;
@synthesize spieler1, spieler2, spieler3, spieler4;
@synthesize spielerName;
@synthesize spieler1Btn, spieler2Btn, spieler3Btn, spieler4Btn;

@synthesize spieler1Lbl,  spieler2Lbl, spieler3Lbl, spieler4Lbl;
@synthesize player1Img;
@synthesize menuLabel;
@synthesize tableView;

@synthesize people, filteredPeople;
@synthesize searchDisplayController;
@synthesize progressBar;
@synthesize naechsteRundeBtn;
@synthesize spinngLblTop, spinngLblBot, spinningLblBackr, spinningLblBackr2;

@synthesize spieler1Bubble, spieler2Bubble, spieler3Bubble,spieler4Bubble;
@synthesize spieler1BubbleImg, spieler2BubbleImg, spieler3BubbleImg, spieler4BubbleImg;
@synthesize auswertungLbl1, auswertungLbl2,auswertungLbl3,auswertungLbl4;
@synthesize auswertungView;
@synthesize player1Auswertung, player2Auswertung, player3Auswertung, player4Auswertung;
@synthesize player1AuswertungImg,player2AuswertungImg,player3AuswertungImg,player4AuswertungImg;
@synthesize nextBtn,cameraBtn;

@synthesize loadingF,loadingView;





//////////////

@synthesize  qu_unten_am,qu_unten_amVALIE,qu_unten_bei,qu_unten_beiVALIE,qu_unten_in,qu_unten_inVALIE,qu_unten_mit,qu_unten_mitVALIE,qu_unten_war,qu_unten_warVALIE, qu_unten_bei2, qu_unten_bei2VALIE;
@synthesize qu_oben_am,qu_oben_amVALIE,qu_oben_bei,qu_oben_bei2,qu_oben_bei2VALIE,qu_oben_beiVALIE,qu_oben_in,qu_oben_inVALIE,qu_oben_mit,qu_oben_mitVALIE,qu_oben_war,qu_oben_warVALIE;



////////

static int curveValues[] = {
    UIViewAnimationOptionCurveEaseInOut,
    UIViewAnimationOptionCurveEaseIn,
    UIViewAnimationOptionCurveEaseOut,
    UIViewAnimationOptionCurveLinear };



@synthesize container, startTransform, bottle, zeiger, zeigerLbl, kompassScheibe, kompassScheibeImg;
@synthesize locationLblBot, locationLblTop, gameMenu;

- (void)viewDidLoad
{
    [super viewDidLoad];
    

        
        NSLog(@"LOGGED IN");

        spielAktiv = false;
        spielerAktiv = 0;
        locationAktiv = nil;
        
        loadingView.hidden = true;
        

        kompassScheibeHeight = kompassScheibeImg.frame.size.height;
        kompassScheibeWidth = kompassScheibeImg.frame.size.width;
        locationLblTop.transform = CGAffineTransformRotate(locationLblTop.transform,  M_PI);
        spinningLblBackr2.transform = CGAffineTransformRotate(spinningLblBackr2.transform,  M_PI);
        
        /// START LOCATION SERVICES

        CLController = [[WIPLocationController alloc] init];
        CLController.delegate = self;
        CLController.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
        CLController.locMgr.headingFilter = 0;
        [CLController.locMgr startUpdatingLocation];
        [CLController.locMgr startUpdatingHeading];

 
    
   
    
}

- (UIImage * ) mergeImage: (UIImage *) imageA
                withImage:  (UIImage *) imageB
                 strength: (float) strength {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageA.size.width, imageA.size.height), YES, 0.0);
    
    
 
    [imageA drawInRect:CGRectMake(0, 0, imageA.size.width, imageA.size.height)];
    [imageB drawInRect:CGRectMake(0, 0, imageA.size.width, imageA.size.height) blendMode: kCGBlendModeNormal alpha: strength];
    

    
    UIImage *answer = UIGraphicsGetImageFromCurrentImageContext();
    
  
    UIGraphicsEndImageContext();
    return answer;
}


- (void)locationUpdate:(CLLocation *)location {
    globalPosition = [location coordinate];
    
    if (spielAktiv && locationAktiv!=nil) {
        mWIPDirection  = [[WIPDirection alloc] init];        
        float angle = [mWIPDirection performDirectionCalculation:locationAktiv withMyPosition:globalPosition];
        globalLocationHeading = angle;
        zeiger.tag = angle;
        if (angle>=90){
            zeiger.transform = CGAffineTransformMakeRotation(M_PI / 180 * (angle-90));
        }
        else{
            zeiger.transform = CGAffineTransformMakeRotation(M_PI / 180 * (360-angle));
        }
        
        
             }
    
    }

- (void)locationError:(NSError *)error {
	NSLog(@"ERROR %@", [error description]);
    
}

- (void)headingUpdate:(CLHeading *)heading {
    globalHeading = heading.trueHeading;

       if (spielAktiv) {
           [UIView animateWithDuration:0.0 delay:0.0 options:0
                            animations:^{
                                kompassScheibe.transform = CGAffineTransformMakeRotation(M_PI / 180 * (-[heading trueHeading]));
                                                               
                               

                                
                            }
                            completion:nil];

    }
}

- (void)initiateNewGame{
    NSLog(@"INITIATE NEW GAME - RESET PLAYER, QUESTIONASKED AND ASKED==1");
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];

    [CoreDataHelper deleteAllObjectsForEntity:@"Player" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"QuestionAsked" andContext:mainDelegate.managedObjectContext];
    
    NSMutableArray *questionsAsked = [[NSMutableArray alloc] init];
    
    NSPredicate *asked = [NSPredicate predicateWithFormat: @"asked == 1"];
    
    questionsAsked = [CoreDataHelper searchObjectsForEntity:@"Question" withPredicate:asked andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];

    for (Question *question in questionsAsked) {
        question.asked = [NSNumber numberWithInt:0];
        [mainDelegate.managedObjectContext save:nil];
    }
                 
}

- (void)initiateNewUser{
	NSLog(@"INITIATE NEW USER");
    
    loadingView.hidden = false;
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    [CoreDataHelper deleteAllObjectsForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Location" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Player" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Tags" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Question" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"QuestionAsked" andContext:mainDelegate.managedObjectContext];
    
    mWIPFacebook = [[WIPFacebook alloc] init];
    
    [mWIPFacebook openFBSession];
        
    [mWIPFacebook getFacebookFriends:^(int result){
        
        loadingF.text = @"Ermittle Freundesfreunde...";
        
        [mWIPFacebook getFacebookMutualFriends:^(int result){
            
            

            if (result==100) {
                
                loadingF.text = @"Ermittle CheckIns...";
                
                [mWIPFacebook queryLocations:nil :^(int result){

                                        
                    if (result==-1) {
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
                        
                        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WIPViewController"];
                        
                        [vc setModalPresentationStyle:UIModalPresentationFullScreen];
                        
                        [self presentViewController:vc
                                           animated:YES completion:nil];

                    }
                    
                    
                }];

            }
            
                       
        }];

        
    }];

    

    

}

- (void)logoutUser{
	NSLog(@"LOGOUT USER");
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    [CoreDataHelper deleteAllObjectsForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Location" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Player" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Tags" andContext:mainDelegate.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Question" andContext:mainDelegate.managedObjectContext];
    
    mWIPFacebook = [[WIPFacebook alloc] init];
    
    [mWIPFacebook closeFBSession];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WIPViewController"];
    
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    [self presentViewController:vc
                       animated:YES completion:nil];

        
}



- (IBAction)backToMenu:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WIPViewController"];
    
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    [self presentViewController:vc
                       animated:YES completion:nil];

}

- (IBAction) selectPlayerSetup:(id)sender {
    UIButton *button = (UIButton *)sender;

    if(spielAktiv&&tableView.hidden&&nextBtn.hidden){
        
        [self nextPlayer:button.tag];
        
    }
    
    else if (!spielAktiv&&tableView.hidden){
        
        [self initiateNewGame];
        [[self tableView] reloadData];

    anzahlPlayer = button.tag;
        
    spieler1Lbl.transform = CGAffineTransformRotate(spieler1Lbl.transform,  M_PI *.75);
    spieler2Lbl.transform = CGAffineTransformRotate(spieler2Lbl.transform,  -M_PI *.25);
    spieler3Lbl.transform = CGAffineTransformRotate(spieler3Lbl.transform,  M_PI *.25);
    spieler4Lbl.transform = CGAffineTransformRotate(spieler4Lbl.transform,  -M_PI *.75);
    
    if(anzahlPlayer==1)
    {
        
       
        [UIView animateWithDuration:1 delay:0.0 options:curveValues[0]
                         animations:^{
                             glass1.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler1Btn.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass2.frame = CGRectMake(2000, glass2.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler2Btn.frame = CGRectMake(2000, spieler2Btn.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass3.frame = CGRectMake(-2000, spieler3.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler3Btn.frame = CGRectMake(-2000, spieler3Btn.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass4.frame = CGRectMake(2000, glass4.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler4Btn.frame = CGRectMake(2000, glass4.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             
                             glass1.transform = CGAffineTransformRotate(glass1.transform, M_PI *.75);                 
                             spieler1Btn.transform = CGAffineTransformRotate(spieler1Btn.transform,  M_PI *.75);
                             
                         }completion:^(BOOL finished) {
                             spieler1Lbl.hidden = FALSE;
                             
                         }];
                    
        spieler2Btn.userInteractionEnabled = FALSE;
        spieler3Btn.userInteractionEnabled = FALSE;
        spieler4Btn.userInteractionEnabled = FALSE;
         
    }
    if(anzahlPlayer==2)
    {
        
        [UIView animateWithDuration:1 delay:0.0 options:curveValues[0]
                         animations:^{
                             glass1.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler1Btn.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass2.frame = CGRectMake(spieler2.frame.origin.x, spieler2.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler2Btn.frame = CGRectMake(spieler2.frame.origin.x, spieler2.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass3.frame = CGRectMake(-2000, spieler3.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler3Btn.frame = CGRectMake(-2000, spieler3Btn.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass4.frame = CGRectMake(2000, glass4.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler4Btn.frame = CGRectMake(2000, glass4.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             
                             glass1.transform = CGAffineTransformRotate(glass1.transform, M_PI *.75);
                             spieler1Btn.transform = CGAffineTransformRotate(spieler1Btn.transform,  M_PI *.75);
                             
                             glass2.transform = CGAffineTransformRotate(glass2.transform, -M_PI *.25);
                             spieler2Btn.transform = CGAffineTransformRotate(spieler2Btn.transform,  -M_PI *.25);
                         }completion:^(BOOL finished) {
                             spieler1Lbl.hidden = FALSE;
                             spieler2Lbl.hidden = FALSE;

                         }];

        spieler3Btn.userInteractionEnabled = FALSE;
        spieler4Btn.userInteractionEnabled = FALSE;


    }
    if(anzahlPlayer==3)
    {
        
        [UIView animateWithDuration:1 delay:0.0 options:curveValues[0]
                         animations:^{
                             glass1.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler1Btn.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass2.frame = CGRectMake(spieler2.frame.origin.x, spieler2.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler2Btn.frame = CGRectMake(spieler2.frame.origin.x, spieler2.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass3.frame = CGRectMake(spieler3.frame.origin.x, spieler3.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler3Btn.frame = CGRectMake(spieler3.frame.origin.x, spieler3.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass4.frame = CGRectMake(2000, glass4.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler4Btn.frame = CGRectMake(2000, glass4.center.y, glass1.frame.size.width, glass1.frame.size.height);
                             
                             glass1.transform = CGAffineTransformRotate(glass1.transform, M_PI *.75);
                             spieler1Btn.transform = CGAffineTransformRotate(spieler1Btn.transform,  M_PI *.75);
                             
                             glass2.transform = CGAffineTransformRotate(glass2.transform, -M_PI *.25);
                             spieler2Btn.transform = CGAffineTransformRotate(spieler2Btn.transform,  -M_PI *.25);
                             
                             glass3.transform = CGAffineTransformRotate(glass3.transform, M_PI *.25);
                             spieler3Btn.transform = CGAffineTransformRotate(spieler3Btn.transform,  M_PI *.25);
                             
                             
                         }completion:^(BOOL finished) {
                             spieler1Lbl.hidden = FALSE;
                             spieler2Lbl.hidden = FALSE;
                             spieler3Lbl.hidden = FALSE;

                             
                         }];

        spieler4Btn.userInteractionEnabled = FALSE;
        
    }
    if(anzahlPlayer==4)
    {
        
        [UIView animateWithDuration:1 delay:0.0 options:curveValues[0]
                         animations:^{
                             glass1.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler1Btn.frame = CGRectMake(spieler1.frame.origin.x, spieler1.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass2.frame = CGRectMake(spieler2.frame.origin.x, spieler2.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler2Btn.frame = CGRectMake(spieler2.frame.origin.x, spieler2.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass3.frame = CGRectMake(spieler3.frame.origin.x, spieler3.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler3Btn.frame = CGRectMake(spieler3.frame.origin.x, spieler3.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             glass4.frame = CGRectMake(spieler4.frame.origin.x, spieler4.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             spieler4Btn.frame = CGRectMake(spieler4.frame.origin.x, spieler4.frame.origin.y, glass1.frame.size.width, glass1.frame.size.height);
                             
                             glass1.transform = CGAffineTransformRotate(glass1.transform, M_PI *.75);
                             spieler1Btn.transform = CGAffineTransformRotate(spieler1Btn.transform,  M_PI *.75);
                             
                             glass2.transform = CGAffineTransformRotate(glass2.transform, -M_PI *.25);
                             spieler2Btn.transform = CGAffineTransformRotate(spieler3Btn.transform,  -M_PI *.25);
                             
                             glass3.transform = CGAffineTransformRotate(glass3.transform, M_PI *.25);
                             spieler3Btn.transform = CGAffineTransformRotate(spieler3Btn.transform,  M_PI *.25);
                             
                             glass4.transform = CGAffineTransformRotate(glass4.transform, -M_PI *.75);
                             spieler4Btn.transform = CGAffineTransformRotate(spieler4Btn.transform,  -M_PI *.75);
                         }completion:^(BOOL finished) {
                             spieler1Lbl.hidden = FALSE;
                             spieler2Lbl.hidden = FALSE;
                             spieler3Lbl.hidden = FALSE;
                             spieler4Lbl.hidden = FALSE;
        
                             
                         }];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3];
    [UIView commitAnimations];
    
    
    mWIPGameController = [[WIPGameController alloc]init];
    
   // spielerName.hidden = FALSE;
    cameraBtn.hidden = false;
    menuLabel.text = @"Spieler 1";
    spielerName.placeholder =  @"Spieler 1";
        
        locationLblTop.text = @"Wähle deine Mitspieler!";
        locationLblBot.text = @"Wähle deine Mitspieler!";
    
    [self pulsateUIImageView:self.glass1];

    currentPlayer = 1;

    tableView.hidden = false;
        
        }
}



- (void)spielerNameSelected:(NSString*)spielerNameValue: (NSString*)spielerFbId{
    
    UIImageView * glass = nil;
    UIImageView * playerBubble = nil;
    
    
    NSURL* file = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"bu" ofType:@"mp3"]];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    [audioPlayer prepareToPlay];
    
    [audioPlayer play];

 
    [mWIPGameController insertPlayer:spielerNameValue withId:[NSNumber numberWithDouble:currentPlayer] :spielerFbId];
    
    
    spielerName.placeholder = [NSString stringWithFormat:@"Spieler %.0f", currentPlayer+1];
    spielerName.text = @"";
    
    menuLabel.text = [NSString stringWithFormat:@"Spieler %.0f", currentPlayer+1];

    currentPlayer = currentPlayer+1;
//spieler1Lbl.text = spielerNameValue;
    if (currentPlayer==2) {
        [self stopPulsateUIImageView:self.glass1];
        glass = glass1;
        playerBubble = spieler1BubbleImg;
        spieler1Lbl.text = @"";
        [self.spieler1Btn setTitle:@"0" forState:UIControlStateNormal];
        

        
        [self pulsateUIImageView:self.glass2];
    }
    else if (currentPlayer==3) {
        [self stopPulsateUIImageView:self.glass2];
        glass = glass2;
        playerBubble = spieler2BubbleImg;
        spieler2Lbl.text = @"";
        [self.spieler2Btn setTitle:@"0" forState:UIControlStateNormal];
        [self pulsateUIImageView:self.glass3];    }
    
    else if (currentPlayer==4) {
        [self stopPulsateUIImageView:self.glass3];
        glass = glass3;
        playerBubble = spieler3BubbleImg;
        spieler3Lbl.text = @"";
        [self.spieler3Btn setTitle:@"0" forState:UIControlStateNormal];
        [self pulsateUIImageView:self.glass4];    }
    
    
    else if (currentPlayer==5) {
        [self stopPulsateUIImageView:self.glass4];
        glass = glass4;
        playerBubble = spieler4BubbleImg;
        spieler4Lbl.text = @"";
        [self.spieler4Btn setTitle:@"0" forState:UIControlStateNormal];
    }
    

    if (currentPlayer==anzahlPlayer+1) {
       [self startGame];
        tableView.hidden = true;
    }
    else{
        
        // [spielerNameField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];

    }
    
    
    
    
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSFileManager *m    = [NSFileManager defaultManager];
    NSString *imagePath = nil;
    if (spielerFbId!=nil) {
        imagePath = [NSString stringWithFormat:@"%@/%@.png",documentsDirectory,spielerFbId];
    }
    else {
        imagePath = [NSString stringWithFormat:@"%@/%@.png",documentsDirectory,spielerNameValue];
    }

    if ([m fileExistsAtPath:imagePath]){
        glass.image  =  [[UIImage alloc] initWithContentsOfFile:imagePath];
        playerBubble.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
       
    }
    else{
        glass.image  =  [UIImage imageNamed:@"Unbenannt-1.png"];
        playerBubble.image = [UIImage imageNamed:@"Unbenannt-1.png"];
    }
        
    
    glass.layer.cornerRadius  = 75.0;
    glass.layer.masksToBounds = YES;
    playerBubble.layer.cornerRadius  = 50.0;
    playerBubble.layer.masksToBounds = YES;
    glass.image = [self imageWithColor:glass.image withAColor:[UIColor whiteColor]];

}

- (void)startGame {
    
     
    mWIPGameController = [[WIPGameController alloc]init];
    [mWIPGameController newGame:anzahlPlayer];
    
    
    imageWheel = [[ANImageWheel alloc] initWithFrame:CGRectMake(0, 0, kompassScheibeHeight, kompassScheibeWidth)];
    [imageWheel setImage:[UIImage imageNamed:@"bottlenormal.png"]];
    [imageWheel startAnimating:self];
    [imageWheel setDrag:1];
    
    [kompassScheibeImg addSubview:imageWheel];
    
    
    menuLabel.hidden = TRUE;
   // spielerName.hidden = TRUE;
    cameraBtn.hidden = TRUE;
        
        spielAktiv = true;
        startPlayer = 1;
        
        [self nextRound];
        NSLog(@"globalHeading %f", globalHeading);
        
}

- (void)showQuestionToAll{
    
    
    NSURL* fileQuestio = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"questio" ofType:@"mp3"]];
    
    audioPlayerQuestio = [[AVAudioPlayer alloc] initWithContentsOfURL:fileQuestio  error:nil];
    
    [audioPlayerQuestio prepareToPlay];
    
    [audioPlayerQuestio play];
    
    imageWheel.hidden = TRUE;
    spinningLblBackr.hidden = FALSE;
    spinningLblBackr2.hidden = FALSE;

  
     

    [UIView animateWithDuration:10 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        spinningLblBackr.transform  = CGAffineTransformScale(spinningLblBackr.transform , 1.01, 1.01);
                       spinningLblBackr2.transform  = CGAffineTransformScale(spinningLblBackr2.transform , 1.01, 1.01);
                         
                     }completion:^(BOOL finished) {
                         if (finished)
    {
        spinningLblBackr.hidden = TRUE;
        spinningLblBackr2.hidden = TRUE;
        spinningLblBackr2.transform  = CGAffineTransformScale(spinningLblBackr2.transform , 1/1.01, 1/1.01);
        spinningLblBackr.transform  = CGAffineTransformScale(spinningLblBackr.transform , 1/1.01, 1/1.01);
        [self showBottleToAll];

    }
                        
                         
    }];
    
    
    
}

- (void)showAuswertungToAll{
    
    auswertungView.hidden = false;
    
    zeiger.hidden  = false;
    
     //locationLblTop.text = @"";
     //locationLblBot.text = @"";

    
    NSURL* fileWin = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"win" ofType:@"mp3"]];
    
    audioPlayerWin = [[AVAudioPlayer alloc] initWithContentsOfURL:fileWin error:nil];
   

    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animScale setFromValue:[NSNumber numberWithFloat:1]];
    [animScale setToValue:[NSNumber numberWithFloat:.000000001]];
    
    [animScale setAutoreverses:NO];
    [animScale setDuration:2];
    animScale.repeatCount = NO;
    animScale.fillMode = kCAFillModeForwards;
    animScale.removedOnCompletion = FALSE;
    
    [imageWheel.layer addAnimation:animScale forKey:@"grow"];
    
    CABasicAnimation *animRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animRotate setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animRotate setToValue:[NSNumber numberWithFloat:6*M_PI]];
    
    [animRotate setAutoreverses:NO];
    [animRotate setDuration:2];
    animRotate.repeatCount = NO;
    animRotate.fillMode = kCAFillModeForwards;
    animRotate.cumulative=true;
    animRotate.removedOnCompletion = FALSE;
    [imageWheel.layer addAnimation:animRotate forKey:@"rotate"];
    
    
    
    
    
    CABasicAnimation *animScale1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animScale1 setFromValue:[NSNumber numberWithFloat:.000001]];
    [animScale1 setToValue:[NSNumber numberWithFloat:1]];
    
    [animScale1 setAutoreverses:NO];
    [animScale1 setDuration:2];
    animScale1.repeatCount = NO;
    animScale1.fillMode = kCAFillModeForwards;
    
    [zeiger.layer addAnimation:animScale1 forKey:@"grow"];
    
    CABasicAnimation *animRotate1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animRotate1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    if (globalLocationHeading>=90){
        [animRotate1 setToValue:[NSNumber numberWithFloat:10*M_PI+(M_PI / 180 * (globalLocationHeading-90))]];
    }
    else{
        [animRotate1 setToValue:[NSNumber numberWithFloat:10*M_PI+(M_PI / 180 * (360-globalLocationHeading))]];
    }
    
    
    [animRotate1 setAutoreverses:NO];
    [animRotate1 setDuration:6];
    animRotate1.repeatCount = NO;
    animRotate1.fillMode = kCAFillModeForwards;
    animRotate1.cumulative=true;
    animRotate1.removedOnCompletion = FALSE;
    [zeiger.layer addAnimation:animRotate1 forKey:@"rotate"];
    
    spieler1Bubble.hidden = false;
    spieler2Bubble.hidden = false;
    spieler3Bubble.hidden = false;
    spieler4Bubble.hidden = false;

    [NSTimer scheduledTimerWithTimeInterval: 6.0 target: self selector:@selector(onTick:) userInfo: nil repeats:NO];
    
    [audioPlayerWin prepareToPlay];
    
    [audioPlayerWin play];
    
    
   

    
}

-(void)onTick:(NSTimer *)timer {
    
    nextBtn.hidden = false;
    
    [self pulsateSimpleUIImageView:nextBtn.imageView];
    
    
    mWIPGameController = [[WIPGameController alloc]init];
    
    NSArray *liste = [mWIPGameController calculateWinner:globalLocationHeading: startPlayer];
    
    int i = 1;
    NSString *name = nil;
    double playerid = 1;
    NSString *distance = nil;
    UIImage *img = nil;
    
    i = 0;
    
    
    //// SELECT KREIS IMG
    
    for (NSDictionary *listeneintrag in liste)
    {
    i++;
        if (i==1) {
            img = [UIImage imageNamed:@"badge1.png"];
        }
        else if (i-anzahlPlayer==0)
        {
            img = [UIImage imageNamed:@"badge4.png"];
        }
        else
        {
          img = nil;   
        }
               
        
        
        
        name = [listeneintrag valueForKey:@"name"];
        distance = [listeneintrag valueForKey:@"distance"];
        playerid = [[listeneintrag valueForKey:@"id"] doubleValue];
        double dis = [distance doubleValue];

   
        
        
        if (playerid==1) {
            if (i==1){
                [self pulsateUIImageView:spieler1BubbleImg];
                [self pulsateUIImageView:glass1];
                [self pulsateUIImageView:player1AuswertungImg];
            }
            
            player1Auswertung.text = [NSString stringWithFormat:@"- %.0f°",dis];
            player1Auswertung.hidden = false;
            player1AuswertungImg.hidden = false;
             player1AuswertungImg.image = img;
            double points = [spieler1Btn.titleLabel.text doubleValue];
            
            points = points + (-(i-anzahlPlayer));
            
            NSString *title = [NSString stringWithFormat:@"%.0f",points];
            
            [spieler1Btn setTitle:title forState:UIControlStateNormal];
        }
        
        if (playerid==2) {
            if (i==1){
                [self pulsateUIImageView:spieler2BubbleImg];
                [self pulsateUIImageView:glass2];
                [self pulsateUIImageView:player2AuswertungImg];
            }
            
            player2Auswertung.text = [NSString stringWithFormat:@"- %.0f°",dis];
            player2Auswertung.hidden = false;
            player2AuswertungImg.hidden = false;
            player2AuswertungImg.image = img;
            double points = [spieler2Btn.titleLabel.text doubleValue];
            
            points = points + (-(i-anzahlPlayer));
            
            NSString *title = [NSString stringWithFormat:@"%.0f",points];
            
            [spieler2Btn setTitle:title forState:UIControlStateNormal];
        }
        
        if (playerid==3) {
            if (i==1){
                [self pulsateUIImageView:spieler3BubbleImg];
                [self pulsateUIImageView:glass3];
                [self pulsateUIImageView:player3AuswertungImg];
            }
            
            player3Auswertung.text = [NSString stringWithFormat:@"- %.0f°",dis];
            player3Auswertung.hidden = false;
            player3AuswertungImg.hidden = false;
             player3AuswertungImg.image = img;
            double points = [spieler3Btn.titleLabel.text doubleValue];
            
            points = points + (-(i-anzahlPlayer));
            
            NSString *title = [NSString stringWithFormat:@"%.0f",points];
            
            [spieler3Btn setTitle:title forState:UIControlStateNormal];

        }
        
        if (playerid==4) {
            if (i==1){
                [self pulsateUIImageView:spieler4BubbleImg];
                [self pulsateUIImageView:glass4];
                [self pulsateUIImageView:player4AuswertungImg];
            }
            player4Auswertung.text = [NSString stringWithFormat:@"- %.0f°",dis];
            player4Auswertung.hidden = false;
            player4AuswertungImg.hidden = false;
            player4AuswertungImg.image = img;
            double points = [spieler4Btn.titleLabel.text doubleValue];
            
            points = points + (-(i-anzahlPlayer));
            
            NSString *title = [NSString stringWithFormat:@"%.0f",points];
            
            [spieler4Btn setTitle:title forState:UIControlStateNormal];
        }
        
              
       
     
    
   }
    
}


- (void)showBottleToAll{
    
    imageWheel.hidden = FALSE;
    
    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animScale setFromValue:[NSNumber numberWithFloat:.01]];
    [animScale setToValue:[NSNumber numberWithFloat:1]];
    
    [animScale setAutoreverses:NO];
    [animScale setDuration:2];
    animScale.repeatCount = NO;
    animScale.fillMode = kCAFillModeForwards;
    
    [imageWheel.layer addAnimation:animScale forKey:@"grow"];
    
    CABasicAnimation *animRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animRotate setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animRotate setToValue:[NSNumber numberWithFloat:-10*M_PI+(M_PI/180*globalHeading)]];
    
    [animRotate setAutoreverses:NO];
    [animRotate setDuration:2];
    animRotate.repeatCount = NO;
    animRotate.fillMode = kCAFillModeForwards;
    animRotate.cumulative=true;
    animRotate.removedOnCompletion = FALSE;
    [imageWheel.layer addAnimation:animRotate forKey:@"rotate"];
    
    bottleHeading = M_PI / 180 * globalHeading;


}

- (void)selectLocation{
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    locationAktiv = [mWIPLocations selectLocation:startPlayer];
    
    float angle = [mWIPDirection performDirectionCalculation:locationAktiv withMyPosition:globalPosition];
    NSLog(@"angle %f",angle);
    float distance = [mWIPDirection performDistanceCalculation:locationAktiv withMyPosition:globalPosition];
    NSLog(@"distance %f",distance);
    
    
    float angleLow = angle - 5;
    float angleHigh = angle + 5;
    float distanceLow = distance * 0.9;
    float distanceHigh = distance * 1.1;
    
    
    NSMutableArray *questionsAsked = [[NSMutableArray alloc] init];
    
    
    
    NSArray *rangeAngle = [NSArray arrayWithObjects: [NSExpression expressionForConstantValue:[NSNumber numberWithFloat:angleLow]], [NSExpression expressionForConstantValue:[NSNumber numberWithFloat:angleHigh]], nil];
    NSArray *rangeDistance = [NSArray arrayWithObjects: [NSExpression expressionForConstantValue:[NSNumber numberWithFloat:distanceLow]], [NSExpression expressionForConstantValue:[NSNumber numberWithFloat:distanceHigh]], nil];
    
    
    NSPredicate *query_questionsAsked = [NSPredicate predicateWithFormat: @"distance BETWEEN %@ AND angle BETWEEN %@", rangeDistance, rangeAngle];
    
    questionsAsked = [CoreDataHelper searchObjectsForEntity:@"QuestionAsked" withPredicate:query_questionsAsked andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    NSLog(@"questionsAsked.count %d",questionsAsked.count);
    
    
    if(questionsAsked.count==0){
        QuestionAsked *questionAsked = [NSEntityDescription insertNewObjectForEntityForName:@"QuestionAsked" inManagedObjectContext:mainDelegate.managedObjectContext];
        
        
        questionAsked.distance = [NSNumber numberWithFloat:distance];
        questionAsked.angle = [NSNumber numberWithFloat:angle];
        
        [mainDelegate.managedObjectContext save:nil];
        
        NSLog(@"GEWÄHLTE FRAGE %@", locationAktiv.place_name);
        NSLog(@"GEWÄHLTE FRAGE DISTANCE %@ ANGLE %@", questionAsked.distance, questionAsked.angle);
        
        
    }
    else{
        
         NSLog(@"ORT LIEGT ZU NAH  %@", locationAktiv.place_name);
   
        NSLog(@"ORT LIEGT ZU NAH DISTANCE %f ANGLE %f", distance, angle);
        
        [self selectLocation];

    }
    
    
}




- (void)nextRound{
    
    countPlayer = 1;
    

    mWIPDirection  = [[WIPDirection alloc]init];
    mWIPLocations  = [[WIPLocations alloc]init];
    
    [self selectLocation];
    
    NSString * frageString = @"";
    NSString * frageShortString = @"";
    NSString * person = @"";
   int tagi = 0;

  //  qu_unten_am,qu_unten_amVALIE,qu_unten_bei,qu_unten_beiVALIE,qu_unten_in,qu_unten_inVALIE,qu_unten_mit,qu_unten_mitVALIE,qu_unten_war,qu_unten_warVALIE;
    person = locationAktiv.person_name;
  
    qu_unten_warVALIE.text = person;
    qu_oben_warVALIE.text = person;
    
    if ([locationAktiv.tags count]>0) {
        qu_unten_mitVALIE.text = @"";
        qu_unten_mit.hidden = false;
        qu_unten_mitVALIE.hidden = false;
        qu_oben_mitVALIE.text = @"";
        qu_oben_mit.hidden = false;
        qu_oben_mitVALIE.hidden = false;
        
        int i = 0;
        for (Tags* tag in locationAktiv.tags)
        {
        i++;
        
            if (![person isEqualToString:tag.name]&&tag.name!=nil) {
            qu_unten_mitVALIE.text = [qu_unten_mitVALIE.text stringByAppendingString:tag.name];
            qu_oben_mitVALIE.text = [qu_oben_mitVALIE.text stringByAppendingString:tag.name];
             }
            else{tagi=1;}
                
             if (i!=locationAktiv.tags.count && ![person isEqualToString:tag.name]) {
                 qu_unten_mitVALIE.text = [qu_unten_mitVALIE.text stringByAppendingString:@", "];
                 qu_oben_mitVALIE.text = [qu_oben_mitVALIE.text stringByAppendingString:@", "];
             }
        }
            
    }else if ((tagi==1&&locationAktiv.tags.count==1) || locationAktiv.tags.count==0){qu_unten_mit.hidden = true;qu_unten_mitVALIE.hidden = true;qu_oben_mit.hidden = true;qu_oben_mitVALIE.hidden = true;}

    if (locationAktiv.place_name!=nil) {
        qu_unten_beiVALIE.text = @"";
        qu_unten_bei.hidden = false;
        qu_unten_beiVALIE.hidden = false;
        qu_unten_beiVALIE.text = locationAktiv.place_name;
        qu_oben_beiVALIE.text = @"";
        qu_oben_bei.hidden = false;
        qu_oben_beiVALIE.hidden = false;
        qu_oben_beiVALIE.text = locationAktiv.place_name;

        locationLblTop.text = locationAktiv.place_name;
        locationLblBot.text = locationAktiv.place_name;
    }else{qu_unten_bei.hidden = true;qu_unten_beiVALIE.hidden = true;qu_oben_bei.hidden = true;qu_oben_beiVALIE.hidden = true;}
    
    if (locationAktiv.place_location_city!=nil) {
        qu_unten_inVALIE.text = @"";
        qu_unten_in.hidden = false;
        qu_unten_inVALIE.hidden = false;
        qu_unten_inVALIE.text = locationAktiv.place_location_city;
        qu_oben_inVALIE.text = @"";
        qu_oben_in.hidden = false;
        qu_oben_inVALIE.hidden = false;
        qu_oben_inVALIE.text = locationAktiv.place_location_city;

        locationLblTop.text = [locationLblTop.text stringByAppendingString:@" - "];
        locationLblBot.text = [locationLblBot.text stringByAppendingString:@" - "];
        locationLblTop.text = [locationLblTop.text stringByAppendingString:locationAktiv.place_location_city];
        locationLblBot.text = [locationLblBot.text stringByAppendingString:locationAktiv.place_location_city];
    }else{qu_unten_in.hidden = true;qu_unten_inVALIE.hidden = true;qu_oben_in.hidden = true;qu_oben_inVALIE.hidden = true;}
    
    if (locationAktiv.place_location_street!=nil) {
        qu_unten_bei2VALIE.text = @"";
        qu_unten_bei2.hidden = false;
        qu_unten_bei2VALIE.hidden = false;
        qu_unten_bei2VALIE.text = locationAktiv.place_location_street;
        qu_oben_bei2VALIE.text = @"";
        qu_oben_bei2.hidden = false;
        qu_oben_bei2VALIE.hidden = false;
        qu_oben_bei2VALIE.text = locationAktiv.place_location_street;
    }else{qu_unten_bei2.hidden = true;qu_unten_bei2VALIE.hidden = true;qu_oben_bei2.hidden = true;qu_oben_bei2VALIE.hidden = true;}
    
    if (locationAktiv.created_time!=nil) {
   
        qu_unten_amVALIE.text = @"";
        qu_unten_am.hidden = false;
        qu_unten_amVALIE.hidden = false;
        qu_oben_amVALIE.text = @"";
        qu_oben_am.hidden = false;
        qu_oben_amVALIE.hidden = false;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        //2010-12-01T21:35:43+0000
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        NSDate *date = [df dateFromString:locationAktiv.created_time];
        [df setDateFormat:@"eeee, dd.MMMM.yyyy HH:mm"];
        NSString *dateStr = [df stringFromDate:date];
  
             qu_unten_amVALIE.text = dateStr;
        qu_oben_amVALIE.text = dateStr;

        
        
          }else{qu_unten_am.hidden = true;qu_unten_amVALIE.hidden = true;qu_oben_am.hidden = true;qu_oben_amVALIE.hidden = true;}

    [self showQuestionToAll];
   
    
    
    spinngLblBot.text = frageString;
    spinngLblTop.text = frageString;
    
    float angle = [mWIPDirection performDirectionCalculation:locationAktiv withMyPosition:globalPosition];
 

    globalLocationHeading = angle;
    zeiger.tag = angle;
    if (angle>=90){
        zeiger.transform = CGAffineTransformMakeRotation(M_PI / 180 * (angle-90));
    }
    else{
         zeiger.transform = CGAffineTransformMakeRotation(M_PI / 180 * (360-angle));
    }
 
    
    
    
    
    
    if(startPlayer<anzahlPlayer)
    {
        startPlayer++;
    }
    else
    {
        startPlayer = 1;
    }
    
    if (startPlayer==1) {
        [self pulsateUIImageView:self.glass1];
    }
    if (startPlayer==2) {
        [self pulsateUIImageView:self.glass2];
    }
    if (startPlayer==3) {
        [self pulsateUIImageView:self.glass3];
    }
    if (startPlayer==4) {
        [self pulsateUIImageView:self.glass4];
    }
    
    
   
    
    
    currentPlayer = startPlayer;
   
}

- (void)nextPlayer:(int) spielerNr {
    
    NSURL* file = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"bu" ofType:@"mp3"]];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    [audioPlayer prepareToPlay];
    
    double playerAngle = [imageWheel getAngle];
    
    
    
    double indicatorAngle;
    double trueHeading;
    
    if (playerAngle>=0) {
       
            trueHeading = 180 / (M_PI) * playerAngle;
            trueHeading = fmod(trueHeading, 360);
        
    }
    else{
        trueHeading = (180 / (M_PI) * (-playerAngle));
        trueHeading = fmod(trueHeading, 360);
    
    }
    
    if(playerAngle<0)
    {
        playerAngle = M_PI + M_PI + playerAngle;
    }
    
    
    indicatorAngle = bottleHeading + playerAngle - M_PI/2;
    
    indicatorAngle = fmod(indicatorAngle, (2*M_PI));


    if (indicatorAngle>=M_PI) {
        indicatorAngle = indicatorAngle - M_PI;
        indicatorAngle = -M_PI + indicatorAngle;
    }

    mWIPGameController = [[WIPGameController alloc]init];

    if (spielerNr == 1) {
        if (currentPlayer == 1) {
            [mWIPGameController saveAngle:currentPlayer :playerAngle: globalHeading];
            spieler1Bubble.transform = CGAffineTransformMakeRotation(indicatorAngle);
            if (anzahlPlayer>countPlayer) {
                currentPlayer = 2;
                countPlayer++;
                [imageWheel resetAngle: globalHeading];
                [self stopPulsateUIImageView:self.glass1];
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass3];
                [self pulsateUIImageView:self.glass2];
                [audioPlayer play];
            }
            else
            {
                [self stopPulsateUIImageView:self.glass1];
                [self finishRound];
            }
            
        }
        
    }
    if (spielerNr == 2) {
        if (currentPlayer == 2) {
            [mWIPGameController saveAngle:currentPlayer :playerAngle: globalHeading];
            spieler2Bubble.transform = CGAffineTransformMakeRotation(indicatorAngle);
            if (anzahlPlayer>countPlayer&&anzahlPlayer!=2) {
                currentPlayer = 3;
                countPlayer++;
                [imageWheel resetAngle: globalHeading];
                [self stopPulsateUIImageView:self.glass1];
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass2];
                [self pulsateUIImageView:self.glass3];
                [audioPlayer play];
            }
            else if (anzahlPlayer>countPlayer&&anzahlPlayer==2)
            {
                currentPlayer = 1;
                countPlayer++;
                [imageWheel resetAngle: globalHeading];
                [self stopPulsateUIImageView:self.glass3];
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass2];
                [self pulsateUIImageView:self.glass1];
                [audioPlayer play];
                
            }
            else
            {
                [self stopPulsateUIImageView:self.glass2];
                [self finishRound];
            }
            
        }
        
    }
    if (spielerNr == 3) {
        if (currentPlayer == 3) {
            [mWIPGameController saveAngle:currentPlayer :playerAngle: globalHeading];
            spieler3Bubble.transform = CGAffineTransformMakeRotation(indicatorAngle);
            if (anzahlPlayer>countPlayer&&anzahlPlayer!=3) {
                currentPlayer = 4;
                countPlayer++;
                [imageWheel resetAngle: globalHeading];
                [self stopPulsateUIImageView:self.glass1];
                [self stopPulsateUIImageView:self.glass2];
                [self stopPulsateUIImageView:self.glass3];
                [self pulsateUIImageView:self.glass4];
                [audioPlayer play];
            }
            else if (anzahlPlayer>countPlayer&&anzahlPlayer==3)
            {
                currentPlayer = 1;
                countPlayer++;
                [imageWheel resetAngle: globalHeading];
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass2];
                [self stopPulsateUIImageView:self.glass3];
                [self pulsateUIImageView:self.glass1];
                [audioPlayer play];

                
            }
            else
            {
                [self stopPulsateUIImageView:self.glass3];
                [self finishRound];
            }
            
        }
        
    }
    if (spielerNr == 4) {
        if (currentPlayer == 4) {
            [mWIPGameController saveAngle:currentPlayer :playerAngle: globalHeading];
            spieler4Bubble.transform = CGAffineTransformMakeRotation(indicatorAngle);
            if (anzahlPlayer>countPlayer) {
                currentPlayer = 1;
                countPlayer++;
                [imageWheel resetAngle: globalHeading];
                [self stopPulsateUIImageView:self.glass2];
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass3];
                [self pulsateUIImageView:self.glass1];
                [audioPlayer play];
            }
            else
            {
                [self stopPulsateUIImageView:self.glass4];
                [self finishRound];
            }
            
        }
        
    }



  
}

- (void)finishRound
{
    NSLog(@"AUSWERTUNG");
    
     [self showAuswertungToAll];
    
    
}

    
- (void)pulsateSimpleUIImageView:(UIImageView*) view
{
    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animScale setFromValue:[NSNumber numberWithFloat:1]];
    [animScale setToValue:[NSNumber numberWithFloat:1.3]];
    
    [animScale setAutoreverses:YES];
    [animScale setDuration:0.3];
    animScale.repeatCount = HUGE_VALF;
    animScale.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:animScale forKey:@"grow"];
    
    
    CABasicAnimation* spinAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.rotation"];
    spinAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    spinAnimation.repeatCount = HUGE_VALF;
    [spinAnimation setDuration:5];
    [view.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
    
}


- (void)pulsateUIImageView:(UIImageView*) view
{
    
   /* CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [anim setFromValue:[NSNumber numberWithFloat:0.5]];
    [anim setToValue:[NSNumber numberWithFloat:1]];
    [anim setAutoreverses:YES];
    [anim setDuration:0.3];
    anim.repeatCount = HUGE_VALF;
    [view.layer addAnimation:anim forKey:@"flash"];
    */
    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animScale setFromValue:[NSNumber numberWithFloat:1]];
    [animScale setToValue:[NSNumber numberWithFloat:1.3]];
    
    [animScale setAutoreverses:YES];
    [animScale setDuration:0.3];
    animScale.repeatCount = HUGE_VALF;
    animScale.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:animScale forKey:@"grow"];
    
}

- (void)stopPulsateUIImageView:(UIImageView*) view
{
    [view.layer removeAllAnimations];
    
}



- (UIImage *)imageWithColor:(UIImage*) image withAColor: (UIColor *)color
{
    // load the image
    // NSString *name = view.image;
    UIImage *img = image;
    
    
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context,  kCGBlendModeNormal);
    
    CGContextSetAlpha(context, .8);
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];

    return [CoreDataHelper countForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
    
    
}

-(void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView1 cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    NSString *cellDetailedText = cell.detailTextLabel.text;


    if (cellText!=nil) {
        [self spielerNameSelected:cellText :cellDetailedText];
    }

    
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
      static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];

    NSMutableArray *friends = [CoreDataHelper getObjectsForEntity:@"Friends" withSortKey:@"name" andSortAscending:true andContext:mainDelegate.managedObjectContext];
    double count = [CoreDataHelper countForEntity:@"Friends" andContext:mainDelegate.managedObjectContext];
        

    if (count!=0) {
    
        cell.textLabel.text = [[friends objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.detailTextLabel.text = [[friends objectAtIndex:indexPath.row] valueForKey:@"friend_id"];
        cell.detailTextLabel.hidden =true;
                
    
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

        NSFileManager *m    = [NSFileManager defaultManager];
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@.png",documentsDirectory,[[friends objectAtIndex:indexPath.row] valueForKey:@"friend_id"]];
        
        if ([m fileExistsAtPath:imagePath])
            cell.imageView.image =  [[UIImage alloc] initWithContentsOfFile:imagePath];
        else
            cell.imageView.image = nil;  
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView1 willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView1 cellForRowAtIndexPath:indexPath];

    return indexPath;
   }

- (void) drawStringAtContext:(CGContextRef) context string:(NSString*) text atAngle:(float) angle withRadius:(float) radius
{
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:88.0f]];
    
    float perimeter = 2 * M_PI * radius;
    float textAngle = textSize.width / perimeter * 2 * M_PI;
    
    angle += textAngle / 2;
    
    for (int index = 0; index < [text length]; index++)
    {
        NSRange range = {index, 1};
        NSString* letter = [text substringWithRange:range];
        char* c = (char*)[letter cStringUsingEncoding:NSASCIIStringEncoding];
        CGSize charSize = [letter sizeWithFont:[UIFont systemFontOfSize:88.0f]];
        
        NSLog(@"Char %@ with size: %f x %f", letter, charSize.width, charSize.height);
        
        float x = radius * cos(angle);
        float y = radius * sin(angle);
        
        float letterAngle = (charSize.width / perimeter * -2 * M_PI);
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, x, y);
        CGContextRotateCTM(context, (angle - 0.5 * M_PI));
        CGContextShowTextAtPoint(context, 0, 0, c, strlen(c));
        CGContextRestoreGState(context);
        
        angle += letterAngle;
    }
}

- (UIImage*) createMenuRingWithFrame:(CGRect)frame
{
   NSSet *sections = [NSSet setWithObjects:@"1",@"2",@"3",@"4",@"5",nil];
    CGPoint centerPoint = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    char* fontName = (char*)[@"daadsasdasdas" cStringUsingEncoding:NSASCIIStringEncoding];
    
    CGFloat* ringColorComponents = (float*)CGColorGetComponents([[UIColor whiteColor] CGColor]);
    CGFloat* textColorComponents = (float*)CGColorGetComponents([[UIColor redColor] CGColor]);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, frame.size.width, frame.size.height, 8, 4 * frame.size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextSelectFont(context, fontName, 18, kCGEncodingMacRoman);
    CGContextSetRGBStrokeColor(context, ringColorComponents[0], ringColorComponents[1], ringColorComponents[2], 1);
    CGContextSetLineWidth(context, 20);
    
    CGContextStrokeEllipseInRect(context, CGRectMake(20, 20, frame.size.width - (20 * 2), frame.size.height - (20 * 2)));
    CGContextSetRGBFillColor(context, textColorComponents[0], textColorComponents[1], textColorComponents[2], 1);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, centerPoint.x, centerPoint.y);
    
    float angleStep = 2 * M_PI / [sections count];
    float angle = M_PI/2;
    
    //textRadius = 20 - 12;
    
    for (NSString* text in sections)
    {
        [self drawStringAtContext:context string:text atAngle:angle withRadius:8];
        angle -= angleStep;
    }
    
    CGContextRestoreGState(context);
    
    CGImageRef contextImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //[self saveImage:[UIImage imageWithCGImage:contextImage] withName:@"test.png"];
    return [UIImage imageWithCGImage:contextImage];
    
}



- (IBAction)naechsteRunde:(id)sender {
    
    auswertungView.hidden = true;
    zeiger.hidden = true;
    nextBtn.hidden = true;
    spieler1Bubble.hidden = true;
    spieler2Bubble.hidden = true;
    spieler3Bubble.hidden = true;
    spieler4Bubble.hidden = true;
    [self stopPulsateUIImageView:nextBtn.imageView];
    [self stopPulsateUIImageView:glass1];
    [self stopPulsateUIImageView:glass2];
    [self stopPulsateUIImageView:glass3];
    [self stopPulsateUIImageView:glass4];
    [self stopPulsateUIImageView:spieler1BubbleImg];
    [self stopPulsateUIImageView:spieler2BubbleImg];
    [self stopPulsateUIImageView:spieler3BubbleImg];
    [self stopPulsateUIImageView:spieler4BubbleImg];
    [self stopPulsateUIImageView:player1AuswertungImg];
    [self stopPulsateUIImageView:player2AuswertungImg];
    [self stopPulsateUIImageView:player3AuswertungImg];
    [self stopPulsateUIImageView:player4AuswertungImg];
     [self stopPulsateUIImageView:nextBtn.imageView];
    player1AuswertungImg.hidden = true;
    player2AuswertungImg.hidden = true;
    player3AuswertungImg.hidden = true;
    player4AuswertungImg.hidden = true;
    
    player1Auswertung.hidden = true;
    player2Auswertung.hidden = true;
    player3Auswertung.hidden = true;
    player4Auswertung.hidden = true;
    
    [self nextRound];
}
- (IBAction)showAuswertung:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                                         bundle:nil];
    UIViewController *viewController =
    [storyboard instantiateViewControllerWithIdentifier:@"results"];
    
    [viewController setModalPresentationStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)takePicture:(id)sender {

    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = TRUE;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {

    
        NSString *spielerNameValue = spielerName.text;
        
        if (spielerNameValue.length==0) {
            spielerNameValue = spielerName.placeholder;
        }
        
        
        UIImage* new = image;
        NSData *imageData = UIImagePNGRepresentation(new);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:spielerNameValue];
        documentsDirectory = [documentsDirectory stringByAppendingString:@".png"];
        
        [imageData writeToFile:documentsDirectory atomically:YES];

    [self spielerNameSelected:spielerNameValue :nil];

    
     }
    
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)doLogout:(id)sender {
    
    
    [mWIPFacebook openFBSession];
    [self initiateNewUser];
}
@end

