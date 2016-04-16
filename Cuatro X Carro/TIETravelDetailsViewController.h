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

@interface TIETravelDetailsViewController : UIViewController<CLLocationManagerDelegate>

- (id)initWithTripData:(NSMutableDictionary *) aTripData;

@property (weak, nonatomic) IBOutlet GMSMapView *routeMap;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *dateTrip;
@property (weak, nonatomic) IBOutlet UILabel *hourTrip;
@property (weak, nonatomic) IBOutlet UILabel *seatsState;
@property (weak, nonatomic) IBOutlet UIButton *startTripUIButton;
@property (weak, nonatomic) IBOutlet UIButton *requestUIButton;
@property (weak, nonatomic) IBOutlet UIButton *finishTripUIButton;
@property (weak, nonatomic) IBOutlet UILabel *passengerOne;
@property (weak, nonatomic) IBOutlet UILabel *passengerTwo;
@property (weak, nonatomic) IBOutlet UILabel *passengerThree;
@property (weak, nonatomic) IBOutlet UILabel *passengerFour;
@property (weak, nonatomic) IBOutlet UIButton *passengerOneUIButton;
@property (weak, nonatomic) IBOutlet UIButton *passengerTwoUIButton;
@property (weak, nonatomic) IBOutlet UIButton *passengerThreeUIButton;
@property (weak, nonatomic) IBOutlet UIButton *passengerFourUIButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *animmationPositionDiver;

- (IBAction)goChatButton:(id)sender;
- (IBAction)startTripButton:(id)sender;
- (IBAction)finishTripButton:(id)sender;
- (IBAction)viewApplications:(id)sender;
- (IBAction)passengerOneInfoButton:(id)sender;
- (IBAction)passengerTwoInfoButton:(id)sender;
- (IBAction)passengerThreeInfoButton:(id)sender;
- (IBAction)passengerFourInfoButton:(id)sender;

@end
