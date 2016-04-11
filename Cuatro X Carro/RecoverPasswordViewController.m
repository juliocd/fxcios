//
//  RecoverPasswordViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 4/10/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "RecoverPasswordViewController.h"

@interface RecoverPasswordViewController ()

@end

@implementation RecoverPasswordViewController

@synthesize userEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Rec. Contraseña";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)recoverPasswordButton:(id)sender {
    
    //Se ejecuta validacion de usuario
    NSLog(@"Se inicia almacenamiento de usuario");
    NSString *urlServer = @"http://127.0.0.1:5000/recoverPassword";
    NSLog(@"url saveUser: %@", urlServer);
    
    NSString *email = userEmail.text;
    
    if (![userEmail.text isEqualToString:@""]) {
        
        //Se configura data a enviar
        NSString *post = [NSString stringWithFormat:
                          @"email=%@",
                          email];
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
                
                NSString *message = @"Solicitud procesada exitosamente. Revise su correo electrónico para continuar con el proceso";
                if (!(isValid ? [isValid boolValue] : NO)) {
                    message = [jsonData valueForKey:@"description"];
                }
                UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                          message:message
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                [alertErrorLogin show];
            });
        }] resume];
        
    }
    else{
        UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                  message:@"Debe ingresar un correo electónico."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [alertErrorLogin show];
    }
    
}
@end
