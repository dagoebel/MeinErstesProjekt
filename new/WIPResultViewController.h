//
//  WIPResultViewController.h
//  new
//
//  Created by Daniel Goebel on 09.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WIPGameController.h"

@interface WIPResultViewController : UIViewController{
     WIPGameController *mWIPGameController;
}
@property (weak, nonatomic) IBOutlet UILabel *result1;
@property (weak, nonatomic) IBOutlet UILabel *result2;
@property (weak, nonatomic) IBOutlet UILabel *result3;
@property (weak, nonatomic) IBOutlet UILabel *result4;
@property (weak, nonatomic) IBOutlet UIImageView *i1;
@property (weak, nonatomic) IBOutlet UIImageView *i2;
@property (weak, nonatomic) IBOutlet UIImageView *i3;
@property (weak, nonatomic) IBOutlet UIImageView *i4;

- (IBAction)back:(id)sender;
- (IBAction)closeInstruction:(id)sender;

@end
