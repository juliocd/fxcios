//
//  TIESearchTravelViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TIESearchTravelViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithSearchData:(NSMutableArray *) aScheduleDayArray withSecond:(NSMutableArray *) aStepArray withThird:(NSNumber *) aIsGoing withFourth:(NSMutableArray *) aDaysArray;

@property (weak, nonatomic) IBOutlet UITableView *resultTableView;
@property (weak, nonatomic) IBOutlet GMSMapView *searchRouteMap;
- (IBAction)DaySelect:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *daySelect;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
- (IBAction)RequestTrip:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *resultSearchTable;

@end
