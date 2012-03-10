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
	UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
	ClassesViewController *classesViewController = [[navigationController viewControllers] objectAtIndex:0];
	classesViewController.classes = classes;
    return YES;
}

@end
