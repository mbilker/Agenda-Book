//
//  AppDelegate.m
//  Agenda Book
//
//  Created by Matt Bilker on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Info.h"
#import "ClassesViewController.h"

@implementation AppDelegate {
    NSMutableArray *classes;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    classes = [NSMutableArray arrayWithCapacity:20];
    
	Info *info = [[Info alloc] init];
	info.teacher = @"Mrs. Murray";
	info.subject = @"Math";
	info.complete = TRUE;
	[classes addObject:info];
    
	info = [[Info alloc] init];
	info.teacher = @"Mr. Quenzer";
	info.subject = @"Science";
	info.complete = TRUE;
	[classes addObject:info];
    
	info = [[Info alloc] init];
	info.teacher = @"Ms. Koerper";
	info.subject = @"Social Studies";
	info.complete = FALSE;
	[classes addObject:info];
    
    info = [[Info alloc] init];
	info.teacher = @"Mr. Cullen";
	info.subject = @"Tech Ed";
	info.complete = TRUE;
	[classes addObject:info];
    
	UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
	ClassesViewController *classesViewController = [[navigationController viewControllers] objectAtIndex:0];
	classesViewController.classes = classes;
    return YES;
}

@end
