//
//  TIEPassengerDetailsViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 4/16/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "TIEPassengerDetailsViewController.h"

@interface TIEPassengerDetailsViewController (){
    NSString *userId;
}

@end

@implementation TIEPassengerDetailsViewController

@synthesize pictureProfileImage, userNameLabel, userEmailLabel, startedTripsLabel, finishedTripsLabel, cancelTripLabel;

- (id) initWithTripId:(NSString *) passengerId{
    self = [super initWithNibName:@"TIEPassengerDetailsViewController" bundle:nil];
    if (self) {
        userId = passengerId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"Pasajero";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    //Estilo de imagen de perdil
    pictureProfileImage.layer.cornerRadius = pictureProfileImage.frame.size.width / 2;
    pictureProfileImage.clipsToBounds = YES;
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
