//
//  TIEScheduleTripViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TIEScheduleTripViewController : UIViewController
- (IBAction)searchRoute:(id)sender;

@property (weak, nonatomic) IBOutlet GMSMapView *selectRouteMap;

@end
