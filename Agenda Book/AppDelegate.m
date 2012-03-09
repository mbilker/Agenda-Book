//
//  AppDelegate.m
//  Agenda Book
//
//  Created by Matt Bilker on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Player.h"
#import "ClassesViewController.h"

@implementation AppDelegate {
    NSMutableArray *players;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    players = [NSMutableArray arrayWithCapacity:20];
    
	Player *player = [[Player alloc] init];
	player.name = @"Mrs. Murray";
	player.game = @"Math";
	player.complete = TRUE;
	[players addObject:player];
    
	player = [[Player alloc] init];
	player.name = @"Mr. Quenzer";
	player.game = @"Science";
	player.complete = TRUE;
	[players addObject:player];
    
	player = [[Player alloc] init];
	player.name = @"Ms. Koerper";
	player.game = @"Social Studies";
	player.complete = FALSE;
	[players addObject:player];
    
	UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
	ClassesViewController *classesViewController = [[navigationController viewControllers] objectAtIndex:0];
	classesViewController.players = players;
    return YES;
}

@end
