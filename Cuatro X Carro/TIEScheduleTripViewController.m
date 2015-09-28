//
//  TIEScheduleTripViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIEScheduleTripViewController.h"
#import "TIESearchTravelViewController.h"
@import GoogleMaps;

@interface TIEScheduleTripViewController ()

@end

@implementation TIEScheduleTripViewController

@synthesize selectRouteMap;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    self.selectRouteMap.camera = camera;
    self.selectRouteMap.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.selectRouteMap;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)searchRoute:(id)sender {
    TIESearchTravelViewController *searchTravelsVC = [[TIESearchTravelViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:searchTravelsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}
@end
