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

@interface TIEProfileViewController (){
    //Se declara variable de utilidades
    Util *util;
    NSMutableDictionary *userData;
}

@end

@implementation TIEProfileViewController

@synthesize profilePricture, rateOneIcon, rateTwoIcon, rateThreeIcon, rateFourIcon, rateFiveIcon, userName, userEmail, userPhone, schedule, mondayDepartTime, tuesdayDepartTime, wednesdayDepartTime, thursdayDepartTime, fridayDepartTime, saturdayDepartTime, mondayReturnTime,tuesdayReturnTime, wednesdayReturnTime, thursdayReturnTime, fridayReturnTime, saturdayReturnTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
- (IBAction)LogOut:(id)sender {
    //Se borran datos de usuario deslogueado
    NSUserDefaults *defaultProperties = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *emptyData = [[NSMutableDictionary alloc] init];
    [defaultProperties setObject:emptyData forKey:@"userData"];
    
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
    self.profilePricture.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
