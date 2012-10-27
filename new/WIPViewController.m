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

@interface WIPViewController ()


@end


static double kompassScheibeHeight, kompassScheibeWidth;
static double globalHeading;
static double anzahlPlayer, currentPlayer, startPlayer;
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


static int curveValues[] = {
    UIViewAnimationOptionCurveEaseInOut,
    UIViewAnimationOptionCurveEaseIn,
    UIViewAnimationOptionCurveEaseOut,
    UIViewAnimationOptionCurveLinear };



@synthesize container, startTransform, bottle, zeiger, kompassScheibe;
@synthesize locationLabel, gameMenu;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    spielAktiv = false;
    spielerAktiv = 0;
    locationAktiv = nil;

    
    kompassScheibeHeight = kompassScheibe.frame.size.height;
    kompassScheibeWidth = kompassScheibe.frame.size.width;
    
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
        
         NSLog(@"GGETTING FRIENDS");
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
        CLLocationCoordinate2D myPosition  = [location coordinate];        
        float angle = [mWIPDirection performDirectionCalculation:locationAktiv withMyPosition:myPosition];
        globalLocationHeading = angle;
        zeiger.tag = angle;
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
                                zeiger.transform = CGAffineTransformMakeRotation(M_PI / 180 * (-[heading trueHeading]-90+zeiger.tag));
                                
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
    
    spielerName.hidden = FALSE;
    menuLabel.text = @"Spieler 1";
    spielerName.placeholder =  @"Spieler 1";
    
    [self pulsateUIImageView:self.glass1];

    
    [mWIPGameController deletePlayer];
  
    currentPlayer = 1;
    //[spielerName becomeFirstResponder];
    tableView.hidden = false;
        
        }
}

- (IBAction)spielerNameEntered:(id)sender {
    
    UITextField *spielerNameField = (UITextField*) sender;
    NSString *spielerNameValue = spielerNameField.text;
    
    if (spielerNameValue.length==0) {
        spielerNameValue = spielerNameField.placeholder;
    }
    
    [self spielerNameSelected:spielerNameValue :nil];
   
    
}

- (void)spielerNameSelected:(NSString*)spielerNameValue: (NSString*)spielerFbId {
    
    UIImageView * glass = nil;
       
    [mWIPGameController insertPlayer:spielerNameValue withId:[NSNumber numberWithDouble:currentPlayer] :spielerFbId:nil];
    
    spielerName.placeholder = [NSString stringWithFormat:@"Spieler %.0f", currentPlayer+1];
    spielerName.text = @"";
    
    menuLabel.text = [NSString stringWithFormat:@"Spieler %.0f", currentPlayer+1];

    currentPlayer = currentPlayer+1;

    if (currentPlayer==2) {
        [self stopPulsateUIImageView:self.glass1];
        if(spielerFbId!=nil)
        {
          glass = glass1;
          spieler1Lbl.text = @"";
        }
        else{
            spieler1Lbl.text = spielerNameValue;
   
        }
        [self pulsateUIImageView:self.glass2];
    }
    
    else if (currentPlayer==3) {
        [self stopPulsateUIImageView:self.glass2];
        if(spielerFbId!=nil)
        {
            glass = glass2;
            spieler2Lbl.text = @"";
        }
        else{
            spieler2Lbl.text = spielerNameValue;
            
        }

        [self pulsateUIImageView:self.glass3];
       //  [spielerName becomeFirstResponder];
    }
    
    else if (currentPlayer==4) {
        [self stopPulsateUIImageView:self.glass3];
        if(spielerFbId!=nil)
        {
            glass = glass3;
            spieler3Lbl.text = @"";
        }
        else{
            spieler3Lbl.text = spielerNameValue;
            
        }

        [self pulsateUIImageView:self.glass4];
      //  [spielerName becomeFirstResponder];
    }
    
    
    else if (currentPlayer==5) {
        [self stopPulsateUIImageView:self.glass4];
        if(spielerFbId!=nil)
        {
            glass = glass4;
            spieler4Lbl.text = @"";
        }
        else{
            spieler4Lbl.text = spielerNameValue;
            
        }
    }
    
    
    if (currentPlayer==anzahlPlayer+1) {
        [self startGame];
        currentPlayer = 1;
        tableView.hidden = true;
    }
    else{
        
        // [spielerNameField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];

    }
    
    
    
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
            
            glass.image = [self mergeImage:glass.image withImage:new strength:1];
            glass.layer.cornerRadius  = 75.0;
           glass.layer.masksToBounds = YES;
            
           // kompassScheibe.image  = [self createMenuRingWithFrame:CGRectMake(0,0,480,480)];
            
            
            
        });
    });
    

}

- (void)startGame {
    

    
    WIPAppDelegate *mainDelegate = (WIPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    if (!([CoreDataHelper countForEntity:@"Question" andContext:mainDelegate.managedObjectContext]>0)) {
        mWIPFacebook = [[WIPFacebook alloc] init];
        [mWIPFacebook sendRequestToFacebook:@"me/friends?fields=name,locations"];
        
        progressBar.hidden=FALSE;
        progressBar.progress=0.5;
        
        NSLog(@"GENERATING QUESTIONS, SPIEL KANN NICHT BEGINNEN!");

    }
    else{
        
        
        
      
    
        
    mWIPGameController = [[WIPGameController alloc]init];
    [mWIPGameController newGame:anzahlPlayer];
    
    
    imageWheel = [[ANImageWheel alloc] initWithFrame:CGRectMake(0, 0, kompassScheibeHeight, kompassScheibeWidth)];
    [imageWheel setImage:[UIImage imageNamed:@"jj1.png"]];
    [imageWheel startAnimating:self];
    [imageWheel setDrag:.9];
    
    // first reduce the view to 1/100th of its original dimension

    [kompassScheibe addSubview:imageWheel];
    
    
    
    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animScale setFromValue:[NSNumber numberWithFloat:.01]];
    [animScale setToValue:[NSNumber numberWithFloat:1]];
    
    [animScale setAutoreverses:NO];
    [animScale setDuration:2];
    animScale.repeatCount = NO;
    animScale.fillMode = kCAFillModeForwards;
    [imageWheel.layer addAnimation:animScale forKey:@"grow"];
    
    NSLog(@"globalHeading %f", globalHeading);
    
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

    
    menuLabel.hidden = TRUE;
    spielerName.hidden = TRUE;
        
        spielAktiv = true;
        startPlayer = 1;
        
        [self nextRound];
        
    }
        
}

- (void)nextRound{
    
  
    
    mWIPDirection  = [[WIPDirection alloc]init];
    mWIPLocations  = [[WIPLocations alloc]init];
    
    
    locationAktiv = [mWIPLocations selectLocation:startPlayer];
    
    NSString * frageString = @"";
    
    frageString = [frageString stringByAppendingString:locationAktiv.person_name];
    
    if (locationAktiv.place_name!=nil) {
        frageString = [frageString stringByAppendingString:@" war bei "];
        frageString = [frageString stringByAppendingString:locationAktiv.place_name];
        
    }
    
    if (locationAktiv.place_location_city!=nil) {
        frageString = [frageString stringByAppendingString:@" in "];
        frageString = [frageString stringByAppendingString:locationAktiv.place_location_city];
        
    }
    
    if (locationAktiv.place_location_street!=nil) {
        frageString = [frageString stringByAppendingString:@" ("];
        frageString = [frageString stringByAppendingString:locationAktiv.place_location_street];
        frageString = [frageString stringByAppendingString:@")"];
        
    }
    
    if (locationAktiv.created_time!=nil) {
        frageString = [frageString stringByAppendingString:@" am "];
        frageString = [frageString stringByAppendingString:locationAktiv.created_time];
        
    }
    
    if ([locationAktiv.tags count]>0) {
        frageString = [frageString stringByAppendingString:@" mit "];
        
        for (Tags* tag in locationAktiv.tags)
        {
            NSLog(@"tag %@",tag.name);
            NSLog(@"tagID %@",tag.id);
            frageString = [frageString stringByAppendingString:tag.name];
            frageString = [frageString stringByAppendingString:@" , "];
        }
    }
    
    
    
    locationLabel.hidden = FALSE;
    locationLabel.text = frageString;
    
    
    float angle = [mWIPDirection performDirectionCalculation:locationAktiv withMyPosition:globalPosition];
    globalLocationHeading = angle;
    
    
    zeiger.tag = angle;
    zeiger.transform = CGAffineTransformMakeRotation(M_PI / 180 * (-globalHeading-90+zeiger.tag));
    
    
    
    
    if(startPlayer<anzahlPlayer)
    {
        //startPlayer++;
    }
    else
    {
        startPlayer = 1;
    }
    
    
    [self stopPulsateUIImageView:self.glass4];
    [self stopPulsateUIImageView:self.glass2];
    [self stopPulsateUIImageView:self.glass3];
    [self pulsateUIImageView:self.glass1];
    
    currentPlayer = 1;
   
}

- (void)nextPlayer:(int) spielerNr {
    
    NSURL* file = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"bu" ofType:@"mp3"]];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    [audioPlayer prepareToPlay];

    
    mWIPGameController = [[WIPGameController alloc]init];

    if (spielerNr == 1) {
        if (currentPlayer == 1) {
            [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle]];
            if (anzahlPlayer != 1) {
                currentPlayer = 2;
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
    else if (spielerNr == 2) {
        [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle]];
        if (currentPlayer == 2) {
            if (anzahlPlayer != 2) {
                currentPlayer = 3;
                [self stopPulsateUIImageView:self.glass1];
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass2];
                [self pulsateUIImageView:self.glass3];
                [audioPlayer play];
            }
            else
            {
                [self stopPulsateUIImageView:self.glass2];
                [self finishRound];
            }
            
        }
        
    }
    else if (spielerNr == 3) {
        if (currentPlayer == 3) {
        [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle]];
            if (anzahlPlayer != 3) {
                currentPlayer = 4;
                [self stopPulsateUIImageView:self.glass1];
                [self stopPulsateUIImageView:self.glass3];
                [self stopPulsateUIImageView:self.glass2];
                [self pulsateUIImageView:self.glass4];
                [audioPlayer play];
            }
            else
            {
                [self stopPulsateUIImageView:self.glass3];
                [self finishRound];
            }
            
        }
        
    }
    
    else if (spielerNr == 4) {
        if (currentPlayer == 4) {
            [mWIPGameController saveAngle:currentPlayer :[imageWheel getAngle]];
            [self stopPulsateUIImageView:self.glass4];
            [self finishRound];
            
        }
    }
  
}

- (void)finishRound
{
    NSLog(@"AUSWERTUNG");
    
    int winner = [mWIPGameController calculateWinner:((2*M_PI/360)*globalLocationHeading)];
    
    mWIPGameController = [[WIPGameController alloc]init];
    
    
    locationLabel.text = [NSString stringWithFormat:@"DER GEWINNER IST: %i", winner];

    [audioPlayer play];
    
    naechsteRundeBtn.hidden = false;
    
}


- (void)pulsateUIImageView:(UIImageView*) view
{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [anim setFromValue:[NSNumber numberWithFloat:0.7]];
    [anim setToValue:[NSNumber numberWithFloat:1.0]];
    [anim setAutoreverses:YES];
    [anim setDuration:0.5];
    anim.repeatCount = HUGE_VALF;
    [view.layer addAnimation:anim forKey:@"flash"];
    
    CABasicAnimation *animScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [animScale setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animScale setFromValue:[NSNumber numberWithFloat:1]];
    [animScale setToValue:[NSNumber numberWithFloat:1.2]];
    
    [animScale setAutoreverses:YES];
    [animScale setDuration:0.5];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    NSString *cellDetailedText = cell.detailTextLabel.text;
    
    cell.userInteractionEnabled = FALSE;

    NSLog(@"tap %@",cellDetailedText );
    NSLog(@"tap %@",cellText );

    
    [self spielerNameSelected:cellText :cellDetailedText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
      static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
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
        
        NSURL *imageURL = [NSURL URLWithString: [[friends objectAtIndex:indexPath.row] valueForKey:@"picture"]];
 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
               cell.imageView.image = [UIImage imageWithData:imageData];
                
            });
        });
        
      // cell.tag = [[friends objectAtIndex:indexPath.row] valueForKey:@"friend_id"];
        
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    
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
    
    naechsteRundeBtn.hidden = true;
    
    [self nextRound];
}
@end
