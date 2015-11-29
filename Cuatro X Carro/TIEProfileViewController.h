//
//  TIEProfileViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIEProfileViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *schedule;

- (IBAction)EditProfile:(id)sender;
- (IBAction)updateSchedue:(id)sender;

//Hora ida
@property (weak, nonatomic) IBOutlet UILabel *mondayDepartTime;
@property (weak, nonatomic) IBOutlet UILabel *tuesdayDepartTime;
@property (weak, nonatomic) IBOutlet UILabel *wednesdayDepartTime;
@property (weak, nonatomic) IBOutlet UILabel *thursdayDepartTime;
@property (weak, nonatomic) IBOutlet UILabel *fridayDepartTime;
@property (weak, nonatomic) IBOutlet UILabel *saturdayDepartTime;

//Hora regreso
@property (weak, nonatomic) IBOutlet UILabel *mondayReturnTime;
@property (weak, nonatomic) IBOutlet UILabel *tuesdayReturnTime;
@property (weak, nonatomic) IBOutlet UILabel *wednesdayReturnTime;
@property (weak, nonatomic) IBOutlet UILabel *thursdayReturnTime;
@property (weak, nonatomic) IBOutlet UILabel *fridayReturnTime;
@property (weak, nonatomic) IBOutlet UILabel *saturdayReturnTime;

@end
