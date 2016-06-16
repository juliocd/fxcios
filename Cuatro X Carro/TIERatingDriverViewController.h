//
//  TIERatingDriverViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 6/14/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "ViewController.h"
#import "TIEProfileViewController.h"

@interface TIERatingDriverViewController : ViewController

@property (weak, nonatomic) IBOutlet UIImageView *starOne;
@property (weak, nonatomic) IBOutlet UIImageView *starTwo;
@property (weak, nonatomic) IBOutlet UIImageView *starThree;
@property (weak, nonatomic) IBOutlet UIImageView *starFour;
@property (weak, nonatomic) IBOutlet UIImageView *starFive;

- (IBAction)SelectRating:(id)sender;
- (IBAction)SendRating:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
