//
//  TIEMyScheduleViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"

@interface TIEMyScheduleViewController : UIViewController

@property (nonatomic, strong) IBOutlet RadioButton* radioButton;
- (IBAction)onRadioBtn:(RadioButton*)sender;

@end
