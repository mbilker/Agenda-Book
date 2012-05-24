
#import "AppDelegate.h"
#import "ClassesViewController.h"

#import "Info.h"
#import "Assignment.h"

#import "OpenUDID.h"
#import "UAirship.h"
#import "UAPush.h"

@implementation AppDelegate {
    NSDictionary *_info;
}

@synthesize window = _window;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)update:(NSDictionary *)dictionary
{
    if ([[dictionary valueForKey:@"update"] boolValue]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mbilker.us/agenda.html"]];
        [[UAPush shared] resetBadge]; //zero badge
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSManagedObjectContext *context = [self managedObjectContext];
    /* Info *info = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Info"
                                       inManagedObjectContext:context];
    info.teacher = @"Mrs. Test";
    info.subject = @"Math";
    info.classid = @"0";
    Assignment *assignment = [NSEntityDescription
                                          insertNewObjectForEntityForName:@"Assignment"
                                          inManagedObjectContext:context];
    assignment.assignmentText = @"Test";
    assignment.complete = YES;
    assignment.dueDate = [NSDate date]; */
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *iCloudURL = [fileManager URLForUbiquityContainerIdentifier:@"DXD4278H9V.us.mbilker.agendabook"];
    //NSLog(@"iCloudURL: '%@'", [iCloudURL absoluteString]);
    
    if(iCloudURL) {
        NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
        [iCloudStore setString:@"Success" forKey:@"iCloudStatus"];
        [iCloudStore synchronize]; // For Synchronizing with iCloud Server
        NSLog(@"iCloudStatus: '%@'", [iCloudStore stringForKey:@"iCloudStatus"]);
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"iCloud"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"iCloud"];
    }
    
	UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
	ClassesViewController *classesViewController = [[navigationController viewControllers] objectAtIndex:0];
    classesViewController.managedObjectContext = self.managedObjectContext;
    /* NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Info" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (Info *info in fetchedObjects) {
        NSLog(@"class: '%@'",info.subject);
        NSLog(@"classid: '%@'",info.classid);
        NSLog(@"teacher: '%@'",info.teacher);
    } */
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared] resetBadge]; //zero badge
    //[UIApplication sharedApplication].delegate = self;
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Check if the app was launched in response to the user tapping on a
	// push notification. If so, we add the new message to the data model.
	if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			//NSLog(@"Launched from push notification: %@", dictionary);
			[self update:dictionary];
		}
	}
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //NSLog(@"Received Notification: %@", userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        _info = userInfo;
        int appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue];
        int updateVersion = [[userInfo valueForKey:@"version"] intValue];
        if (updateVersion > appVersion) {
            [[[UIAlertView alloc] initWithTitle:@"New Update" message:[NSString stringWithFormat:@"There is a newer app version (%d), you currently have %d",updateVersion,appVersion] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil] show];
        }
    } else {
        [self update:userInfo];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Index: '%d'",buttonIndex);
    if (buttonIndex == 1) {
        [self update:_info];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"DeviceToken: '%@'",deviceToken.description);
    [UAPush shared].alias = [OpenUDID value];
    [[UAirship shared] registerDeviceToken:deviceToken];
    //[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Data" withExtension:@"momd"];
    //NSLog(@"url: '%@'",modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    //NSLog(@"model: '%@'",__managedObjectModel);
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Data.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [UAirship land];
}

@end