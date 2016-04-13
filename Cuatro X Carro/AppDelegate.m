//
//  AppDelegate.m
//  Cuatro X Carro
//
//  Created by Process On Line on 7/19/15.
//  Copyright (c) 2015 IT Economics SAS. All rights reserved.
//

#import "AppDelegate.h"
#import "TIELoginViewController.h"
#import "TIESingUpViewController.h"
#import "TIETrayTravelsTableViewController.h"
#import "TIEProfileViewController.h"
#import "TIEScheduleTripViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


@synthesize tabBarController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [GMSServices provideAPIKey:@"AIzaSyBJSZlhicTKq7zb8-Pt6ba-dAMvLIyNAUc"];
    
    //Bandeja de viajes
    TIETrayTravelsTableViewController *trayTravelsTableVC = [[TIETrayTravelsTableViewController alloc]init];
    trayTravelsTableVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"viajes_on@2x~iphone.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    trayTravelsTableVC.tabBarItem.image = [[UIImage imageNamed:@"viajes_off@2x~iphone.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    trayTravelsTableVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    //Perfil de usuario
    TIEProfileViewController *profileVC = [[TIEProfileViewController alloc]init];
    profileVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"perfil_on@2x~iphone.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profileVC.tabBarItem.image = [[UIImage imageNamed:@"perfil_off@2x~iphone.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profileVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    //Programar viaje
    TIEScheduleTripViewController *scheduleTripVC = [[TIEScheduleTripViewController alloc]init];
    scheduleTripVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"program_on@2x~iphone.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    scheduleTripVC.tabBarItem.image = [[UIImage imageNamed:@"program_off@2x~iphone.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    scheduleTripVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    //Inicializar UITabBarController
    self.tabBarController = [[UITabBarController alloc]init];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:(30/255.0) green:(190/255.0) blue:(219/255.0)alpha:1.0];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.viewControllers = @[trayTravelsTableVC, profileVC, scheduleTripVC];
    
    //Add the tab bar controller to the window
    TIELoginViewController *loginVC = [[TIELoginViewController alloc]init];
    [self.window setRootViewController:loginVC];
    [self.window setBackgroundColor: [UIColor colorWithRed:(30/255.0) green:(190/255.0) blue:(219/255.0)alpha:1.0]];
    [self.window makeKeyAndVisible];
    
    //Se configuran notificacion
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    return YES;
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
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Detect if APN is received on Background or Foreground state
    NSString *opa = @"asdasd";
}

@end
