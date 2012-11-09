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

@interface WIPViewController ()


@end


static double kompassScheibeHeight, kompassScheibeWidth;
static double globalHeading;
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
@synthesize spinngLblTop, spinngLblBot, spinningLblBackr;

@synthesize spieler1Bubble, spieler2Bubble, spieler3Bubble,spieler4Bubble;
@synthesize spieler1BubbleImg, spieler2BubbleImg, spieler3BubbleImg, spieler4BubbleImg;
@synthesize auswertungLbl1, auswertungLbl2,auswertungLbl3,auswertungLbl4;
@synthesize auswertungView;
@synthesize player1Auswertung, player2Auswertung, player3Auswertung, player4Auswertung;
@synthesize player1AuswertungImg,player2AuswertungImg,player3AuswertungImg,player4AuswertungImg;
@synthesize nextBtn,cameraBtn;






//////////////

@synthesize  qu_unten_am,qu_unten_amVALIE,qu_unten_bei,qu_unten_beiVALIE,qu_unten_in,qu_unten_inVALIE,qu_unten_mit,qu_unten_mitVALIE,qu_unten_war,qu_unten_warVALIE;




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
    
    spielAktiv = false;
    spielerAktiv = 0;
    locationAktiv = nil;

    
    kompassScheibeHeight = kompassScheibeImg.frame.size.height;
    kompassScheibeWidth = kompassScheibeImg.frame.size.width;
   
    

    locationLblTop.transform = CGAffineTransformRotate(locationLblTop.transform,  M_PI);

    
       /// START LOCATION SERVICES
    
    
    CLController = [[WIPLocationController alloc] init];
	CLController.delegate = self;
    CLController.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    CLController.locMgr.headingFilter = 0;
	[CLController.locMgr startUpdatingLocation];
    [CLController.locMgr startUpdatingHeading];
    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];

    if (!([CoreDataHelper countForEntity:@"Friends" andContext:mainDelegate.managedObjectContext]>0)) {
        
        mWIPFacebook = [[WIPFacebook alloc] init];
        
        [mWIPFacebook getFacebookFriends:tableView];
        
         NSLog(@"GfETTING FRIENDS");
    }

    
    NSPredicate *predicate_asked = [NSPredicate predicateWithFormat:@"(asked == 1)"];
    
    NSMutableArray *questionArray = [CoreDataHelper searchObjectsForEntity:@"Question" withPredicate:predicate_asked andSortKey:nil andSortAscending:false andContext:mainDelegate.managedObjectContext];
    
    
    if (questionArray.count>0) {
        
        for (Question *asked_question in questionArray) {
            asked_question.asked = [[NSNumber alloc] initWithDouble:0];
            [mainDelegate.managedObjectContext save:nil];
        }
        
        NSLog(@"ASKED=1 ZURÜCKGESETZ %u", questionArray.count);
        
        
    }





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
           [UIView animateWithDuration:1.0 delay:0.0 options:0
                            animations:^{
                                kompassScheibe.transform = CGAffineTransformMakeRotation(M_PI / 180 * (-[heading trueHeading]));
                                                               
                               

                                
                            }
                            completion:nil];

    }
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

    if(spielAktiv){
        
        [self nextPlayer:button.tag];
        
    }
    
    else{
    
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
                             [self.spieler1Btn setTitle:@"" forState:UIControlStateNormal];
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
                             [self.spieler1Btn setTitle:@"" forState:UIControlStateNormal];
                             [self.spieler2Btn setTitle:@"" forState:UIControlStateNormal];
                         }];
        //spieler2Btn.userInteractionEnabled = FALSE;
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
                             [self.spieler1Btn setTitle:@"" forState:UIControlStateNormal];
                             [self.spieler2Btn setTitle:@"" forState:UIControlStateNormal];
                             [self.spieler3Btn setTitle:@"" forState:UIControlStateNormal];
                             
                         }];
        //spieler2Btn.userInteractionEnabled = FALSE;
        //spieler3Btn.userInteractionEnabled = FALSE;
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
                             [self.spieler1Btn setTitle:@"" forState:UIControlStateNormal];
                             [self.spieler2Btn setTitle:@"" forState:UIControlStateNormal];
                             [self.spieler3Btn setTitle:@"" forState:UIControlStateNormal];
                             [self.spieler4Btn setTitle:@"" forState:UIControlStateNormal];
                             
                         }];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3];
    [UIView commitAnimations];
    
    
    mWIPGameController = [[WIPGameController alloc]init];
    
   // spielerName.hidden = FALSE;
    menuLabel.text = @"Spieler 1";
    spielerName.placeholder =  @"Spieler 1";
    
    [self pulsateUIImageView:self.glass1];

    
    [mWIPGameController deletePlayer];
  
    currentPlayer = 1;
    //[spielerName becomeFirstResponder];
    tableView.hidden = false;
        
        }
}



- (void)spielerNameSelected:(NSString*)spielerNameValue: (NSString*)spielerFbId: (UIImage*) pictureBase64 {
    
    UIImageView * glass = nil;
    UIImageView * playerBubble = nil;
 
    [mWIPGameController insertPlayer:spielerNameValue withId:[NSNumber numberWithDouble:currentPlayer] :spielerFbId :pictureBase64];
    
    
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
        [self pulsateUIImageView:self.glass2];
    }
    else if (currentPlayer==3) {
        [self stopPulsateUIImageView:self.glass2];
        glass = glass2;
        playerBubble = spieler2BubbleImg;
        spieler2Lbl.text = @"";
        [self pulsateUIImageView:self.glass3];    }
    
    else if (currentPlayer==4) {
        [self stopPulsateUIImageView:self.glass3];
        glass = glass3;
        playerBubble = spieler3BubbleImg;
        spieler3Lbl.text = @"";
        [self pulsateUIImageView:self.glass4];    }
    
    
    else if (currentPlayer==5) {
        [self stopPulsateUIImageView:self.glass4];
        glass = glass4;
        playerBubble = spieler4BubbleImg;
        spieler4Lbl.text = @"";
    }
    

    if (currentPlayer==anzahlPlayer+1) {
       [self startGame];
        tableView.hidden = true;
    }
    else{
        
        // [spielerNameField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];

    }
    
    
    if(spielerFbId!=nil)
    {
    /////// LOAD IMAGE
    
    NSString *imageUrlString = @"http://graph.facebook.com/";
    imageUrlString = [imageUrlString stringByAppendingString:spielerFbId];
    imageUrlString = [imageUrlString stringByAppendingString:@"/picture?type=large"];
    
    NSURL *imageURL = [NSURL URLWithString: imageUrlString];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            
            UIImage* new = [UIImage imageWithData:imageData];
            
            glass.image = new;
            playerBubble.image = glass.image;
            glass.layer.cornerRadius  = 75.0;
            glass.layer.masksToBounds = YES;
            
            
            playerBubble.layer.cornerRadius  = 15.0;
            playerBubble.layer.masksToBounds = YES;

        });
    });
        
    }
    else if (pictureBase64!=nil)
    {
                
        UIImage* new = pictureBase64;

        glass.image =  pictureBase64;

        playerBubble.image = new;
        glass.layer.cornerRadius  = 75.0;
        glass.layer.masksToBounds = YES;
        
        
        playerBubble.layer.cornerRadius  = 15.0;
        playerBubble.layer.masksToBounds = YES;
    }
    

}

- (void)startGame {
    

    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    if (!([CoreDataHelper countForEntity:@"Question" andContext:mainDelegate.managedObjectContext]>0)) {
        mWIPFacebook = [[WIPFacebook alloc] init];
        [mWIPFacebook sendRequestToFacebook:nil];
        
     //   progressBar.hidden=FALSE;
     //   progressBar.progress=0.5;
        
        NSLog(@"GENERATING QUESTIONS, SPIEL KANN NICHT BEGINNEN!");

    }
    else{
        

        
    mWIPGameController = [[WIPGameController alloc]init];
    [mWIPGameController newGame:anzahlPlayer];
    
    
    imageWheel = [[ANImageWheel alloc] initWithFrame:CGRectMake(0, 0, kompassScheibeHeight, kompassScheibeWidth)];
    [imageWheel setImage:[UIImage imageNamed:@"jj1.png"]];
    [imageWheel startAnimating:self];
    [imageWheel setDrag:1];
        
    [kompassScheibeImg addSubview:imageWheel];
    
    
    menuLabel.hidden = TRUE;
    spielerName.hidden = TRUE;
    cameraBtn.hidden = TRUE;
        
        spielAktiv = true;
        startPlayer = 0;
        
        [self nextRound];
        NSLog(@"globalHeading %f", globalHeading);
    }
        
}

- (void)showQuestionToAll{
    
    
    NSURL* fileQuestio = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"questio" ofType:@"mp3"]];
    
    audioPlayerQuestio = [[AVAudioPlayer alloc] initWithContentsOfURL:fileQuestio  error:nil];
    
    [audioPlayerQuestio prepareToPlay];
    
    [audioPlayerQuestio play];
    
    imageWheel.hidden = TRUE;
    spinningLblBackr.hidden = FALSE;
    spinngLblTop.transform  = CGAffineTransformMakeRotation(M_PI);
  
     

    [UIView animateWithDuration:10 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         spinngLblTop.transform  = CGAffineTransformScale(spinngLblTop.transform , 1.2, 1.1);
                        spinngLblBot.transform  = CGAffineTransformScale(spinngLblBot.transform , 1.2, 1.1);
                         
                     }completion:^(BOOL finished) {
                         if (finished)
    {
        spinningLblBackr.hidden = TRUE;
        spinngLblTop.transform  = CGAffineTransformScale(spinngLblTop.transform , 1/1.2, 1/1.1);
        spinngLblBot.transform  = CGAffineTransformScale(spinngLblBot.transform , 1/1.2, 1/1.1);
        [self showBottleToAll];

    }
                        
                         
    }];
    
    
    
}

- (void)showAuswertungToAll{
    
     auswertungView.hidden = false;
    
    zeiger.hidden  = false;

    
    NSURL* fileWin = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"win" ofType:@"mp3"]];
    
    audioPlayerWin = [[AVAudioPlayer alloc] initWithContentsOfURL:fileWin error:nil];
   

    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animScale setFromValue:[NSNumber numberWithFloat:1]];
    [animScale setToValue:[NSNumber numberWithFloat:.000000001]];
    
    [animScale setAutoreverses:NO];
    [animScale setDuration:2];
    animScale.repeatCount = NO;
    animScale.fillMode = kCAFillModeForwards;
    animScale.removedOnCompletion = FALSE;
    
    [imageWheel.layer addAnimation:animScale forKey:@"grow"];
    
    CABasicAnimation *animRotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animRotate setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animRotate setToValue:[NSNumber numberWithFloat:3*M_PI]];
    
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
        [animRotate1 setToValue:[NSNumber numberWithFloat:-12*M_PI+(M_PI / 180 * (globalLocationHeading-90))]];
    }
    else{
        [animRotate1 setToValue:[NSNumber numberWithFloat:-12*M_PI+(M_PI / 180 * (360-globalLocationHeading))]];
    }
    
    
    [animRotate1 setAutoreverses:NO];
    [animRotate1 setDuration:8];
    animRotate1.repeatCount = NO;
    animRotate1.fillMode = kCAFillModeForwards;
    animRotate1.cumulative=true;
    animRotate1.removedOnCompletion = FALSE;
    [zeiger.layer addAnimation:animRotate1 forKey:@"rotate"];
    
    spieler1Bubble.hidden = false;
    spieler2Bubble.hidden = false;
    spieler3Bubble.hidden = false;
    spieler4Bubble.hidden = false;

    [NSTimer scheduledTimerWithTimeInterval: 8.0 target: self selector:@selector(onTick:) userInfo: nil repeats:NO];
    
    [audioPlayerWin prepareToPlay];
    
    [audioPlayerWin play];
    
    
   

    
}

-(void)onTick:(NSTimer *)timer {
    
    nextBtn.hidden = false;
    
    [self pulsateUIImageView:nextBtn.imageView];
    
    
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
        }
        
      
                
        if (playerid==1) {
            player1AuswertungImg.image = img;
                   }
        if (playerid==2) {
            player2AuswertungImg.image = img;
                   }
        if (playerid==3) {{
            player3AuswertungImg.image = img;
                    }
        if (playerid==4) {
            player4AuswertungImg.image = img;
                   }
        
        
        
        
       
        
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

}





- (void)nextRound{
    
    countPlayer = 1;
    

    mWIPDirection  = [[WIPDirection alloc]init];
    mWIPLocations  = [[WIPLocations alloc]init];
    
    
    locationAktiv = [mWIPLocations selectLocation:startPlayer];
    
    NSString * frageString = @"";
    NSString * frageShortString = @"";
    NSString * person = @"";
   int tagi = 0;

  //  qu_unten_am,qu_unten_amVALIE,qu_unten_bei,qu_unten_beiVALIE,qu_unten_in,qu_unten_inVALIE,qu_unten_mit,qu_unten_mitVALIE,qu_unten_war,qu_unten_warVALIE;
    
  
    qu_unten_warVALIE.text = locationAktiv.person_name;
    
    if ([locationAktiv.tags count]>0) {
        qu_unten_mitVALIE.text = @"";
        qu_unten_mit.hidden = false;
        qu_unten_mitVALIE.hidden = false;
        
        int i = 0;
        for (Tags* tag in locationAktiv.tags)
        {
        i++;
            if (![person isEqualToString:tag.name]&&tag.name!=nil) {
            qu_unten_mitVALIE.text = [qu_unten_mitVALIE.text stringByAppendingString:tag.name];
             }
            else{tagi=1;}
                
             if (i!=locationAktiv.tags.count && ![person isEqualToString:tag.name]) {
                 qu_unten_mitVALIE.text = [qu_unten_mitVALIE.text stringByAppendingString:@" | "];
             }    
        }
            
    }else if ((tagi==1&&locationAktiv.tags.count==1) || locationAktiv.tags.count==0){qu_unten_mit.hidden = true;qu_unten_mitVALIE.hidden = true;}
    
    if (locationAktiv.place_name!=nil) {
        qu_unten_mitVALIE.text = @"";
        qu_unten_bei.hidden = false;
        qu_unten_beiVALIE.hidden = false;
        qu_unten_beiVALIE.text = locationAktiv.place_name;
    }else{qu_unten_bei.hidden = true;qu_unten_beiVALIE.hidden = true;}
    
    if (locationAktiv.place_location_city!=nil||locationAktiv.place_location_street!=nil) {
        qu_unten_inVALIE.text = @"";
        qu_unten_in.hidden = false;
        qu_unten_inVALIE.hidden = false;
        qu_unten_inVALIE.text = locationAktiv.place_location_city;
        if (locationAktiv.place_location_street!=nil) {
            qu_unten_inVALIE.text = [qu_unten_inVALIE.text stringByAppendingString:@" ("];
            qu_unten_inVALIE.text = [qu_unten_inVALIE.text stringByAppendingString:locationAktiv.place_location_street];
            qu_unten_inVALIE.text = [qu_unten_inVALIE.text stringByAppendingString:@")"];
        }
    }else{qu_unten_in.hidden = true;qu_unten_inVALIE.hidden = true;}
    
    if (locationAktiv.created_time!=nil) {
        qu_unten_amVALIE.text = @"";
        qu_unten_am.hidden = false;
        qu_unten_amVALIE.hidden = false;
        qu_unten_amVALIE.text = locationAktiv.created_time;
          }else{qu_unten_am.hidden = true;qu_unten_amVALIE.hidden = true;}

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

    
    mWIPGameController = [[WIPGameController alloc]init];

    if (spielerNr == 1) {
        if (currentPlayer == 1) {
            [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle:globalHeading]];
            spieler1Bubble.transform = CGAffineTransformMakeRotation([imageWheel getAngle:globalHeading]-(M_PI/2));
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
            [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle:globalHeading]];
            spieler2Bubble.transform = CGAffineTransformMakeRotation([imageWheel getAngle:globalHeading]-(M_PI/2));
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
            [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle:globalHeading]];
            spieler3Bubble.transform = CGAffineTransformMakeRotation([imageWheel getAngle:globalHeading]-(M_PI/2));
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
            [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle:globalHeading]];
            spieler4Bubble.transform = CGAffineTransformMakeRotation([imageWheel getAngle:globalHeading]-(M_PI/2));
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

    
 
    


- (void)pulsateUIImageView:(UIImageView*) view
{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [anim setFromValue:[NSNumber numberWithFloat:0.5]];
    [anim setToValue:[NSNumber numberWithFloat:1]];
    [anim setAutoreverses:YES];
    [anim setDuration:0.3];
    anim.repeatCount = HUGE_VALF;
    [view.layer addAnimation:anim forKey:@"flash"];
    
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



- (UIImage *)imageWithColor:(UIImageView*) view withAColor: (UIColor *)color
{
    // load the image
    // NSString *name = view.image;
    UIImage *img = view.image;
    
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
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
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
    
   // cell.userInteractionEnabled = FALSE;

    NSLog(@"tap %@",cellDetailedText );
    NSLog(@"tap %@",cellText );
    
    if (cellText!=nil) {
         [self spielerNameSelected:cellText :cellDetailedText:nil];
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
        cell.imageView.image = [[friends objectAtIndex:indexPath.row] valueForKey:@"pictureBase64"];
        
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
    
    [self spielerNameSelected:spielerNameValue :nil:image];
    
     }
    
    [self dismissModalViewControllerAnimated:YES];
}
@end

