//
//  WIPViewController.m
//  new
//
//  Created by Daniel Goebel on 26.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPViewController.h"
#import "WIPAppDelegate.h"

@interface WIPViewController ()


@end


static double kompassScheibeHeight, kompassScheibeWidth;
static double globalHeading;
static double anzahlPlayer, currentPlayer;
static bool spielAktiv;
static double spielerAktiv;
static Location *locationAktiv;
static CLLocationCoordinate2D globalPosition;
static double globalLocationHeading;

@implementation WIPViewController

@synthesize glass1, glass2, glass3, glass4, glassOutlet2;
@synthesize spieler1, spieler2, spieler3, spieler4;
@synthesize spielerName;
@synthesize spieler1Btn, spieler2Btn, spieler3Btn, spieler4Btn;

@synthesize spieler1Lbl,  spieler2Lbl, spieler3Lbl, spieler4Lbl;
@synthesize menuLabel;

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
        
        if (button.tag == 1) {
            if (currentPlayer == 1) {
                if (anzahlPlayer != 1) {
                     currentPlayer = 2;
                    [imageWheel resetAngle: globalHeading];
                    [self stopPulsateUIImageView:self.glass1];
                    [self stopPulsateUIImageView:self.glass4];
                    [self stopPulsateUIImageView:self.glass3];
                    [self pulsateUIImageView:self.glass2];
                }
                else
                {
                   [self stopPulsateUIImageView:self.glass1];
                    NSLog(@"AUSWERTUNG");
                }
               
            }
            else{
                currentPlayer = 1;
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass2];
                [self stopPulsateUIImageView:self.glass3];
                [self pulsateUIImageView:self.glass1];
            }
            
        }
        else if (button.tag == 2) {
            if (currentPlayer == 2) {
                if (anzahlPlayer != 2) {
                    currentPlayer = 3;
                    [self stopPulsateUIImageView:self.glass1];
                    [self stopPulsateUIImageView:self.glass4];
                    [self stopPulsateUIImageView:self.glass2];
                    [self pulsateUIImageView:self.glass3];
                }
                else
                {
                    [self stopPulsateUIImageView:self.glass2];
                    NSLog(@"AUSWERTUNG");
                }
                
            }
            else{
                currentPlayer = 1;
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass2];
                [self stopPulsateUIImageView:self.glass3];
                [self pulsateUIImageView:self.glass1];
            }
            
        }
        else if (button.tag == 3) {
            if (currentPlayer == 3) {
                if (anzahlPlayer != 3) {
                    currentPlayer = 4;
                    [self stopPulsateUIImageView:self.glass1];
                    [self stopPulsateUIImageView:self.glass3];
                    [self stopPulsateUIImageView:self.glass2];
                    [self pulsateUIImageView:self.glass4];
                }
                else
                {
                    [self stopPulsateUIImageView:self.glass3];
                    NSLog(@"AUSWERTUNG");
                }
                
            }
            else{
                currentPlayer = 1;
                [self stopPulsateUIImageView:self.glass4];
                [self stopPulsateUIImageView:self.glass2];
                [self stopPulsateUIImageView:self.glass3];
                [self pulsateUIImageView:self.glass1];
            }
            
        }

        else if (button.tag == 4) {
            if (currentPlayer == 4) {
                    [self stopPulsateUIImageView:self.glass4];
                    NSLog(@"AUSWERTUNG");
                }
        }

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
    [spielerName becomeFirstResponder];
        
        }
}

- (IBAction)spielerNameEntered:(id)sender {
    
    UITextField *spielerNameField = (UITextField*) sender;
    NSString *spielerNameValue = spielerNameField.text;
    
    if (spielerNameValue.length==0) {
        spielerNameValue = spielerNameField.placeholder;
    }
    
    [mWIPGameController insertPlayer:spielerName.text withId:[NSNumber numberWithDouble:currentPlayer]];
    
    menuLabel.text = [NSString stringWithFormat:@"Spieler %.0f", currentPlayer+1];
    spielerName.placeholder = [NSString stringWithFormat:@"Spieler %.0f", currentPlayer+1];
    spielerName.text = @"";
    currentPlayer = currentPlayer+1;

    if (currentPlayer==2) {
        [self stopPulsateUIImageView:self.glass1];
        spieler1Lbl.text = spielerNameValue;
        [self pulsateUIImageView:self.glass2];
    }
    
    if (currentPlayer==3) {
        [self stopPulsateUIImageView:self.glass2];
         spieler2Lbl.text = spielerNameValue;
        [self pulsateUIImageView:self.glass3];
        [spielerName becomeFirstResponder];
    }
    
    if (currentPlayer==4) {
        [self stopPulsateUIImageView:self.glass3];
         spieler3Lbl.text = spielerNameValue;
        [self pulsateUIImageView:self.glass4];
        [spielerName becomeFirstResponder];
    }
    
    
    if (currentPlayer==5) {
        [self stopPulsateUIImageView:self.glass4];
         spieler4Lbl.text = spielerNameValue;
    }
    
    
    if (currentPlayer==anzahlPlayer+1) {
        [self startGame];
    }
    else{
        
         [spielerNameField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];

    }
    
    
    
 
    
   
}

- (void)startGame {
    
    spielAktiv = true;

    mWIPDirection  = [[WIPDirection alloc]init];
    mWIPLocations  = [[WIPLocations alloc]init];
    [mWIPLocations createLocations];
    locationAktiv = [mWIPLocations selectLocation];
    
    locationLabel.hidden = FALSE;
    locationLabel.text = locationAktiv.name;
    
    float angle = [mWIPDirection performDirectionCalculation:locationAktiv withMyPosition:globalPosition];
    globalLocationHeading = angle;
    
    
    zeiger.tag = angle;    
    zeiger.transform = CGAffineTransformMakeRotation(M_PI / 180 * (-globalHeading-90+zeiger.tag));
    
    mWIPGameController = [[WIPGameController alloc]init];
    [mWIPGameController newGame:anzahlPlayer];
    
    
    imageWheel = [[ANImageWheel alloc] initWithFrame:CGRectMake(0, 0, kompassScheibeHeight, kompassScheibeWidth)];
    [imageWheel setImage:[UIImage imageNamed:@"jj1.png"]];
    [imageWheel startAnimating:self];
    [imageWheel setDrag:.5];
    
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
        
}

- (void)nextPlayer {
    
  
  
    
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

- (IBAction)importLocations:(id)sender {
    
  

}

- (IBAction)selectLocation:(id)sender {
    
    
    
}

- (IBAction)calculateLocation:(id)sender {
    
    
   
}


- (IBAction)gastgeberTapped:(id)sender {
    
    
    mWIPFacebook = [[WIPFacebook alloc] init];
    
   // [self presentViewController:[mWIPFacebook pickFriendsButtonClick] animated:YES completion:nil ];
    
    [mWIPFacebook sendRequestToFacebook:@"2"];

}
@end
