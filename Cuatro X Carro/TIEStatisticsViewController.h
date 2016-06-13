//
//  TIEPassengerDetailsViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 4/16/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "ViewController.h"

@interface TIEStatisticsViewController : ViewController

- (id)initWithUserId:(NSString *) _userId;

@property (weak, nonatomic) IBOutlet UILabel *startedTripsLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishedTripsLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelTripLabel;

@property (weak, nonatomic) IBOutlet UIImageView *rateOneIcon;
@property (weak, nonatomic) IBOutlet UIImageView *rateTwoIcon;
@property (weak, nonatomic) IBOutlet UIImageView *rateThreeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *rateFourIcon;
@property (weak, nonatomic) IBOutlet UIImageView *rateFiveIcon;

@end
