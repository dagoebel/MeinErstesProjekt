//
//  WIPFacebook.h
//  new
//
//  Created by Daniel Goebel on 14.10.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>


@interface WIPFacebook : NSObject <FBFriendPickerDelegate>

- (void) checkSession;
- (UIViewController *) pickFriendsButtonClick;

@end


