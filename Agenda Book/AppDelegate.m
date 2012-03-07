//
//  AppDelegate.m
//  Agenda Book
//
//  Created by Matt Bilker on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Player.h"
#import "PlayersViewController.h"

@implementation AppDelegate {
    NSMutableArray *players;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    players = [NSMutableArray arrayWithCapacity:20];
    
	Player *player = [[Player alloc] init];
	player.name = @"Bill Evans";
	player.game = @"Tic-Tac-Toe";
	player.rating = 4;
	[players addObject:player];
    
	player = [[Player alloc] init];
	player.name = @"Oscar Peterson";
	player.game = @"Spin the Bottle";
	player.rating = 5;
	[players addObject:player];
    
	player = [[Player alloc] init];
	player.name = @"Dave Brubeck";
	player.game = @"Texas Hold’em Poker";
	player.rating = 2;
	[players addObject:player];
    
	UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
	UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
	PlayersViewController *playersViewController = [[navigationController viewControllers] objectAtIndex:0];
	playersViewController.players = players;
    return YES;
}

@end
