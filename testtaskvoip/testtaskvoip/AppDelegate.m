//
//  AppDelegate.m
//  testtaskvoip
//
//  Created by Mykola on 5/27/15.
//  Copyright (c) 2015 The Kondratyuks. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)                  application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    MDLog(@"\nWindow bounds: %@\n\n\n", [NSValue valueWithCGRect:bounds]  );
    
    self.window = [UIWindow new];
    [self.window makeKeyAndVisible];
    
    self.window.frame = [[UIScreen mainScreen] bounds];
    
    
    ViewController* vc = [[ViewController alloc] initWithNibName: @"ViewController"
                                                          bundle: nil];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController: vc];
    
    self.window.rootViewController = nav;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSString *messageInfo = @"\nUse this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.";
    MDLog(@"%@\n\n\n", messageInfo);
   
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIApplication *thisApp  = [UIApplication sharedApplication];
    BOOL backgroundAccepted = [thisApp setKeepAliveTimeout: 600
                                                   handler: ^(void)
                                                             {
                                                                 [self backgroundHandler];
                                                             }];
    if (backgroundAccepted)
    {
        NSLog(@"VOIP backgrounding accepted");
    }
    
    bgTask = [thisApp beginBackgroundTaskWithExpirationHandler: ^(void)
                                                                 {
                                                                     [thisApp endBackgroundTask: bgTask];
                                                                     bgTask = UIBackgroundTaskInvalid;
                                                                 }];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSString *messageInfo = @"\nCalled as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.";
    MDLog(@"%@\n\n\n", messageInfo);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSString *messageInfo = @"\nRestart any tasks that were paused (or not yet started) while the application was inactive. \nIf the application was previously in the background, optionally refresh the user interface.";
    MDLog(@"%@\n\n\n", messageInfo);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)backgroundHandler
{
    MDLog(@"\n### -->VOIP backgrounding callback\n\n\n");
    UIApplication* app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler: ^(void)
                                                             {
                                                                 [app endBackgroundTask:bgTask];
                                                                 bgTask = UIBackgroundTaskInvalid;
                                                             }];

}



@end
