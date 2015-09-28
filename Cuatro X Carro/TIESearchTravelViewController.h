//
//  TIESearchTravelViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TIESearchTravelViewController : UIViewController

@property (strong, nonatomic) NSArray *results;

@property (weak, nonatomic) IBOutlet UITableView *resultTableView;
@property (weak, nonatomic) IBOutlet GMSMapView *searchRouteMap;

@end
