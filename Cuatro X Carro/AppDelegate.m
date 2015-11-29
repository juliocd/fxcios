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
    trayTravelsTableVC.tabBarItem.title = @"Viajes";
    //Perfil de usuario
    TIEProfileViewController *profileVC = [[TIEProfileViewController alloc]init];
    profileVC.tabBarItem.title = @"Perfil";
    //Programar viaje
    TIEScheduleTripViewController *scheduleTripVC = [[TIEScheduleTripViewController alloc]init];
    scheduleTripVC.tabBarItem.title = @"Programar";
    
    //Inicializar UITabBarController
    self.tabBarController = [[UITabBarController alloc]init];
    self.tabBarController.viewControllers = @[trayTravelsTableVC, profileVC, scheduleTripVC];
    
    //Add the tab bar controller to the window
    TIELoginViewController *loginVC = [[TIELoginViewController alloc]init];
    [self.window setRootViewController:loginVC];
    [self.window setBackgroundColor: [UIColor whiteColor]];
    
    [self.window makeKeyAndVisible];
    
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

@end
