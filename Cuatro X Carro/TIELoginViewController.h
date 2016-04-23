//
//  TIELoginViewController.h
//  Cuatro X Carro
//
//  Created by Process On Line on 7/19/15.
//  Copyright (c) 2015 IT Economics SAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIELoginViewController : UIViewController

- (IBAction)LoginButton:(id)sender;
- (IBAction)SingupButton:(id)sender;
- (IBAction)ForgetPassword:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *myView;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;


@end
