//
//  TIETravelDetailsViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIETravelDetailsViewController.h"
#import "TIEApplicationsViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface TIETravelDetailsViewController ()

@end

@implementation TIETravelDetailsViewController

@synthesize routeMap;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Detalles";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    self.routeMap.camera = camera;
    self.routeMap.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.routeMap;
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)viewApplications:(id)sender {
    TIEApplicationsViewController *applicationsVC =[[TIEApplicationsViewController alloc]init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:applicationsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}
@end
