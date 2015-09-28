//
//  TIELoginViewController.m
//  Cuatro X Carro
//
//  Created by Process On Line on 7/19/15.
//  Copyright (c) 2015 IT Economics SAS. All rights reserved.
//

#import "TIELoginViewController.h"
#import "TIESingUpViewController.h"
#import "AppDelegate.h"

@interface TIELoginViewController ()

@end

@implementation TIELoginViewController

@synthesize usernameTextField, passwordTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.usernameTextField delegate];
    [self.passwordTextField delegate];
}

//Ocultar keyboar con boton aceptar (Investigar respuesta)
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    return YES;
}

- (IBAction)LoginButton:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:appDelegate.tabBarController];
}

- (IBAction)SingupButton:(id)sender {
    TIESingUpViewController *viewController = [[TIESingUpViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}
@end
