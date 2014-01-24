
#import "AppDelegate.h"
#import "ClassesViewController.h"
#import "Utils.h"

#import "Info.h"
#import "Assignment.h"

//#import <PonyDebugger/PonyDebugger.h>

@implementation AppDelegate {
    NSDictionary *_info;
}

@synthesize window = _window;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
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
    
    // PonyDebugger
    //PDDebugger *debugger = [PDDebugger defaultInstance];
    
    //[debugger enableNetworkTrafficDebugging];
    //[debugger enableRemoteLogging];
    //[debugger forwardAllNetworkTraffic];
    //[debugger enableCoreDataDebugging];
    //[debugger addManagedObjectContext:self.managedObjectContext withName:@"Data"];
    
    //[debugger connectToURL:[NSURL URLWithString:@"ws://mbilkermac.local:9000/device"]];
    
    return YES;
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
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        _managedObjectContext = moc;
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Data" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Data.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
        
    // Migrate datamodel
    NSDictionary *options = nil;
        
    // this needs to match the entitlements and provisioning profile
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:@"DXD4278H9V.us.mbilker.agendabook"];
    NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"data"];
    if ([coreDataCloudContent length] != 0) {
            // iCloud is available
        cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
            
        options = @{
            NSMigratePersistentStoresAutomaticallyOption: @YES,
            NSInferMappingModelAutomaticallyOption: @YES,
            NSPersistentStoreUbiquitousContentNameKey: @"Agenda Book",
            NSPersistentStoreUbiquitousContentURLKey: cloudURL
        };
    } else {
        // iCloud is not available
        options = @{
            NSMigratePersistentStoresAutomaticallyOption: @YES,
            NSInferMappingModelAutomaticallyOption: @YES
        };
    }
        
    NSError *error = nil;
    [_persistentStoreCoordinator lock];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
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
    [_persistentStoreCoordinator unlock];
        
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefetchAllDatabaseData object:self userInfo:nil];
    });
    
    return _persistentStoreCoordinator;
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFromiCloud:(NSNotification *)notification
{
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:notification];
        
        NSNotification* refreshNotification = [NSNotification notificationWithName:kRefreshAllViews object:self userInfo:[notification userInfo]];
        
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end