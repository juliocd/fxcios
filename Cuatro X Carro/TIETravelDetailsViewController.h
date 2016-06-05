//
//  TIETravelDetailsViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface TIETravelDetailsViewController : UIViewController<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

- (id)initWithTripData:(NSMutableDictionary *) aTripData;

@property (weak, nonatomic) IBOutlet GMSMapView *routeMap;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *dateTrip;
@property (weak, nonatomic) IBOutlet UILabel *hourTrip;
@property (weak, nonatomic) IBOutlet UIButton *startTripUIButton;
@property (weak, nonatomic) IBOutlet UIButton *requestUIButton;
@property (weak, nonatomic) IBOutlet UIButton *finishTripUIButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *animmationPositionDiver;
@property (weak, nonatomic) IBOutlet UITableView *messengerTable;
@property (weak, nonatomic) IBOutlet UIButton *finishTripPassengerButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelTripButton;
@property (weak, nonatomic) IBOutlet UIButton *showPassengerButton;

- (IBAction)startTripButton:(id)sender;
- (IBAction)finishTripButton:(id)sender;
- (IBAction)viewApplications:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)showPassengers:(id)sender;
- (IBAction)finishTripPassenger:(id)sender;
- (IBAction)cancelTrip:(id)sender;

@end
