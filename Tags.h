//
//  Tags.h
//  new
//
//  Created by Daniel Goebel on 10.11.12.
//  Copyright (c) 2012 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Tags : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Question *question;

@end
