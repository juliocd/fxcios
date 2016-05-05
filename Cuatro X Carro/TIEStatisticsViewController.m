//
//  TIEPassengerDetailsViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 4/16/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "TIEStatisticsViewController.h"

@interface TIEStatisticsViewController (){
    NSString *userId;
}

@end

@implementation TIEStatisticsViewController

@synthesize startedTripsLabel, finishedTripsLabel, cancelTripLabel;

- (id) initWithTripId:(NSString *) passengerId{
    self = [super initWithNibName:@"TIEStatisticsViewController" bundle:nil];
    if (self) {
        userId = passengerId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"Estadisticas";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    //Redondear bordes
    startedTripsLabel.layer.masksToBounds = YES;
    startedTripsLabel.layer.cornerRadius = 8.0;
    finishedTripsLabel.layer.masksToBounds = YES;
    finishedTripsLabel.layer.cornerRadius = 8.0;
    cancelTripLabel.layer.masksToBounds = YES;
    cancelTripLabel.layer.cornerRadius = 8.0;
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
