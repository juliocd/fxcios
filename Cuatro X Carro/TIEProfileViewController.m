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

@interface TIEProfileViewController (){
    //Se declara variable de utilidades
    Util *util;
}

@end

@implementation TIEProfileViewController

@synthesize schedule, mondayDepartTime,tuesdayDepartTime,wednesdayDepartTime,thursdayDepartTime,fridayDepartTime,saturdayDepartTime,mondayReturnTime,tuesdayReturnTime,wednesdayReturnTime,thursdayReturnTime,fridayReturnTime,saturdayReturnTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
    
    //Se carga horario
    [self loadSchedule];
}

- (void) viewWillAppear:(BOOL)animated{
    [self loadSchedule];
}

//Funcion que carga ultimo horario configurado en vista
-(void) loadSchedule{
    
    //Se obtiene informacion de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
    //Se obtiene calendario
    NSString *strSchedule = [dataUser objectForKey:@"schedule"];
    schedule = [[NSMutableDictionary alloc] init];
    if (![strSchedule isEqual:@""]) {
        schedule = [NSJSONSerialization JSONObjectWithData:[strSchedule dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    mondayDepartTime.text = ([schedule valueForKey:@"monday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"monday_going"]];
    mondayReturnTime.text = ([schedule valueForKey:@"monday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"monday_return"]];
    
    tuesdayDepartTime.text = ([schedule valueForKey:@"tuesday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"tuesday_going"]];
    tuesdayReturnTime.text = ([schedule valueForKey:@"tuesday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"tuesday_return"]];
    
    wednesdayDepartTime.text = ([schedule valueForKey:@"wednesday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"wednesday_going"]];
    wednesdayReturnTime.text = ([schedule valueForKey:@"wednesday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"wednesday_return"]];
    
    thursdayDepartTime.text = ([schedule valueForKey:@"thursday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"thursday_going"]];    thursdayReturnTime.text = ([schedule valueForKey:@"thursday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"thursday_return"]];
    
    fridayDepartTime.text = ([schedule valueForKey:@"friday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"friday_going"]];
    fridayReturnTime.text = ([schedule valueForKey:@"friday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"friday_return"]];
    
    saturdayDepartTime.text = ([schedule valueForKey:@"saturday_going"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"saturday_going"]];
    saturdayReturnTime.text = ([schedule valueForKey:@"saturday_return"] == (id)[NSNull null]) ? @"" : [util militaryTimeToAMPMTime:[schedule valueForKey:@"saturday_return"]];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)EditProfile:(id)sender {
    TIESingUpViewController *singupVC = [[TIESingUpViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:singupVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)updateSchedue:(id)sender {
    TIEMyScheduleViewController *myScheduleVC = [[TIEMyScheduleViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:myScheduleVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}
@end
