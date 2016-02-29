//
//  TIETravelCustomCellTableViewCell.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIETravelCustomCellTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TIETravelCustomCellTableViewCell

@synthesize userPictureImage, dateDayLabel, dateMonthLabel,dateYearLabel, seatsAvailableLabel, timeLabel;

- (void)awakeFromNib {
    //Estilo de imagen
    userPictureImage.layer.cornerRadius = userPictureImage.frame.size.width / 2;
    userPictureImage.clipsToBounds = YES;
    //Estilo de etiquetas
    dateDayLabel.layer.masksToBounds = YES;
    dateDayLabel.layer.borderWidth = 1.0;
    dateDayLabel.layer.cornerRadius = 5;
    dateDayLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    dateMonthLabel.layer.masksToBounds = YES;
    dateMonthLabel.layer.borderWidth = 1.0;
    dateMonthLabel.layer.cornerRadius = 5;
    dateMonthLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    dateYearLabel.layer.masksToBounds = YES;
    dateYearLabel.layer.borderWidth = 1.0;
    dateYearLabel.layer.cornerRadius = 5;
    dateYearLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    dateDayLabel.layer.masksToBounds = YES;
    dateDayLabel.layer.borderWidth = 1.0;
    dateDayLabel.layer.cornerRadius = 5;
    dateDayLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    seatsAvailableLabel.layer.masksToBounds = YES;
    seatsAvailableLabel.layer.borderWidth = 1.0;
    seatsAvailableLabel.layer.cornerRadius = 5;
    seatsAvailableLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    timeLabel.layer.masksToBounds = YES;
    timeLabel.layer.borderWidth = 1.0;
    timeLabel.layer.cornerRadius = 5;
    timeLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)NotificationButton:(id)sender {
}

- (IBAction)RequestButton:(id)sender {
}
@end
