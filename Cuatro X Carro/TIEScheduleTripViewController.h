//
//  TIEScheduleTripViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRouteController.h"

@interface TIEScheduleTripViewController : UIViewController <GMSMapViewDelegate, UITextFieldDelegate>{
    UIButton *buttonMonday;
    UIButton *buttonTuesday;
    UIButton *buttonWednesday;
    UIButton *buttonThursday;
    UIButton *buttonFriday;
    UIButton *buttonSaturday;
    
    NSMutableArray *detailedSteps;
    
    NSMutableArray *_coordinates;
    LRouteController *_routeController;
    GMSPolyline *_polyline;
    GMSMarker *_markerStart;
    GMSMarker *_markerFinish;
    int contField;
}
- (IBAction)searchRoute:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *myView;

@property (weak, nonatomic) IBOutlet GMSMapView *selectRouteMap;
@property (weak, nonatomic) IBOutlet UISwitch *switchUserType;
@property (weak, nonatomic) IBOutlet UIButton *saveDriverTravel;
@property (weak, nonatomic) IBOutlet UIButton *searchPassengerTravels;

- (IBAction)SwitchUserType:(id)sender;

- (IBAction)CheckMonday:(id)sender;
- (IBAction)CheckTuesday:(id)sender;
- (IBAction)CheckWednesday:(id)sender;
- (IBAction)CheckThursday:(id)sender;
- (IBAction)CheckFriday:(id)sender;
- (IBAction)CheckSaturday:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *travelTypeSelect;
- (IBAction)SelectTravelType:(id)sender;
- (IBAction)ClearMap:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *availableSeats;
@property (weak, nonatomic) IBOutlet UILabel *availableSeatsLabel;

- (IBAction)SaveDriverTravel:(id)sender;

@end
