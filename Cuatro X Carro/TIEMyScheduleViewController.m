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

@interface TIEMyScheduleViewController (){
    //Se declara variable de utilidades
    Util *util;
    BOOL reloadScroll;
}

@end

@implementation TIEMyScheduleViewController

@synthesize selectedDepartTime, selectedReturnTime,mondayDepartTime,tuesdayDepartTime,wednesdayDepartTime,thursdayDepartTime,fridayDepartTime,saturdayDepartTime,mondayReturnTime,tuesdayReturnTime,wednesdayReturnTime,thursdayReturnTime,fridayReturnTime,saturdayReturnTime, schedule, radioButton, departRB, returnRB, departReturnRB, spinnerSaveEvent, scroll, dayButtonSelect, departTimeButtonSelect, returnTimeButtonSelect;

- (void)viewDidLoad {
    [super viewDidLoad];
    reloadScroll = YES;
    [scroll setDelegate:self];
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

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(reloadScroll){
        reloadScroll = NO;
        CGRect sizeRect=[[UIScreen mainScreen] bounds];
        if(sizeRect.size.height == 480){
            [scroll setScrollEnabled:YES];
            [scroll setContentSize:CGSizeMake(sizeRect.size.width, 510)];
        }else{
            [scroll setScrollEnabled:NO];
        }
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
        [sender setTitle:selectedValue forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *dayItems = [NSArray arrayWithObjects:@"Lunes", @"Martes", @"Miercoles", @"Jueves", @"Viernes", nil];
    NSUInteger initialIndex = 0;
    UIButton *resultButton = (UIButton *)sender;
    if(![resultButton.currentTitle isEqualToString:@"Dia"] && [dayItems indexOfObject:resultButton.currentTitle] != -1){
        initialIndex = [dayItems indexOfObject:resultButton.currentTitle];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Día" rows:dayItems initialSelection:initialIndex
                                       doneBlock:done cancelBlock:cancel origin:sender];
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
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Hora de salida" datePickerMode:UIDatePickerModeTime selectedDate:self.selectedDepartTime target:self action:@selector(departedTimeWasSelected:element:) origin:sender];
    datePicker.minuteInterval = minuteInterval;
    [datePicker showActionSheetPicker];
}

-(void)departedTimeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.selectedDepartTime = selectedTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    [departTimeButtonSelect setTitle:[dateFormatter stringFromDate:selectedDepartTime] forState:UIControlStateNormal];
    [departTimeButtonSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Hora de regreso" datePickerMode:UIDatePickerModeTime selectedDate:self.selectedReturnTime target:self action:@selector(returnTimeWasSelected:element:) origin:sender];
    datePicker.minuteInterval = minuteInterval;
    [datePicker showActionSheetPicker];
}

-(void)returnTimeWasSelected:(NSDate *)selectedTime element:(id)element {
    self.selectedReturnTime = selectedTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    [returnTimeButtonSelect setTitle:[dateFormatter stringFromDate:selectedReturnTime] forState:UIControlStateNormal];
    [returnTimeButtonSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
        [returnTimeButtonSelect setHidden:YES];
        [departTimeButtonSelect setHidden:NO];
    }
    else if([returnRB isSelected]){
        [departTimeButtonSelect setHidden:YES];
        [returnTimeButtonSelect setHidden:NO];
    }
    else{
        [returnTimeButtonSelect setHidden:NO];
        [departTimeButtonSelect setHidden:NO];
    }
    [self clearCombos];
}

#pragma Horario
- (IBAction) setDayTime:(id)sender {
    
    //Convertir hora de ida a hora militar
    NSString *AMPMDepartTime = [departTimeButtonSelect currentTitle];
    NSString *militaryDepartTime = [util ampmTimeToMilitaryTime:AMPMDepartTime];
    
    //Convertir hora de vuelta a hora militar
    NSString *AMPMReturnTime = [self.returnTimeButtonSelect currentTitle];
    NSString *militaryReturnTime = [util ampmTimeToMilitaryTime:AMPMReturnTime];
    
    if ([[self.dayButtonSelect currentTitle] isEqualToString:@"Lunes"]) {
        if (![departTimeButtonSelect isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"monday_going"];
            mondayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeButtonSelect isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"monday_return"];
            mondayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayButtonSelect currentTitle] isEqualToString:@"Martes"]) {
        if (![departTimeButtonSelect isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"tuesday_going"];
            tuesdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeButtonSelect isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"tuesday_return"];
            tuesdayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayButtonSelect currentTitle] isEqualToString:@"Miercoles"]) {
        if (![departTimeButtonSelect isHidden]) {
        [schedule setValue:militaryDepartTime forKey:@"wednesday_going"];
        wednesdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeButtonSelect isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"wednesday_return"];
            wednesdayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayButtonSelect currentTitle] isEqualToString:@"Jueves"]) {
        if (![departTimeButtonSelect isHidden]) {
        [schedule setValue:militaryDepartTime forKey:@"thursday_going"];
        thursdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeButtonSelect isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"thursday_return"];
            thursdayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayButtonSelect currentTitle] isEqualToString:@"Viernes"]) {
        if (![departTimeButtonSelect isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"friday_going"];
            fridayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeButtonSelect isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"friday_return"];
            fridayReturnTime.text = AMPMReturnTime;
        }
    }
    else if ([[self.dayButtonSelect currentTitle] isEqualToString:@"Sabado"]) {
        if (![departTimeButtonSelect isHidden]) {
            [schedule setValue:militaryDepartTime forKey:@"saturday_going"];
            saturdayDepartTime.text = AMPMDepartTime;
        }
        if (![returnTimeButtonSelect isHidden]) {
            [schedule setValue:militaryReturnTime forKey:@"saturday_return"];
            saturdayReturnTime.text = AMPMReturnTime;
        }
    }
    
}

- (IBAction) clearTimeCombos:(id)sender {
    [self clearCombos];
}

- (void) clearCombos{
    [dayButtonSelect setTitle:@"Dia" forState:UIControlStateNormal];
    [departTimeButtonSelect setTitle:@"Hora ida" forState:UIControlStateNormal];
    [returnTimeButtonSelect setTitle:@"Hora regreso" forState:UIControlStateNormal];
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
