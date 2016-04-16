//
//  TIEPassengerDetailsViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 4/16/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "ViewController.h"

@interface TIEPassengerDetailsViewController : ViewController

- (id)initWithTripId:(NSString *) passengerId;

@property (weak, nonatomic) IBOutlet UIImageView *pictureProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *startedTripsLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishedTripsLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelTripLabel;


@end
