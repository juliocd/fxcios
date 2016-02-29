//
//  TIETravelCustomCellTableViewCell.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIETravelCustomCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userPictureImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripType;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rateOneImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateTwoImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateThreeImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateFourImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateFiveImage;
@property (weak, nonatomic) IBOutlet UILabel *tripId;
@property (weak, nonatomic) IBOutlet UILabel *userType;
@property (weak, nonatomic) IBOutlet UIButton *notificationButton;
@property (weak, nonatomic) IBOutlet UIButton *requestButton;

//Nuevos campos por estilos
@property (weak, nonatomic) IBOutlet UILabel *dateDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsAvailableLabel;


- (IBAction)NotificationButton:(id)sender;
- (IBAction)RequestButton:(id)sender;

@end
