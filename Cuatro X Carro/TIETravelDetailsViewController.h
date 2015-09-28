//
//  TIETravelDetailsViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TIETravelDetailsViewController : UIViewController

- (IBAction)viewApplications:(id)sender;

@property (weak, nonatomic) IBOutlet GMSMapView *routeMap;


@end
