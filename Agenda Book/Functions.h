//
//  Functions.h
//  Agenda Book
//
//  Created by System Administrator on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Functions : NSObject

+ (NSString *)assignmentPath;
+ (NSString *)classPath;
+ (NSString *)subjectPath;
+ (UIColor *)colorForComplete:(BOOL)complete;
+ (UIColor *)determineClassComplete:(NSString *)string;

@end
