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
#import "Cuatro_X_Carro-Swift.h"
#import "TIEPassengerDetailsViewController.h"

@interface TIETravelDetailsViewController () <LGChatControllerDelegate> {
    NSMutableDictionary *tripData;
    Util *util;
    GMSPolyline *polyline;
    GMSMarker *markerStart;
    GMSMarker *markerFinish;
    GMSMarker *currenPositionMarker;
    NSMutableDictionary *trackTripData;
    NSTimer *updateDriverPosition;
    CLLocationManager *locationManager;
    BOOL _isAvalibleLocation;
    double currentLatitude;
    double currentLongitude;
    float testMore;
}

@end

@implementation TIETravelDetailsViewController

@synthesize routeMap, driverName, dateTrip, hourTrip, seatsState, startTripUIButton, requestUIButton, finishTripUIButton, passengerOne, passengerTwo, passengerThree, passengerFour, passengerOneUIButton, passengerTwoUIButton, passengerThreeUIButton, passengerFourUIButton, animmationPositionDiver;

- (id)initWithTripData:(NSMutableDictionary *) aTripData {
    self = [super initWithNibName:@"TIETravelDetailsViewController" bundle:nil];
    if (self) {
        tripData = aTripData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isAvalibleLocation = NO;
    currentLatitude = 0;
    currentLongitude = 0;
    testMore = 0.000001;
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
    currenPositionMarker = [GMSMarker new];
    
    [self loadInfoTrip];
}

-(void) loadInfoTrip{
    
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/queryTripInfoIOS", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    //Se configura data a enviar
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:tripData options:0 error:nil];
    NSString *dataTripString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:
                      @"trip=%@",
                      dataTripString];
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
                seatsState.text = [NSString stringWithFormat:@"Pasajeros (%i/%i)", availableSeats, maxSeats];
                
                //Si es pasajero se ocultan botones de conductor
                if(![[tripData valueForKey:@"trip_type"] isEqualToString:@"Conductor"]){
                    startTripUIButton.hidden = YES;
                    requestUIButton.hidden = YES;
                    updateDriverPosition = [NSTimer scheduledTimerWithTimeInterval:1
                                                                            target:self
                                                                          selector: @selector(getDriverPosition)
                                                                          userInfo:nil
                                                                           repeats:YES];
                }
                
                //Se cargan pasajeros
                NSMutableArray *passengers = [tripInfo valueForKey:@"passengers"];
                if(passengers != nil){
                    if(passengers.count > 0){
                        passengerOne.text = [passengers[0] valueForKey:@"name"];
                        passengerOneUIButton.hidden = NO;
                        passengerOneUIButton.accessibilityValue = [NSString stringWithFormat:@"%@", [passengers[0] valueForKey:@"id"]];
                    }if(passengers.count > 1){
                        passengerTwo.text = [passengers[1] valueForKey:@"name"];
                        passengerOneUIButton.hidden = NO;
                    }if(passengers.count > 2){
                        passengerThree.text = [passengers[2] valueForKey:@"name"];
                        passengerOneUIButton.hidden = NO;
                    }if(passengers.count > 3){
                        passengerFour.text = [passengers[3] valueForKey:@"name"];
                        passengerOneUIButton.hidden = NO;
                    }
                }
                
                //Se incia traking de pasajero
                trackTripData = tripInfo;
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
    [updateDriverPosition invalidate];
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

- (IBAction)passengerOneInfoButton:(id)sender {
    [self viewPassengerDetails:passengerOneUIButton.accessibilityValue];
}

- (IBAction)passengerTwoInfoButton:(id)sender {
    [self viewPassengerDetails:passengerOneUIButton.accessibilityValue];
}

- (IBAction)passengerThreeInfoButton:(id)sender {
    [self viewPassengerDetails:passengerOneUIButton.accessibilityValue];
}

- (IBAction)passengerFourInfoButton:(id)sender {
    [self viewPassengerDetails:passengerOneUIButton.accessibilityValue];
}

-(void) viewPassengerDetails:(NSString *) passengerId{
    TIEPassengerDetailsViewController *passangerDetailsVC =[[TIEPassengerDetailsViewController alloc] initWithTripId:passengerId];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:passangerDetailsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)goChatButton:(id)sender {
    
    LGChatController *chatController = [LGChatController new];
    chatController.opponentImage = [UIImage imageNamed:@"User"];
    chatController.delegate = self;
    [self.navigationController pushViewController:chatController animated:YES];
}

- (IBAction)startTripButton:(id)sender {
    
    //Se recupera posición incial del conductor y se carga en mapa

    //se recupera posicion actual del usuario
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [self->locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

- (IBAction)finishTripButton:(id)sender {
    [updateDriverPosition invalidate];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLatitude = newLocation.coordinate.latitude;
    currentLongitude = newLocation.coordinate.longitude;
    if(!_isAvalibleLocation){
        _isAvalibleLocation = true;
        startTripUIButton.hidden = YES;
        requestUIButton.hidden = YES;
        finishTripUIButton.hidden = NO;
        updateDriverPosition = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                              selector: @selector(saveDriverPosition)
                                                              userInfo:nil
                                                               repeats:YES];
    }
}

-(void) saveDriverPosition{
    //testMore += 0.001;
    //Se valida que se tengan las coordenadas
    if(currentLatitude !=0 && currentLongitude !=0){
        //Se recupera informacion de usuario
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
        long userId = [[dataUser objectForKey:@"id"] intValue];
        long tenantId = [[dataUser objectForKey:@"tenant_id"] intValue];
        //Se recupera host para peticiones
        NSString *urlServer = [NSString stringWithFormat:@"%@/saveDriverLocation", [util.getGlobalProperties valueForKey:@"host"]];
        NSLog(@"url saveUser: %@", urlServer);
        //Se configura data a enviar
        NSString *post = [NSString stringWithFormat:
                          @"user_id=%ld&latitude=%f&longitude=%f&tenant_id=%ld",
                          userId,currentLatitude,currentLongitude,tenantId];
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
                    //Se dibuja posicion en mapa
                    [self updateDriverLocation];
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
    else{
        UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                message:@"No ha sido posble obtener su posición actual. Por favor verifique en Configuraciones si tiene los permisos de ubicación."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [alertMessage show];
    }
}

-(void)updateDriverLocation{
    
}

#pragma mark - LGChatControllerDelegate
- (void)chatController:(LGChatController *)chatController didAddNewMessage:(LGChatMessage *)message
{
    NSLog(@"Did Add Message: %@", message.content);
}

- (BOOL)shouldChatController:(LGChatController *)chatController addMessage:(LGChatMessage *)message
{
    /*
     This is implemented just for demonstration so the sent by is randomized.  This way, the full functionality can be demonstrated.
     */
    message.userName = @"Andres";
    message.date = @"3:45pm";
    message.sentByString = arc4random_uniform(2) == 0 ? [LGChatMessage SentByOpponentString] : [LGChatMessage SentByUserString];
    return YES;
}

-(void) getDriverPosition{
    
    //Se recupera informacion de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
    long userId = [[dataUser objectForKey:@"id"] intValue];
    long tenantId = [[dataUser objectForKey:@"tenant_id"] intValue];
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/queryDriverLocation", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"user_id=%ld&tenant_id=%ld",
                      userId,tenantId];
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
                NSMutableDictionary *dataUserLocation = [jsonData valueForKey:@"result"];
                if(dataUserLocation != nil){
                    
                    animmationPositionDiver.hidden = YES;
                    [animmationPositionDiver stopAnimating];
                    double driverCurrentLatitude = [[dataUserLocation valueForKey:@"latitude"] doubleValue];
                    double driverCurrentLongitude = [[dataUserLocation valueForKey:@"longitude"] doubleValue];
                    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(driverCurrentLatitude, driverCurrentLongitude);
                    GMSMarker *marker = [GMSMarker markerWithPosition:position];
                    marker.position = position;
                    marker.title = @"Conductor";
                    marker.map = self.routeMap;
                }else{
                    animmationPositionDiver.hidden = NO;
                    [animmationPositionDiver startAnimating];
                }
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
@end
