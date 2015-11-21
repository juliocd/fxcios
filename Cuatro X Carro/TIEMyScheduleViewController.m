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

@class AbstractActionSheetPicker;
@interface TIEMyScheduleViewController ()

@end

@implementation TIEMyScheduleViewController

@synthesize dayTextInput, departTimeTextInput, returnTimeTextInput, selectedDepartTime, selectedReturnTime,mondayDepartTime,tuesdayDepartTime,wednesdayDepartTime,thursdayDepartTime,fridayDepartTime,saturdayDepartTime,mondayReturnTime,tuesdayReturnTime,wednesdayReturnTime,thursdayReturnTime,fridayReturnTime,saturdayReturnTime, schedule;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Mi Horario";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    //Declaro delegados de campos, con el fin de que lo encuentren en la vista
    [self.dayTextInput delegate];
    [self.departTimeTextInput delegate];
    [self.returnTimeTextInput delegate];
    
    //Se inicializa calendario
    DefaultRequest *defaultRequest=[DefaultRequest getInstance];
    NSMutableDictionary *dataUser = [defaultRequest getUserDefault];
    schedule = [dataUser objectForKey:@"schedule"];
    if (schedule != nil && ![schedule isEqual:@""]) {
        [self loadSchedule];
    }
    else{
        schedule = [[NSMutableDictionary alloc] init];
    }
    
}

//Funcion que carga ultimo horario configurado en vista
-(void) loadSchedule{
    mondayDepartTime.text = [[schedule objectForKey:@"monday_going"] isEmpty] ? @"" : [schedule objectForKey:@"monday_going"];
    mondayReturnTime.text = [[schedule objectForKey:@"monday_return"] isEmpty] ? @"" : [schedule objectForKey:@"monday_return"];

    tuesdayDepartTime.text = [[schedule objectForKey:@"tuesday_going"] isEmpty] ? @"" : [schedule objectForKey:@"tuesday_going"];
    tuesdayReturnTime.text = [[schedule objectForKey:@"tuesday_return"] isEmpty] ? @"" : [schedule objectForKey:@"tuesday_return"];

    wednesdayDepartTime.text = [[schedule objectForKey:@"wednesday_going"] isEmpty] ? @"" : [schedule objectForKey:@"wednesday_going"];
    wednesdayReturnTime.text = [[schedule objectForKey:@"wednesday_return"] isEmpty] ? @"" : [schedule objectForKey:@"wednesday_return"];
    
    thursdayDepartTime.text = [[schedule objectForKey:@"thursday_going"] isEmpty] ? @"" : [schedule objectForKey:@"thursday_going"];
    thursdayReturnTime.text = [[schedule objectForKey:@"thursday_return"] isEmpty] ? @"" : [schedule objectForKey:@"thursday_return"];

    fridayDepartTime.text = [[schedule objectForKey:@"friday_going"] isEmpty] ? @"" : [schedule objectForKey:@"friday_going"];
    fridayReturnTime.text = [[schedule objectForKey:@"friday_return"] isEmpty] ? @"" : [schedule objectForKey:@"friday_return"];

    saturdayDepartTime.text = [[schedule objectForKey:@"saturday_going"] isEmpty] ? @"" : [schedule objectForKey:@"saturday_going"];
    saturdayReturnTime.text = [[schedule objectForKey:@"saturday_return"] isEmpty] ? @"" : [schedule objectForKey:@"saturday_return"];
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    NSArray *dayItems = [NSArray arrayWithObjects:@"Lunes", @"Martes", @"Miercoles", @"Jueves", @"Viernes", @"Sabado", nil];
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:dayItems initialSelection:0
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
}

- (IBAction) setDayTime:(id)sender {
    
    //Convertir hora de ida a hora militar
    NSString *AMPMDepartTime = [self.departTimeTextInput text];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *AMPMDepartTimeFormat = [dateFormatter dateFromString: AMPMDepartTime];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *militaryDepartTime = [dateFormatter stringFromDate:AMPMDepartTimeFormat];
    
    //Convertir hora de vuelta a hora militar
    NSString *AMPMReturnTime = [self.returnTimeTextInput text];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *AMPMReturnTimeFormat = [dateFormatter dateFromString: AMPMReturnTime];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *militaryReturnTime = [dateFormatter stringFromDate:AMPMReturnTimeFormat];
    
    if ([[self.dayTextInput text] isEqualToString:@"Lunes"]) {
        [schedule setValue:militaryDepartTime forKey:@"monday_going"];
        mondayDepartTime.text = AMPMDepartTime;
        [schedule setValue:militaryReturnTime forKey:@"monday_return"];
        mondayReturnTime.text = AMPMReturnTime;
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Martes"]) {
        [schedule setValue:militaryDepartTime forKey:@"tuesday_going"];
        tuesdayDepartTime.text = AMPMDepartTime;
        [schedule setValue:militaryReturnTime forKey:@"tuesday_return"];
        tuesdayReturnTime.text = AMPMReturnTime;
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Miercoles"]) {
        [schedule setValue:militaryDepartTime forKey:@"wednesday_going"];
        wednesdayDepartTime.text = AMPMDepartTime;
        [schedule setValue:militaryReturnTime forKey:@"wednesday_return"];
        wednesdayReturnTime.text = AMPMReturnTime;
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Jueves"]) {
        [schedule setValue:militaryDepartTime forKey:@"thursday_going"];
        thursdayDepartTime.text = AMPMDepartTime;
        [schedule setValue:militaryReturnTime forKey:@"thursday_return"];
        thursdayReturnTime.text = AMPMReturnTime;
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Viernes"]) {
        [schedule setValue:militaryDepartTime forKey:@"friday_going"];
        fridayDepartTime.text = AMPMDepartTime;
        [schedule setValue:militaryReturnTime forKey:@"friday_return"];
        fridayReturnTime.text = AMPMReturnTime;
    }
    else if ([[self.dayTextInput text] isEqualToString:@"Sabado"]) {
        [schedule setValue:militaryDepartTime forKey:@"saturday_going"];
        saturdayDepartTime.text = AMPMDepartTime;
        [schedule setValue:militaryReturnTime forKey:@"saturday_return"];
        saturdayReturnTime.text = AMPMReturnTime;
    }
    
}

- (IBAction) clearTimeCombos:(id)sender {
    
}

- (IBAction)saveSchedule:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
    
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:schedule options:0 error:nil];
    NSString *scheduleString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    
    NSString *urlServer = @"http://127.0.0.1:5000/saveSchedule";
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"schedule=%@&id=%@&tenant_id=%@",
                      scheduleString,
                      [dataUser objectForKey:@"id"],
                      [dataUser objectForKey:@"tenant_id"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //Se captura numero d eparametros a enviar
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
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
            
            NSString *message = @"Calendario almacenado correctamente.";
            if (!isValid ? [isValid boolValue] : NO) {
                message = [jsonData objectForKey:@"error"];
            }
            
            UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
            [alertSaveUser show];
        });
    }] resume];
    
}

- (IBAction)closeSchedule:(id)sender {
}

-(void) onRadioButtonValueChanged:(RadioButton*)sender
{
    // Lets handle ValueChanged event only for selected button, and ignore for deselected
    if(sender.selected) {
        NSLog(@"Selected color: %@", sender.titleLabel.text);
    }
}
@end
