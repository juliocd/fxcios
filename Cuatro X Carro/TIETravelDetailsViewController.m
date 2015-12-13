//
//  TIETravelDetailsViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIETravelDetailsViewController.h"
#import "TIEApplicationsViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Util.h"

@interface TIETravelDetailsViewController (){
    NSMutableDictionary *tripData;
    Util *util;
    GMSPolyline *polyline;
    GMSMarker *markerStart;
    GMSMarker *markerFinish;
}

@end

@implementation TIETravelDetailsViewController

@synthesize routeMap, driverName, dateTrip, hourTrip, seatsState;

- (id)initWithTripData:(NSMutableDictionary *) aTripData {
    self = [super initWithNibName:@"TIETravelDetailsViewController" bundle:nil];
    if (self) {
        tripData = aTripData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Detalles";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:6.2488523
                                                            longitude:-75.585289
                                                                 zoom:16];
    self.routeMap.camera = camera;
    self.routeMap.myLocationEnabled = YES;
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
    
    //Varibales de mapa
    markerStart = [GMSMarker new];
    markerFinish = [GMSMarker new];
    
    [self loadInfoTrip];
}

-(void) loadInfoTrip{
    
    //Se recupera informacion de usuario
    NSString *urlServer = @"http://127.0.0.1:5000/queryTripInfoIOS";
    //Se configura data a enviar
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:tripData options:0 error:nil];
    NSString *dataTripString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:
                      @"trip=%@",
                      dataTripString];
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
        dispatch_async(dispatch_get_main_queue(),^{
            //Se convierte respuesta en JSON
            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
            id isValid = [jsonData valueForKey:@"valid"];
            
            if (isValid ? [isValid boolValue] : NO) {
                //Se recuperan datos de viaje
                NSMutableDictionary *tripInfo = [[NSMutableDictionary alloc] init];
                tripInfo = [jsonData valueForKey:@"result"];
                //Se actualiza titulo de barra de navegacion
                if ([tripInfo valueForKey:@"is_going"] ? [[tripInfo valueForKey:@"is_going"] boolValue] : NO) {
                    self.title = @"Viaje de ida";
                }
                else{
                    self.title = @"Viaje de regreso";
                }
                //Se carga nombre de conductor
                driverName.text = [tripInfo valueForKey:@"driver_name"];
                //Se carga ruta en mapa
                [util buildRoute:[tripInfo valueForKey:@"route"] withSecond:[[tripInfo valueForKey:@"tenant_id"] longValue] withThird:polyline withFourth:markerStart withFifth:markerFinish withSixth:self.routeMap];
                //Se carga fecha
                dateTrip.text = [[tripInfo valueForKey:@"date_hour"] substringToIndex:10];
                //Se carga hora
                hourTrip.text = [util militaryTimeToAMPMTime:[[[tripInfo valueForKey:@"date_hour"] substringFromIndex:11] substringToIndex:5]];
                //Sillas disponibles
                int availableSeats = [tripInfo valueForKey:@"available_seats"] == nil ? [[tripInfo valueForKey:@"available_seats"] intValue] : 0;
                int maxSeats = [tripInfo valueForKey:@"max_seats"] == nil ? [[tripInfo valueForKey:@"max_seats"] intValue] : 0;
                seatsState.text = [NSString stringWithFormat:@"(%i/%i)", availableSeats, maxSeats];
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

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)viewApplications:(id)sender {
    TIEApplicationsViewController *applicationsVC =[[TIEApplicationsViewController alloc] initWithTripId:[tripData valueForKey:@"id"] withSecond:[tripData valueForKey:@"max_seats"]];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:applicationsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}
@end
