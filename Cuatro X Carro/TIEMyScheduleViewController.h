//
//  TIEMyScheduleViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"

@class AbstractActionSheetPicker;
@interface TIEMyScheduleViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSDate *selectedDepartTime, *selectedReturnTime;
@property (nonatomic, strong) NSMutableDictionary *schedule;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;

@property (nonatomic, strong) IBOutlet RadioButton* radioButton;
@property (weak, nonatomic) IBOutlet RadioButton *departRB;
@property (weak, nonatomic) IBOutlet RadioButton *returnRB;
@property (weak, nonatomic) IBOutlet RadioButton *departReturnRB;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerSaveEvent;

- (IBAction)selectDay:(id)sender;
- (IBAction)selectDepartTime:(id)sender;
- (IBAction)selectReturnTime:(id)sender;

//Select de horas
@property (weak, nonatomic) IBOutlet UIButton *dayButtonSelect;
@property (weak, nonatomic) IBOutlet UIButton *departTimeButtonSelect;
@property (weak, nonatomic) IBOutlet UIButton *returnTimeButtonSelect;

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

- (IBAction)onRadioBtn:(RadioButton*)sender;

- (IBAction)setDayTime:(id)sender;

- (IBAction)clearTimeCombos:(id)sender;

@end
