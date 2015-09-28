//
//  TIESingUpViewController.m
//  Cuatro X Carro
//
//  Created by Process On Line on 7/19/15.
//  Copyright (c) 2015 IT Economics SAS. All rights reserved.
//

#import "TIESingUpViewController.h"
#import "ActionSheetPicker.h"

@class AbstractActionSheetPicker;
@interface TIESingUpViewController ()

@end

@implementation TIESingUpViewController

@synthesize countryTextInput, stateTextInput, cityTextInput, groupTextInput, fullUserNameTextInput, passwordTextInput, confirmPasswordTextInput, emailInput, groupHost;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Registro";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    //Declaro delegados de campos, con el fin de que lo encuentren en la vista
    [self.countryTextInput delegate];
    [self.stateTextInput delegate];
    [self.cityTextInput delegate];
    [self.groupTextInput delegate];
    [self.fullUserNameTextInput delegate];
    [self.passwordTextInput delegate];
    [self.confirmPasswordTextInput delegate];
    [self.emailInput delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//Ocultar keyboar con boton aceptar (Investigar respuesta)
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.fullUserNameTextInput resignFirstResponder];
    [self.passwordTextInput resignFirstResponder];
    [self.confirmPasswordTextInput resignFirstResponder];
    [self.emailInput resignFirstResponder];
    return YES;
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma Combos
//Combo pais
- (IBAction)selectCountry:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
        [self.countryTextInput  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *colors = @[@"Colombia", @"Ecuador", @"Panama", @"Brasil"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:colors initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    [self.countryTextInput setEnabled:NO];
}

//Combo departamento
- (IBAction)selectState:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
        [self.stateTextInput  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *colors = @[@"Cordoba", @"Choco", @"Antioquia", @"Amazonas"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:colors initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    [self.stateTextInput  setEnabled:NO];
}

//Combo ciudad
- (IBAction)selectCity:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
        [self.cityTextInput  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *colors = @[@"Medellin", @"Monteria", @"Leticia", @"Quibdo"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:colors initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    [self.cityTextInput  setEnabled:NO];
}

//Combo grupo
- (IBAction)selectGroup:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
            groupHost.text = [NSString stringWithFormat:@"%@",selectedValue];
        }
        [self.groupTextInput  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *colors = @[@"Universidad de Antioaquia", @"EAFIT", @"Universidoad Nacional", @"CES"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:colors initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    [self.groupTextInput  setEnabled:NO];
}

#pragma Botones
- (IBAction)saveSingUpForm:(id)sender {
    UIAlertView *alertSave = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                    message:@"Usuario guardado correctamente. Revise su correo para completar el registro."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alertSave show];
}
@end
