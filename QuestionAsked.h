//
//  QuestionAsked.h
//  new
//
//  Created by Daniel Goebel on 19.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QuestionAsked : NSManagedObject

@property (nonatomic, retain) NSNumber * angle;
@property (nonatomic, retain) NSNumber * distance;

@end
