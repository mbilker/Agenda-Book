
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
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
    [MagicalRecord setupCoreDataStackWithiCloudContainer:kUbiquityContainerIdentifier contentNameKey:@"Agenda Book" localStoreNamed:@"Data" cloudStorePathComponent:@"data" completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAllViews object:nil];
    }];
    
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