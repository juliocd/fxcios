//
//  TIESingUpViewController.h
//  Cuatro X Carro
//
//  Created by Process On Line on 7/19/15.
//  Copyright (c) 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIESingUpViewController : UIViewController <UITextFieldDelegate>

- (id)initWithUserData:(NSMutableDictionary *) aUserData;

- (IBAction)selectCountry:(id)sender;
- (IBAction)selectState:(id)sender;
- (IBAction)selectCity:(id)sender;
- (IBAction)selectGroup:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *countryTextInput;
@property (weak, nonatomic) IBOutlet UITextField *stateTextInput;
@property (weak, nonatomic) IBOutlet UITextField *cityTextInput;
@property (weak, nonatomic) IBOutlet UITextField *groupTextInput;
@property (weak, nonatomic) IBOutlet UITextField *fullUserNameTextInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextInput;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextInput;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UILabel *groupHost;

- (IBAction)saveSingUpForm:(id)sender;

@property (strong, nonatomic) NSMutableArray *countryItems;
@property (strong, nonatomic) NSMutableArray *stateItems;
@property (strong, nonatomic) NSMutableArray *cityItems;
@property (strong, nonatomic) NSMutableArray *groupItems;
@property (strong, nonatomic) NSMutableDictionary *countryItemsIds;
@property (strong, nonatomic) NSMutableDictionary *stateItemsIds;
@property (strong, nonatomic) NSMutableDictionary *cityItemsIds;
@property (strong, nonatomic) NSMutableDictionary *groupItemsIds;
@property (strong, nonatomic) NSMutableDictionary *groupItemsDomains;

@end
