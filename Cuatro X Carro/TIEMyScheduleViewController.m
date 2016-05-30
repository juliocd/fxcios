//
//  TIEMyScheduleViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIEMyScheduleViewController.h"
#import "RadioButton.h"
#import "ActionSheetPicker.h"
#import "DefaultRequest.h"
#import "Util.h"

@class AbstractActionSheetPicker;
@interface TIEMyScheduleViewController (){
    //Se declara variable de utilidades
    Util *util;
}

@end

@implementation TIEMyScheduleViewController

@synthesize dayTextInput, departTimeTextInput, returnTimeTextInput, selectedDepartTime, selectedReturnTime,mondayDepartTime,tuesdayDepartTime,wednesdayDepartTime,thursdayDepartTime,fridayDepartTime,saturdayDepartTime,mondayReturnTime,tuesdayReturnTime,wednesdayReturnTime,thursdayReturnTime,fridayReturnTime,saturdayReturnTime, schedule, radioButton, departRB, returnRB, departReturnRB, spinnerSaveEvent;

- (void)viewDidLoad {
    [super viewDidLoad];
    spinnerSaveEvent.hidden = YES;
    self.navigationController.navigationBar.topItem.title = @"Mi Horario";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
    
    //Declaro delegados de campos, con el fin de que lo encuentren en la vista
    [self.dayTextInput delegate];
    [self.departTimeTextInput delegate];
    [self.returnTimeTextInput delegate];
    
    //Se inicializa calendario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
    NSString *strSchedule = [dataUser objectForKey:@"schedule"];
    schedule = [[NSMutableDictionary alloc] init];
    if (![strSchedule isEqual:@""]) {
        schedule = [NSJSONSerialization JSONObjectWithData:[strSchedule dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        [self loadSchedule];
    }
}

//Funcion que carga ultimo horario configurado en vista
-(void) loadSchedule{
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

//Personalizar boton atras
-(void)backButton{
    [self saveUserSchedule];
}

#pragma Combos
//Combo dia
- (IBAction)selectDay:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
        [self.dayTextInput  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *dayItems = [NSArray arrayWithObjects:@"Lunes", @"Martes", @"Miercoles", @"Jueves", @"Viernes", nil];
    NSUInteger initialIndex = 0;
    if(![self.dayTextInput.text isEqualToString:@""] && [dayItems indexOfObject:self.dayTextInput.text] != -1){
        initialIndex = [dayItems indexOfObject:self.dayTextInput.text];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Día" rows:dayItems initialSelection:initialIndex
                                       doneBlock:done cancelBlock:cancel origin:sender];
    [self.dayTextInput setEnabled:NO];
}

//Combo hora de ida
- (IBAction)selectDepartTime:(id)sender {
    NSInteger minuteInterval = 5;
    //clamp date
    NSInteger referenceTimeInterval = (NSInteger)[self.selectedDepartTime timeIntervalSinceReferenceDate];
    NSInteger remainingSeconds = referenceTimeInterval % (minuteInterval *60);
    NSInteger timeRoundedTo5Minutes = referenceTimeInterval - remainingSeconds;
    if(remainingSeconds>((minuteInterval*60)/2)) {/// round up
        timeRoundedTo5Minutes = referenceTimeInterval +((minuteInterval*60)-remainingSeconds);
    }
    
    self.selectedDepartTime = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)timeRoundedTo5Minutes];
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:self.selectedDepartTime target:self action:@selector(departedTimeWasSelected:element:) origin:sender];
    datePicker.minuteInterval = minuteInterval;
    [datePicker showActionSheetPicker];
    [self.departTimeTextInput setEnabled:NO];
}

-(void)departedTimeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.selectedDepartTime = selectedTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    self.departTimeTextInput.text = [dateFormatter stringFromDate:selectedDepartTime];
    [self.departTimeTextInput setEnabled:YES];
}

//Combo hora de regreso
- (IBAction)selectReturnTime:(id)sender {
    NSInteger minuteInterval = 5;
    //clamp date
    NSInteger referenceTimeInterval = (NSInteger)[self.selectedReturnTime timeIntervalSinceReferenceDate];
    NSInteger remainingSeconds = referenceTimeInterval % (minuteInterval *60);
    NSInteger timeRoundedTo5Minutes = referenceTimeInterval - remainingSeconds;
    if(remainingSeconds>((minuteInterval*60)/2)) {/// round up
        timeRoundedTo5Minutes = referenceTimeInterval +((minuteInterval*60)-remainingSeconds);
    }
    
    self.selectedReturnTime = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)timeRoundedTo5Minutes];
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a time" datePickerMode:UIDatePickerModeTime selectedDate:self.selectedReturnTime target:self action:@selector(returnTimeWasSelected:element:) origin:sender];
    datePicker.minuteInterval = minuteInterval;
    [datePicker showActionSheetPicker];
    [self.returnTimeTextInput setEnabled:NO];
}

-(void)returnTimeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.selectedReturnTime = selectedTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    self.returnTimeTextInput.text = [dateFormatter stringFromDate:selectedReturnTime];
    [self.returnTimeTextInput setEnabled:YES];
}

-(void)dateSelector
{
    NSLog(@"SELECTOR");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Radiobutton
- (IBAction) onRadioBtn:(id)sender {
    if ([departRB isSelected]) {
        [returnTimeTextInput setHidden:YES];
        [departTimeTextInput setHidden:NO];
    }
    else if([returnRB isSelected]){
        [departTimeTextInput setHidden:YES];
        [returnTimeTextInput setHidden:NO];
    }
    else{
        [returnTimeTextInput setHidden:NO];
        [departTimeTextInput setHidden:NO];
    }
    [self clearCombos];
}

#pragma Horario
- (IBAction) setDayTime:(id)sender {
    
    //Convertir hora de ida a hora militar
    NSString *AMPMDepartTime = [self.departTimeTextInput text];
    NSString *militaryDepartTime = [util ampmTimeToMilitaryTime:AMPMDepartTime];
    
    //Convertir hora de vuelta a hora militar
    NSString *AMPMReturnTime = [self.returnTimeTextInput text];
    NSString *militaryReturnTime = [util ampmTimeToMilitaryTime:AMPMReturnTime];
    
    if ([[self.dayTextInput text] isEqualToString:@"Lunes"]) {
        if (![departTimeTextInput isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"monday_going"];
            mondayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeTextInput isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"monday_return"];
            mondayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Martes"]) {
        if (![departTimeTextInput isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"tuesday_going"];
            tuesdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeTextInput isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"tuesday_return"];
            tuesdayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Miercoles"]) {
        if (![departTimeTextInput isHidden]) {
        [schedule setValue:militaryDepartTime forKey:@"wednesday_going"];
        wednesdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeTextInput isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"wednesday_return"];
            wednesdayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Jueves"]) {
        if (![departTimeTextInput isHidden]) {
        [schedule setValue:militaryDepartTime forKey:@"thursday_going"];
        thursdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeTextInput isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"thursday_return"];
            thursdayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Viernes"]) {
        if (![departTimeTextInput isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"friday_going"];
            fridayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeTextInput isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"friday_return"];
            fridayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Sabado"]) {
        if (![departTimeTextInput isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"saturday_going"];
            saturdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeTextInput isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"saturday_return"];
            saturdayReturnTime.text = AMPMReturnTime;
        }
    }
    
}

- (IBAction) clearTimeCombos:(id)sender {
    [self clearCombos];
}

- (void) clearCombos{
    dayTextInput.text = @"";
    departTimeTextInput.text = @"";
    returnTimeTextInput.text = @"";
}

- (IBAction)saveSchedule:(id)sender {
    //Se oculto por peticion de disenadores.
}

-(void) saveUserSchedule{
    
    spinnerSaveEvent.hidden = NO;
    [spinnerSaveEvent startAnimating];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
    
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:schedule options:0 error:nil];
    NSString *scheduleString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/saveSchedule", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"schedule=%@&id=%@&tenant_id=%@",
                      scheduleString,
                      [dataUser objectForKey:@"id"],
                      [dataUser objectForKey:@"tenant_id"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //Se captura numero de parametros a enviar
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
            [spinnerSaveEvent stopAnimating];
            
            //Se convierte respuesta en JSON
            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
            id isValid = [jsonData valueForKey:@"valid"];
            
            NSString *message = @"Calendario almacenado correctamente.";
            if (!isValid ? [isValid boolValue] : NO) {
                message = [jsonData objectForKey:@"error"];
            }
            else{
                [util updateUserDefaults:^(bool result){
                    if(result){
                        UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                                message:message
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                        [alertSaveUser show];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else{
                        UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                                message:@"Error actualizando informacion de usuario."
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                        [alertSaveUser show];
                    }
                }];
            }
        });
    }] resume];
}
@end
