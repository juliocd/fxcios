//
//  RecoverPasswordViewController.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 4/10/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "ViewController.h"

@interface RecoverPasswordViewController : ViewController

@property (weak, nonatomic) IBOutlet UITextField *userEmail;
- (IBAction)recoverPasswordButton:(id)sender;

@end