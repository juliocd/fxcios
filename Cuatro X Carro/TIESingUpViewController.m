//
//  TIESingUpViewController.m
//  Cuatro X Carro
//
//  Created by Process On Line on 7/19/15.
//  Copyright (c) 2015 IT Economics SAS. All rights reserved.
//

#import "TIESingUpViewController.h"
#import "ActionSheetPicker.h"
#import "NSString+MD5.h"
#import "Util.h"

@class AbstractActionSheetPicker;
@interface TIESingUpViewController (){
    NSMutableDictionary *userData;
    NSURLSession *viewSession;
    Util *util;
    NSString *activePasswordStr;
}

@end

@implementation TIESingUpViewController

@synthesize countryTextInput, stateTextInput, cityTextInput, groupTextInput,
    fullUserNameTextInput, passwordTextInput, confirmPasswordTextInput, emailInput, groupHost,
    countryItems, stateItems, cityItems, groupItems, countryItemsIds, stateItemsIds, cityItemsIds, groupItemsIds, groupItemsDomains, saveButton, changePasswordButton, urlServer, spinnerLocationLoad;

- (id)initWithUserData:(NSMutableDictionary *) aUserData {
    self = [super initWithNibName:@"TIESingUpViewController" bundle:nil];
    if (self) {
        userData = aUserData;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Se inicializan variables y funciones
    util = [Util getInstance];
    activePasswordStr = @"";
    
    //Se crea sesion unica de conexiones
    viewSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
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
    
    //Se cargan datos de ubicacion geografica
    countryItems = [[NSMutableArray alloc] init];
    stateItems = [[NSMutableArray alloc] init];
    cityItems = [[NSMutableArray alloc] init];
    countryItemsIds = [[NSMutableDictionary alloc] init];
    stateItemsIds = [[NSMutableDictionary alloc] init];
    cityItemsIds = [[NSMutableDictionary alloc] init];
    [self loadGeograpichData];
    
    //Cargar grupos
    groupItems = [[NSMutableArray alloc] init];
    groupItemsIds = [[NSMutableDictionary alloc] init];
    groupItemsDomains = [[NSMutableDictionary alloc] init];
    [self loadGroups];
    
    if (userData != nil) {
        groupTextInput.textColor = [UIColor grayColor];
        fullUserNameTextInput.text = [userData valueForKey:@"name"];
        NSArray<NSString * > *emaiArr = [[userData valueForKey:@"email"] componentsSeparatedByString:@"@"];
        emailInput.text = emaiArr[0];
        emailInput.enabled = NO;
        emailInput.textColor = [UIColor grayColor];
        passwordTextInput.enabled = NO;
        passwordTextInput.text = @"xxxxx";
        passwordTextInput.textColor = [UIColor grayColor];
        confirmPasswordTextInput.hidden = YES;
        confirmPasswordTextInput.text = @"xxxxx";
        UIImage *buttonImage = [UIImage imageNamed:@"aceptar_boton.png"];
        [saveButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        changePasswordButton.hidden = NO;
    }
    
}

//Se cargan grupos
-(void) loadGroups{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://127.0.0.1:5000/queryAllTenants"]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
        dispatch_async(dispatch_get_main_queue(),^{
            
            //Se convierte respuesta en JSON
            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
            id isValid = [jsonData valueForKey:@"valid"];
            
            if (isValid ? [isValid boolValue] : NO) {
                NSArray *result = [jsonData objectForKey:@"result"];
                for (int k=0; k<[result count]; k++) {
                    NSDictionary *jsonGroup= result[k];
                    [groupItems addObject:[jsonGroup objectForKey:@"name"]];
                    [groupItemsIds setValue:[jsonGroup objectForKey:@"id"] forKey:[jsonGroup objectForKey:@"name"]];
                    [groupItemsDomains setValue:[jsonGroup objectForKey:@"domain"] forKey:[jsonGroup objectForKey:@"name"]];
                    
                    //Se actualiza grupo y dominio
                    if (userData != nil) {
                        if ([jsonGroup objectForKey:@"id"] == [userData objectForKey:@"tenant_id"]) {
                            groupTextInput.text = [jsonGroup objectForKey:@"name"];
                            [self.groupTextInput  setEnabled:NO];
                            groupHost.text = [jsonGroup objectForKey:@"domain"];
                        }
                    }
                }
            }
            else{
                UIAlertView *alertErrorConnectingServer = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                                     message:@"Error conectando a servidor. Verifique su estado de conexión a internet."
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                [alertErrorConnectingServer show];
            }
        });
    }] resume];
}

//Se recupera infromacion de datos geograficos
- (void) loadGeograpichData{
    [spinnerLocationLoad startAnimating];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://127.0.0.1:5000/queryAllAntioquiaInfo"]];
    [request setHTTPMethod:@"GET"];
    
    [[viewSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
        dispatch_async(dispatch_get_main_queue(),^{
            
            //Se convierte respuesta en JSON
            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
            id isValid = [jsonData valueForKey:@"valid"];
            
            if (isValid ? [isValid boolValue] : NO) {
                NSArray *result = [jsonData objectForKey:@"result"];
                NSDictionary *jsonCountry = result[0];
                [countryItems addObject:[jsonCountry objectForKey:@"name"]];
                [countryItemsIds setValue:[jsonCountry objectForKey:@"id"] forKey:[jsonCountry objectForKey:@"name"]];
                
                //Se actualiza pais
                if (userData != nil) {
                    countryTextInput.text = @"Colombia";
                    [self.countryTextInput  setEnabled:YES];
                }
                
                NSArray *states = [jsonCountry objectForKey:@"states"];
                if (userData != nil) {
                    //Se actualiza departamento
                    stateTextInput.text = @"Antioquia";
                    [self.stateTextInput  setEnabled:YES];
                }
                
                for (int i=0; i<[states count]; i++) {
                    NSDictionary *jsonState = states[i];
                    [stateItems addObject:[jsonState objectForKey:@"name"]];
                    [stateItemsIds setValue:[jsonState objectForKey:@"id"] forKey:[jsonState objectForKey:@"name"]];
                
                    NSArray *cities = [jsonState objectForKey:@"cities"];
                    for (int j=0; j<[cities count]; j++) {
                        NSDictionary *jsonCity= cities[j];
                        [cityItems addObject:[jsonCity objectForKey:@"name"]];
                        [cityItemsIds setValue:[jsonCity objectForKey:@"id"] forKey:[jsonCity objectForKey:@"name"]];
                    
                        //Se actualiza ciudad
                        if (userData != nil) {
                            if ([jsonCity objectForKey:@"id"] == [userData objectForKey:@"city_id"]) {
                                cityTextInput.text = [jsonCity objectForKey:@"name"];
                                [self.cityTextInput  setEnabled:YES];
                            }
                        }
                    }
                }
            }
            [spinnerLocationLoad stopAnimating];
            [spinnerLocationLoad setHidden:YES];
        });
    }] resume];
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
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:countryItems initialSelection:0
                                       doneBlock:done cancelBlock:cancel origin:sender];
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
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:stateItems initialSelection:0
                                       doneBlock:done cancelBlock:cancel origin:sender];
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
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:cityItems initialSelection:0
                                       doneBlock:done cancelBlock:cancel origin:sender];
    [self.cityTextInput  setEnabled:NO];
}

//Combo grupo
- (IBAction)selectGroup:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
            groupHost.text = [groupItemsDomains objectForKey:selectedValue];
        }
        [self.groupTextInput  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:groupItems initialSelection:0
                                       doneBlock:done cancelBlock:cancel origin:sender];
    [self.groupTextInput  setEnabled:NO];
}

#pragma Botones
- (IBAction)saveSingUpForm:(id)sender {
    
    //Se ejecuta almacenamiento de usuario
    NSLog(@"Se inicia almacenamiento de usuario");
    urlServer = @"http://127.0.0.1:5000/saveUser";
    NSLog(@"url saveUser: %@", urlServer);
    
    //Configurar password
    NSString *passwordTextField = [self.passwordTextInput text];
    NSString *passwordConfirmTextField = [self.confirmPasswordTextInput text];
    NSString *password = @"";
    
    //Se valida que los campos no esten vacios
    if (![[self.cityTextInput text] isEqualToString:@""] || ![[self.fullUserNameTextInput text] isEqualToString:@""]
        || ![[self.emailInput text] isEqualToString:@""] || ![[self.groupTextInput text] isEqualToString:@""]
        || ![[self.passwordTextInput text] isEqualToString:@""]) {
        //Se valida que las claves coincidan
        if ([passwordTextField isEqualToString:passwordConfirmTextField]) {
        
            NSString *email = [NSString stringWithFormat:@"%@%@",[self.emailInput text],[self.groupHost text]];
            NSString *userIdStr = [userData valueForKey:@"id"] == nil ? @"null" : [NSString stringWithFormat:@"%@", [userData valueForKey:@"id"]];
            
            if([activePasswordStr isEqualToString:@""]){
                if(![userIdStr isEqualToString:@"null"]){
                    password = [userData valueForKey:@"password"];
                }else{
                    NSString *passwordTextFieldMD5 = [passwordTextField MD5];
                    password = [NSString stringWithFormat:@"%@%@",passwordTextFieldMD5, email];
                    password = [password MD5];
                }
            }else{
                NSString *passwordTextFieldMD5 = [passwordTextField MD5];
                password = [NSString stringWithFormat:@"%@%@",passwordTextFieldMD5, email];
                password = [password MD5];
                password = [NSString stringWithFormat:@"%@%@",password, email];
                password = [password MD5];
            }
            
            //Se configura data a enviar
            NSString *post = [NSString stringWithFormat:
                        @"city_id=%ld&name=%@&email=%@&password=%@&tenant_id=%ld&id=%@",
                        [[cityItemsIds objectForKey:[self.cityTextInput text]] longValue],
                        [self.fullUserNameTextInput text],
                        email,
                        password,
                        [[groupItemsIds objectForKey:[self.groupTextInput text]] longValue],
                        userIdStr];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
            //Se captura numero d eparametros a enviar
            NSString *postLength = [NSString stringWithFormat:@"%lu", [postData length]];
        
            //Se configura request
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString: urlServer]];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:postData];
        
            //Se ejecuta request
            [[viewSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"requestReply: %@", requestReply);
                dispatch_async(dispatch_get_main_queue(),^{
                    [self responseSaveUser:requestReply withSecond: userIdStr];
                });
            }] resume];
            
        }
        else{
            UIAlertView *alertErrorPassword = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                            message:@"Las contraseñas no coinciden."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alertErrorPassword show];
        }
    }
    else{
        UIAlertView *alertEmptyField = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                     message:@"Existen campos obligatorios vacíos."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
        [alertEmptyField show];
    }

}

- (IBAction)changePassword:(id)sender {
    urlServer = @"http://127.0.0.1:5000/userLogin";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cambiar contraseña" message:@"Ingrese su contraseña actual" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              //Se configura data a enviar
              NSString *passwordTextFieldMD5 = [alert.textFields.firstObject.text MD5];
              NSString *password = [NSString stringWithFormat:@"%@%@",passwordTextFieldMD5, [userData valueForKey:@"email"]];
              password = [password MD5];
              NSString *post = [NSString stringWithFormat:
                                @"email=%@&password=%@",
                                [userData valueForKey:@"email"],
                                password];
              NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
              
              //Se captura numero de deparametros a enviar
              NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
              
              //Se configura request
              NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
              [request setURL:[NSURL URLWithString: urlServer]];
              [request setHTTPMethod:@"POST"];
              [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
              [request setHTTPBody:postData];
              
              //Se ejecuta request
              NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
              [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                  NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                  NSLog(@"requestReply: %@", requestReply);
                  dispatch_async(dispatch_get_main_queue(),^{
                      //Se convierte respuesta en JSON
                      NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                      NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
                      id isValid = [jsonData valueForKey:@"valid"];
                      
                      if (isValid ? [isValid boolValue] : NO) {
                          activePasswordStr = alert.textFields.firstObject.text;
                          emailInput.enabled = YES;
                          emailInput.textColor = [UIColor blackColor];
                          passwordTextInput.text = activePasswordStr;
                          confirmPasswordTextInput.text = activePasswordStr;
                          passwordTextInput.hidden = NO;
                          passwordTextInput.placeholder = @"Nueva contraseña";
                          passwordTextInput.enabled = YES;
                          passwordTextInput.textColor = [UIColor blackColor];
                          confirmPasswordTextInput.hidden = NO;
                          confirmPasswordTextInput.placeholder = @"Repetir nueva contraseña";
                          changePasswordButton.hidden = YES;
                      }
                      else{
                          UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                                    message:@"Contraseña invalida"
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil];
                          [alertErrorLogin show];
                      }
                  });
              }] resume];
          }]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *passwField) {
        passwField.placeholder = @"Contraseña";
        passwField.secureTextEntry = YES;
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) responseSaveUser: (NSString *) requestReply withSecond:(NSString *) userId {
    //Se convierte respuesta en JSON
    NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
    id isValid = [jsonData valueForKey:@"valid"];
    
    NSString *message = @"Usuario almacenado correctamente. Revise su correo para completar el registro.";
    if (!isValid ? [isValid boolValue] : NO) {
        message = [jsonData valueForKey:@"description"];
        [util updateUserDefaults];
    }else{
        if(![userId isEqualToString:@"null"]){
            message = @"Usuario actualizado correctamente.";
        }
    }
    
    UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
    [alertSaveUser show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
