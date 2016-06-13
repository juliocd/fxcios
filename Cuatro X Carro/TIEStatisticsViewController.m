//
//  TIEPassengerDetailsViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 4/16/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "TIEStatisticsViewController.h"
#import "Util.h"

@interface TIEStatisticsViewController (){
    NSString *userId;
}

@end

@implementation TIEStatisticsViewController

@synthesize startedTripsLabel, finishedTripsLabel, cancelTripLabel,rateOneIcon,rateTwoIcon,rateThreeIcon,rateFourIcon,rateFiveIcon;

- (id) initWithUserId:(NSString *) _userId{
    self = [super initWithNibName:@"TIEStatisticsViewController" bundle:nil];
    if (self) {
        userId = _userId;
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
    
    [self getUserStatistics];
    
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getUserStatistics{
    Util *util = [Util getInstance];
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/userStatistics", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"id=%@",
                      userId];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
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
                NSMutableDictionary *userStatistics = [jsonData valueForKey:@"result"];
                startedTripsLabel.text = [NSString stringWithFormat:@"%@", [userStatistics valueForKey:@"initTrip"]];
                finishedTripsLabel.text = [NSString stringWithFormat:@"%@", [userStatistics valueForKey:@"finishTrip"]];
                cancelTripLabel.text = [NSString stringWithFormat:@"%@", [userStatistics valueForKey:@"rating"]];
                NSInteger rating = [[userStatistics valueForKey:@"rating"] integerValue];
                [self loadUserRate: rating];
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
}

- (void) loadUserRate:(NSInteger) rating{
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
                    [rateOneIcon setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [rateOneIcon setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 1:
                if(loadStar){
                    [rateTwoIcon setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [rateTwoIcon setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 2:
                if(loadStar){
                    [rateThreeIcon setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [rateThreeIcon setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 3:
                if(loadStar){
                    [rateFourIcon setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                else{
                    [rateFourIcon setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 4:
                if(loadStar){
                    [rateFiveIcon setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [rateFiveIcon setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
                
            default:
                break;
        }
    }
}

@end
