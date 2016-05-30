//
//  TIEProfileViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIEProfileViewController.h"
#import "TIESingUpViewController.h"
#import "TIEMyScheduleViewController.h"
#import "Util.h"
#import "AppDelegate.h"
#import "TIELoginViewController.h"
#import "ActionSheetPicker.h"
#import "TIEStatisticsViewController.h"

@interface TIEProfileViewController (){
    //Se declara variable de utilidades
    Util *util;
    NSMutableDictionary *userData;
}

@end

@implementation TIEProfileViewController

@synthesize profilePricture, rateOneIcon, rateTwoIcon, rateThreeIcon, rateFourIcon, rateFiveIcon, userName, userEmail, userPhone, schedule, mondayDepartTime, tuesdayDepartTime, wednesdayDepartTime, thursdayDepartTime, fridayDepartTime, saturdayDepartTime, mondayReturnTime,tuesdayReturnTime, wednesdayReturnTime, thursdayReturnTime, fridayReturnTime, saturdayReturnTime, scroll;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Se habilita scroll para pantalla de 3.5
    CGRect sizeRect=[[UIScreen mainScreen] bounds];
    if(sizeRect.size.height == 624){
        [scroll setScrollEnabled:YES];
        [scroll setContentSize:CGSizeMake(320, 624)];
    }else{
        [scroll setContentSize:CGSizeMake(sizeRect.size.width, sizeRect.size.height)];
    }
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
}

- (void) viewWillAppear:(BOOL)animated{
    
    //Se obtiene informacion de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userData = [defaults objectForKey:@"userData"];
    
    //Se actualiza informacion de usuario
    [self loadUserRate:[userData valueForKey:@"rating"] == nil ? [[userData valueForKey:@"rating"] intValue] : 0];
    userName.text = [userData valueForKey:@"name"];
    userEmail.text = [userData valueForKey:@"email"];
    if([userData valueForKey:@"profile_picture_url"] != nil){
        NSURL *url = [NSURL URLWithString:[userData valueForKey:@"profile_picture_url"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        self.profilePricture.image = img;
    }else{
        self.profilePricture.image = [UIImage imageNamed:@"image_perfil_1.png"];
    }
    //userPhone.text = [userData valueForKey:@"phone"];
    
    //Estilo de imagen de perfil
    profilePricture.layer.cornerRadius = profilePricture.frame.size.width / 2;
    profilePricture.clipsToBounds = YES;
    
    //Se actualiza horario
    [self loadSchedule];
}

//Funcion que carga ultimo horario configurado en vista
-(void) loadSchedule{
    
    //Se obtiene calendario
    NSString *strSchedule = [userData objectForKey:@"schedule"];
    schedule = [[NSMutableDictionary alloc] init];
    if (![strSchedule isEqual:@""]) {
        schedule = [NSJSONSerialization JSONObjectWithData:[strSchedule dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    mondayDepartTime.text = ([schedule valueForKey:@"monday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"monday_going"]];
    mondayReturnTime.text = ([schedule valueForKey:@"monday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"monday_return"]];
    
    tuesdayDepartTime.text = ([schedule valueForKey:@"tuesday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"tuesday_going"]];
    tuesdayReturnTime.text = ([schedule valueForKey:@"tuesday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"tuesday_return"]];
    
    wednesdayDepartTime.text = ([schedule valueForKey:@"wednesday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"wednesday_going"]];
    wednesdayReturnTime.text = ([schedule valueForKey:@"wednesday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"wednesday_return"]];
    
    thursdayDepartTime.text = ([schedule valueForKey:@"thursday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"thursday_going"]];
    thursdayReturnTime.text = ([schedule valueForKey:@"thursday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"thursday_return"]];
    
    fridayDepartTime.text = ([schedule valueForKey:@"friday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"friday_going"]];
    fridayReturnTime.text = ([schedule valueForKey:@"friday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"friday_return"]];
    
    saturdayDepartTime.text = ([schedule valueForKey:@"saturday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"saturday_going"]];
    saturdayReturnTime.text = ([schedule valueForKey:@"saturday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"saturday_return"]];
        
    }
    else{
        mondayDepartTime.text = @"";
        mondayReturnTime.text = @"";
        tuesdayDepartTime.text = @"";
        tuesdayReturnTime.text = @"";
        wednesdayDepartTime.text = @"";
        wednesdayReturnTime.text = @"";
        thursdayDepartTime.text = @"";
        thursdayReturnTime.text = @"";
        fridayDepartTime.text = @"";
        fridayReturnTime.text = @"";
        saturdayDepartTime.text = @"";
        saturdayReturnTime.text = @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)EditProfile:(id)sender {
    TIESingUpViewController *singupVC = [[TIESingUpViewController alloc] initWithUserData:userData];
    UINavigationController *trasformerNavC = [[UINavigationController alloc] initWithRootViewController:singupVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)updateSchedue:(id)sender {
    TIEMyScheduleViewController *myScheduleVC = [[TIEMyScheduleViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc] initWithRootViewController:myScheduleVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)passengerStatistics:(id)sender {
    TIEStatisticsViewController *myStatisticsVC = [[TIEStatisticsViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc] initWithRootViewController:myStatisticsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)LogOut:(id)sender {
    //Se elimina token de base de datos
    [util userNotifications: @"true"];
    //Se borran datos de usuario deslogueado
    NSUserDefaults *defaultProperties = [NSUserDefaults standardUserDefaults];
    [defaultProperties setObject:nil forKey:@"userData"];
    
    //Se envia a primera vista
    [self.tabBarController setSelectedIndex:0];
    
    //Se actualiza raiz de app a login
    TIELoginViewController *loginVC = [[TIELoginViewController alloc]init];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:loginVC];
}

- (void) loadUserRate:(int) rating{
    int starCont = 0;
    for (int i=0; i<5; i++) {
        starCont++;
        Boolean loadStar = true;
        if (starCont > rating) {
            loadStar = false;
        }
        switch (i) {
            case 0:
                if(loadStar){
                    [rateOneIcon setImage:[UIImage imageNamed:@"rate_full.png"]];
                }
                else{
                    [rateOneIcon setImage:[UIImage imageNamed:@"rate_empty.png"]];
                }
                break;
            case 1:
                if(loadStar){
                    [rateTwoIcon setImage:[UIImage imageNamed:@"rate_full.png"]];
                }
                else{
                    [rateTwoIcon setImage:[UIImage imageNamed:@"rate_empty.png"]];
                }
                break;
            case 2:
                if(loadStar){
                    [rateThreeIcon setImage:[UIImage imageNamed:@"rate_full.png"]];
                }
                else{
                    [rateThreeIcon setImage:[UIImage imageNamed:@"rate_empty.png"]];
                }
                break;
            case 3:
                if(loadStar){
                    [rateFourIcon setImage:[UIImage imageNamed:@"rate_full.png"]];
                }
                else{
                    [rateFourIcon setImage:[UIImage imageNamed:@"rate_empty.png"]];
                }
                break;
            case 4:
                if(loadStar){
                    [rateFiveIcon setImage:[UIImage imageNamed:@"rate_full.png"]];
                }
                else{
                    [rateFiveIcon setImage:[UIImage imageNamed:@"rate_empty.png"]];
                }
                break;
                
            default:
                break;
        }
    }
}

#pragma Manejador de evento par aimagen de perfil


- (IBAction) PictureOptions:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if([selectedValue isEqualToString:@"Cargar imagen"]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:NULL];
        }else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        }
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    
    NSArray *dayItems = [NSArray arrayWithObjects:@"Tomar foto", @"Cargar imagen", @"Cancelar", nil];
    [ActionSheetStringPicker showPickerWithTitle:@"Tipo de viaje" rows:dayItems initialSelection:0
                                       doneBlock:done cancelBlock:cancel origin:sender];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    NSString *strEncoded = [UIImageJPEGRepresentation(selectedImage, 0.3) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    strEncoded = [strEncoded stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    //Se envia imagen aservidor
    NSString *urlServer = [NSString stringWithFormat:@"%@/upload", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    //Se configura data a enviar
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:userData options:0 error:nil];
    NSString *userDataStr = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:
                      @"file=%@&user=%@",
                      strEncoded, [NSString stringWithFormat:@"%@", userDataStr]];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    //Se captura numero d eparametros a enviar
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
        dispatch_async(dispatch_get_main_queue(),^{
            //Se convierte respuesta en JSON
            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
            id isValid = [jsonData valueForKey:@"valid"];
            
            if (isValid ? [isValid boolValue] : NO) {
                NSMutableDictionary *userUpdateData = [jsonData valueForKey:@"data"];
                NSString *resultUrlImage = [userUpdateData valueForKey:@"profile_picture_url"];
                NSURL *url = [NSURL URLWithString:resultUrlImage];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img = [[UIImage alloc] initWithData:data];
                self.profilePricture.image = img;
                [util updateUserDefaults:^(bool result){}];
            }
            else{
                UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                        message:[jsonData valueForKey:@"description"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                [alertSaveUser show];
            }
        });
    }] resume];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
