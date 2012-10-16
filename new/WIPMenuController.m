//
//  WIPMenuController.m
//  new
//
//  Created by Daniel Goebel on 01.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import "WIPMenuController.h"
#import "WIPLocationViewController.h"

@interface WIPMenuController ()

@end

@implementation WIPMenuController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeApp:(id)sender {
    
    exit(0);
}

- (IBAction)startGame:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WIPViewController"];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    [self presentViewController:vc
                       animated:YES completion:nil];
    
    
    
    
    
    
    
    
    
}

- (IBAction)showLocations:(id)sender {
    
   
    
}


@end
