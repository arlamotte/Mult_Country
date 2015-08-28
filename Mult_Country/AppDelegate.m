//
//  AppDelegate.m
//  Mult_Country
//
//  Created by Archimedes Lamotte on 8/18/15.
//  Copyright (c) 2015 Archimedes Lamotte. All rights reserved.
//

#import "AppDelegate.h"
#import "ETPush.h"



@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // DELETE SDK DATABASE WHEN COUNTRY WAS CHANGED
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IsAppIdReset"]) {
     [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:@"IsAppIdReset"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     NSURL *databaseLocationURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
     NSString *oldDatabaseFilePath = [[databaseLocationURL path] stringByAppendingPathComponent:@"etdb.db"];
     if ([[NSFileManager defaultManager] fileExistsAtPath:oldDatabaseFilePath]) {
         NSError *error;
         [[NSFileManager defaultManager] removeItemAtPath:oldDatabaseFilePath error:&error];
        }
     NSString *newDatabaseFilePath = [[databaseLocationURL path] stringByAppendingPathComponent:SDKName];
     if ([[NSFileManager defaultManager] fileExistsAtPath:newDatabaseFilePath]) {
         NSError *error;
         [[NSFileManager defaultManager] removeItemAtPath:newDatabaseFilePath error:&error];
        }
     }
    
    if ( [[NSUserDefaults standardUserDefaults] stringForKey:@"ApID"] == nil){
        
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:@"newAppID"];
        [[NSUserDefaults standardUserDefaults] setObject:@"País 1"
                                                  forKey:@"Pais"];
    }

    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"newAppID"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"[PUT YOUR COUNTRY 1 APPID]"
                                                  forKey:@"ApID"];
        [[NSUserDefaults standardUserDefaults] setObject:@"[PUT YOUR COUNTRY 1 TOKEN]]"
                                                  forKey:@"key"];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"[PUT YOUR COUNTRY 2 APPID]"
                                                  forKey:@"ApID"];
        [[NSUserDefaults standardUserDefaults] setObject:@"[PUT YOUR COUNTRY 2 TOKEN]"
                                                  forKey:@"key"];
    }
    
    BOOL successful = NO;
    NSError *error = nil;
    
    
    // Set to YES to enable logging while debugging
    [ETPush setETLoggerToRequiredState:YES];
    
    
    // configure and set initial settings of the JB4ASDK
    successful = [[ETPush pushManager] configureSDKWithAppID:[[NSUserDefaults standardUserDefaults] stringForKey:@"ApID"]
                                              andAccessToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"key"]
                                               withAnalytics:YES
                                         andLocationServices:YES
                                               andCloudPages:YES
                                             withPIAnalytics:YES
                                                       error:&error];
    //
    // if configureSDKWithAppID returns NO, check the error object for detailed failure info. See PushConstants.h for codes.
    // the features of the JB4ASDK will NOT be useable unless configureSDKWithAppID returns YES.
    //
    if (!successful) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // something failed in the configureSDKWithAppID call - show what the error is
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed configureSDKWithAppID!", @"Failed configureSDKWithAppID!")
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                              otherButtonTitles:nil] show];
        });
    }
    else {
        // register for push notifications - enable all notification types, no categories
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound |
                                                UIUserNotificationTypeAlert
                                                                                 categories:nil];
        
        
        
        [[ETPush pushManager] registerUserNotificationSettings:settings];
        [[ETPush pushManager] registerForRemoteNotifications];
        
        // inform the JB4ASDK of the launch options - possibly UIApplicationLaunchOptionsRemoteNotificationKey or UIApplicationLaunchOptionsLocalNotificationKey
        [[ETPush pushManager] applicationLaunchedWithOptions:launchOptions];
        
        // HARDCODE SUBSCRIBERKEY
        //[[ETPush pushManager] setSubscriberKey:@"alamotte@salesforce.com"];
        
        // SET TAG FOR LIST SEGMENTATION AT MOBILEPUSH
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"newAppID"]){
            [[ETPush pushManager] addTag:@"P1"];
        }
        else
        {
            [[ETPush pushManager] addTag:@"P2"];
        }

    }
        
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    // inform the JB4ASDK of the notification settings requested
    [[ETPush pushManager] didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    // inform the JB4ASDK of the device token
    [[ETPush pushManager] registerDeviceToken:deviceToken];
        
}

/*
func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    ETPush.pushManager().registerDeviceToken(deviceToken)
}
*/
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // inform the JB4ASDK that the device failed to register and did not receive a device token
    [[ETPush pushManager] applicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // inform the JB4ASDK that the device received a local notification
    [[ETPush pushManager] handleLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    
    // inform the JB4ASDK that the device received a remote notification
    [[ETPush pushManager] handleNotification:userInfo forApplicationState:application.applicationState];
    
    // is it a silent push?
    if (userInfo[@"aps"][@"content-available"]) {
        // received a silent remote notification...
        
        // indicate a silent push
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    }
    else {
        // received a remote notification...
        
        // clear the badge
        [[ETPush pushManager] resetBadgeCount];
    }
    
    handler(UIBackgroundFetchResultNoData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.tutsplus.Mult_Country" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Mult_Country" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mult_Country.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
