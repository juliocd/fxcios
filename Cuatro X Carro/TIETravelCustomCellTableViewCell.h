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
@property (weak, nonatomic) IBOutlet UIImageView *seatOneImage;
@property (weak, nonatomic) IBOutlet UIImageView *SeatTwoImage;
@property (weak, nonatomic) IBOutlet UIImageView *SeatThreeImage;
@property (weak, nonatomic) IBOutlet UIImageView *SeatFourImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rateOneImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateTwoImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateThreeImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateFourImage;
@property (weak, nonatomic) IBOutlet UIImageView *rateFiveImage;


- (IBAction)NotificationButton:(id)sender;

@end
