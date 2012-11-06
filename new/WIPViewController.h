//
//  WIPViewController.h
//  new
//
//  Created by Daniel Goebel on 26.09.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPBottle.h"
#import <UIKit/UIKit.h>
#import "WIPDirection.h"
#import "WIPLocationController.h"
#import "WIPLocations.h"
#import "WIPGameController.h"
#import "ANImageWheel.h"
#import "WIPAnimations.h"
#import "WIPAppDelegate.h"
#import "WIPFacebook.h"
#import <AVFoundation/AVFoundation.h>


@protocol WIPViewControllerDelegate;

@interface WIPViewController : UIViewController <WIPLocationControllerDelegate, UITableViewDelegate, UITableViewDataSource>{
    WIPGameController *mWIPGameController;
    WIPBottle *mWIPBottle;
    WIPDirection *mWIPDirection;
    WIPLocationController *CLController;
    WIPLocations *mWIPLocations;
    IBOutlet UILabel *locLabel;
    ANImageWheel * imageWheel;
    WIPFacebook *mWIPFacebook;

    NSArray *people;
	NSArray *filteredPeople;
    AVAudioPlayer* audioPlayer;
    AVAudioPlayer* audioPlayerWin;
    AVAudioPlayer* audioPlayerQuestio;
    
	UISearchDisplayController *searchDisplayController;
}
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;




@property (weak, nonatomic) IBOutlet UIImageView *bottle;
@property (weak, nonatomic) IBOutlet UIImageView *container;
@property (weak, nonatomic) IBOutlet UIView *zeiger;
@property (weak, nonatomic) IBOutlet UIImageView *glass1;
@property (weak, nonatomic) IBOutlet UIImageView *glass2;
@property (weak, nonatomic) IBOutlet UIImageView *glass3;
@property (weak, nonatomic) IBOutlet UIImageView *glass4;

@property (weak, nonatomic) IBOutlet UIView *kompassScheibe;
@property (weak, nonatomic) IBOutlet UIImageView *kompassScheibeImg;
@property (weak, nonatomic) IBOutlet UILabel *locationLblBot;
@property (weak, nonatomic) IBOutlet UILabel *locationLblTop;

@property (weak, nonatomic) IBOutlet UIView *gameMenu;
@property (weak, nonatomic) IBOutlet UIButton *spieler1;
@property (weak, nonatomic) IBOutlet UIButton *spieler2;
@property (weak, nonatomic) IBOutlet UIButton *spieler3;
@property (weak, nonatomic) IBOutlet UIButton *spieler4;
@property (weak, nonatomic) IBOutlet UITextField *spielerName;
@property (weak, nonatomic) IBOutlet UIButton *spieler1Btn;
@property (weak, nonatomic) IBOutlet UIButton *spieler2Btn;
@property (weak, nonatomic) IBOutlet UIButton *spieler3Btn;
@property (weak, nonatomic) IBOutlet UIButton *spieler4Btn;
@property (weak, nonatomic) IBOutlet UILabel *spieler1Lbl;
@property (weak, nonatomic) IBOutlet UILabel *spieler2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *spieler3Lbl;
@property (weak, nonatomic) IBOutlet UILabel *spieler4Lbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *naechsteRundeBtn;
- (IBAction)naechsteRunde:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *spieler1Bubble;
@property (weak, nonatomic) IBOutlet UIImageView *spieler1BubbleImg;
@property (weak, nonatomic) IBOutlet UIView *spieler2Bubble;
@property (weak, nonatomic) IBOutlet UIImageView *spieler2BubbleImg;
@property (weak, nonatomic) IBOutlet UIView *spieler3Bubble;
@property (weak, nonatomic) IBOutlet UIImageView *spieler3BubbleImg;
@property (weak, nonatomic) IBOutlet UIView *spieler4Bubble;
@property (weak, nonatomic) IBOutlet UIImageView *spieler4BubbleImg;
@property (weak, nonatomic) IBOutlet UILabel *auswertungLbl1;
@property (weak, nonatomic) IBOutlet UILabel *auswertungLbl2;
@property (weak, nonatomic) IBOutlet UILabel *auswertungLbl3;
@property (weak, nonatomic) IBOutlet UILabel *auswertungLbl4;
@property (weak, nonatomic) IBOutlet UIView *auswertungView;
@property (weak, nonatomic) IBOutlet UILabel *zeigerLbl;

@property (weak, nonatomic) IBOutlet UILabel *player1Auswertung;
@property (weak, nonatomic) IBOutlet UILabel *player2Auswertung;
@property (weak, nonatomic) IBOutlet UILabel *player3Auswertung;
@property (weak, nonatomic) IBOutlet UILabel *player4Auswertung;

@property (weak, nonatomic) IBOutlet UIImageView *player4AuswertungImg;
@property (weak, nonatomic) IBOutlet UIImageView *player3AuswertungImg;
@property (weak, nonatomic) IBOutlet UIImageView *player1AuswertungImg;
@property (weak, nonatomic) IBOutlet UIImageView *player2AuswertungImg;




@property (weak, nonatomic) IBOutlet UILabel *spinngLblTop;
@property (weak, nonatomic) IBOutlet UILabel *spinngLblBot;


@property (weak, nonatomic) IBOutlet UIView *spinningLblBackr;

@property (weak, nonatomic) IBOutlet UIImageView *player1Img;


@property (weak, nonatomic) IBOutlet UILabel *menuLabel;
- (IBAction)spielerNameEntered:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *glassOutlet2;


@property double startTransform;

@property (nonatomic, assign) id<WIPViewControllerDelegate> delegate;

@property (nonatomic, retain) WIPLocationController *CLController;

@property (nonatomic, retain) NSArray *people;
@property (nonatomic, retain) NSArray *filteredPeople;

@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;

- (IBAction)fakeDegree:(id)sender;
- (IBAction)gastgeberTapped:(id)sender;
- (IBAction)showFriendPicker:(id)sender;
- (IBAction)singleBottleTap:(id)sender;
-(IBAction)handleCloseButton:(id)sender;
-(IBAction)rotateTheFUCKINGBottle:(id)sender;
- (IBAction)flascheFaerben:(id)sender;
- (IBAction)backToMenu:(id)sender;
- (IBAction)selectPlayer:(id)sender;
- (void)startGame;
- (IBAction)selectPlayerSetup:(id)sender;
- (UIImage *)imageWithColor:(UIColor *)color;
- (IBAction)importLocations:(id)sender;
- (IBAction)selectLocation:(id)sender;
- (IBAction)calculateLocation:(id)sender;


- (void)pulsateUIImageView:(UIImageView*) view;
- (UIImage * ) mergeImage: (UIImage *) imageA
withImage:  (UIImage *) imageB
                 strength: (float) strength;

@property (weak, nonatomic) IBOutlet UITableView *TableViewFriends;

@end

@protocol WIPViewControllerDelegate <NSObject>

-(void)WIPViewControllerDidFinish:(WIPViewController*)viewController;
- (void)nextPlayer;
- (void)finishRound;


@end