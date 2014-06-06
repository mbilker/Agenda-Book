
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "AppDelegate.h"
#import "ClassesViewController.h"
#import "Utils.h"

#import "Info.h"
#import "Assignment.h"

@implementation AppDelegate {
    NSDictionary *_info;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithiCloudContainer:kUbiquityContainerIdentifier contentNameKey:@"Agenda Book" localStoreNamed:@"Data" cloudStorePathComponent:@"data"];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end