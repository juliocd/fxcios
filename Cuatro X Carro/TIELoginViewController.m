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
#import "NSString+MD5.h"
#import "Util.h"
#import "RecoverPasswordViewController.h"

@interface TIELoginViewController (){
    int fieldNumber;
    int contField;
}

@end

@implementation TIELoginViewController

@synthesize usernameTextField, passwordTextField, userName, password, myView;

- (void)viewDidLoad {
    
    //Se definen variables que contralan aumento de campos en pantalla
    contField = 1;
    
    [self userHaveOpenSession];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) userHaveOpenSession{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
//    if (dataUser != nil) {
//        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//        [appDelegate.window setRootViewController:appDelegate.tabBarController];
//    }
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
    Util *util=[Util getInstance];
    
    //Se ejecuta validacion de usuario
    NSLog(@"Se inicia almacenamiento de usuario");
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/userLogin", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    
    if (![userName isEqualToString:@""] || ![[self.passwordTextField text] isEqualToString:@""]) {
        
        userName = [self.usernameTextField text];
        
        NSString *passwordTextFieldMD5 = [[self.passwordTextField text] MD5];
        password = [NSString stringWithFormat:@"%@%@",passwordTextFieldMD5, userName];
        password = [password MD5];
        
        //Se configura data a enviar
        NSString *post = [NSString stringWithFormat:
                          @"email=%@&password=%@",
                          userName,
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
                    //Se almacena datos de usuario
                    [util constructUserDefaults:jsonData];
                    //Se insctibe token de usuario en caso de tenerlo
                    [util userNotifications];
                    //Se carga vista principal
                    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                    [appDelegate.window setRootViewController:appDelegate.tabBarController];
                }
                else{
                    UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                              message:[jsonData valueForKey:@"description"]
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                    [alertErrorLogin show];
                }
            });
        }] resume];
        
    }
    else{
        UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                message:@"Existen campos obligatorios vacíos."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [alertErrorLogin show];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    contField++;
    [UIView animateWithDuration:0.15 animations:^
     {
         CGRect newFrame = [myView frame];
         newFrame.origin.y = -140;
         [myView setFrame:newFrame];
         
     }completion:^(BOOL finished)
     {
         
     }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.15 animations:^
     {
         CGRect newFrame = [myView frame];
         newFrame.origin.y = 0;
         [myView setFrame:newFrame];
         
     }completion:^(BOOL finished)
     {
         
     }];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)SingupButton:(id)sender {
    TIESingUpViewController *viewController = [[TIESingUpViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)ForgetPassword:(id)sender {
    RecoverPasswordViewController *viewController = [[RecoverPasswordViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}
@end
