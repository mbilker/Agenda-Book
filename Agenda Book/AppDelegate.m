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
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
	ClassesViewController *classesViewController = [[navigationController viewControllers] objectAtIndex:0];
	classesViewController.classes = classes;
    return YES;
}

@end
