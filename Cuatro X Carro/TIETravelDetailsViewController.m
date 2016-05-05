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
#import "TIEStatisticsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TIETravelDetailsViewController () <LGChatControllerDelegate> {
    NSMutableDictionary *tripData;
    Util *util;
    GMSPolyline *polyline;
    GMSMarker *markerStart;
    GMSMarker *markerFinish;
    GMSMarker *currenPositionMarker;
    NSMutableDictionary *trackTripData;
    NSTimer *updateDriverPosition;
    NSTimer *updateCommentaries;
    CLLocationManager *locationManager;
    BOOL _isAvalibleLocation;
    double currentLatitude;
    double currentLongitude;
    float testMore;
    NSMutableArray *messages;
    NSMutableDictionary *dataUser;
    BOOL isPassengerOnTrip;
}

@end

@implementation TIETravelDetailsViewController

@synthesize routeMap, driverName, dateTrip, hourTrip, startTripUIButton, requestUIButton, finishTripUIButton, animmationPositionDiver, messengerTable, spinnerComments,finishTripPassengerButton;

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
    
    //Bordear esquinas de tabla
    messengerTable.layer.cornerRadius=5;
    
    //Se recuperan datos de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    dataUser = [defaults objectForKey:@"userData"];
    
    //Se recupera informacion del viaje
    [self loadInfoTrip];
    
    //Timer para recuperar comentarios de usaurio
    messages = [[NSMutableArray alloc] init];
    updateCommentaries = [NSTimer scheduledTimerWithTimeInterval:1
                                                            target:self
                                                          selector: @selector(getTripCommentaries)
                                                          userInfo:nil
                                                           repeats:YES];
}

#pragma mark - Messenger table
//Se determina numero de filas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [messages count];
}
//Se configura celda a cargar en la tabla
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Se crea instancia de celda
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //Se valida que la celda esta vacia para llenarla
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    }
    if ([messages count] > 0) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result = [messages objectAtIndex:indexPath.row];
        cell.textLabel.text = [result valueForKey:@"comment"];
        cell.detailTextLabel.text = [result valueForKey:@"name"];
        cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:9];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:139/255.0 green:137/255.0 blue:137/255.0 alpha:1];
        if([result valueForKey:@"user_id"] == [dataUser valueForKey:@"id"]){
            cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"chat_box_other.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        }else{
            cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"chat_box_user.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        }
    }
    
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([messages count] > 0) {
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result = [messages objectAtIndex:indexPath.row];
        NSString *cellText = [result valueForKey:@"comment"];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:15.0];
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
         initWithString:cellText
         attributes:@
         {
         NSFontAttributeName: cellFont,
         }];
        CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        return rect.size.height + 30;
    }else{
        return 0;
    }
}
// Delegate table
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - Load basic trip information on view
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
                
                //Si es pasajero se ocultan botones de conductor
                if(![[tripData valueForKey:@"trip_type"] isEqualToString:@"Conductor"]){
                    startTripUIButton.hidden = YES;
                    requestUIButton.hidden = YES;
                    finishTripPassengerButton.hidden = NO;
                    isPassengerOnTrip = false;
                    updateDriverPosition = [NSTimer scheduledTimerWithTimeInterval:1
                                                                            target:self
                                                                          selector: @selector(getDriverPosition)
                                                                          userInfo:nil
                                                                           repeats:YES];
                }
                
                //Se coloca punto de pasajero en el mapa
                NSMutableArray *passengers = [tripInfo valueForKey:@"passengers"];
                //Pasajero 1
                for(int k=0 ; k<[passengers count]; k++){
                    NSMutableDictionary * passenger = [passengers objectAtIndex:k];
                    double driverCurrentLatitude = [[passenger valueForKey:@"passenger_latitude"] doubleValue];
                    double driverCurrentLongitude = [[passenger valueForKey:@"passenger_longitude"] doubleValue];
//                    double driverCurrentLatitude = 6.21;
//                    double driverCurrentLongitude = -75.58;
                    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(driverCurrentLatitude, driverCurrentLongitude);
                    GMSMarker *marker = [GMSMarker markerWithPosition:position];
                    marker.position = position;
                    marker.title = [passenger valueForKey:@"name"];
                    marker.map = self.routeMap;
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
    [updateCommentaries invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)viewApplications:(id)sender {
    TIEApplicationsViewController *applicationsVC =[[TIEApplicationsViewController alloc] initWithTripId:[tripData valueForKey:@"id"] withSecond:[tripData valueForKey:@"max_seats"] withThird:nil];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:applicationsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

//Enviar mensaje
- (IBAction)sendMessage:(id)sender {
    
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/saveNewComment", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nuevo mensaje" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Enviar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                      {
                          NSDate *now = [NSDate date];
                          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                          [dateFormatter setDateFormat:@"y-M-d HH:mm:ss"];
                          NSString *currentDate = [dateFormatter stringFromDate:now];
                          //Se configura data a enviar
                          NSString *post = [NSString stringWithFormat:
                                            @"user_id=%@&driver_trip_id=%@&comment=%@&is_deleted=%@&tenant_id=%@&date_hour=%@",
                                            [dataUser valueForKey:@"id" ],
                                            [tripData valueForKey:@"id"],
                                            alert.textFields.firstObject.text,
                                            @"false",
                                            [dataUser valueForKey:@"tenant_id"],
                                            currentDate];
                          NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                          
                          //Se captura numero de deparametros a enviar
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
                                  //Se convierte respuesta en JSON
                                  NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                                  NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
                                  id isValid = [jsonData valueForKey:@"valid"];
                                  
                                  if (isValid ? [isValid boolValue] : NO) {
                                      NSLog(@"Mensaje almacenado: %@", alert.textFields.firstObject.text);
                                  }
                                  else{
                                      UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                                                message:@"Error al enviar mensaje"
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil];
                                      [alertErrorLogin show];
                                  }
                              });
                          }] resume];
                      }]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *messageText) {
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)showPassengers:(id)sender {
    NSMutableArray *passengers = [trackTripData valueForKey:@"passengers"];
    TIEApplicationsViewController *applicationsVC =[[TIEApplicationsViewController alloc] initWithTripId:[tripData valueForKey:@"id"] withSecond:[tripData valueForKey:@"max_seats"] withThird:passengers];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:applicationsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

- (IBAction)finishTripPassenger:(id)sender {
    [updateDriverPosition invalidate];
    [updateCommentaries invalidate];
    UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                            message:[NSString stringWithFormat:@"%@ se ha unido al viaje.", [trackTripData valueForKey:@"driver_name"]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
    [alertSaveUser show];
    isPassengerOnTrip = true;
}

-(void) getTripCommentaries{
    spinnerComments.hidden = NO;
    [spinnerComments startAnimating];
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/queryCommentsByTrip", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"id=%@&tenant_id=%@",
                      [tripData valueForKey:@"id"],
                      [dataUser valueForKey:@"tenant_id"]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //Se captura numero de deparametros a enviar
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
            //Se convierte respuesta en JSON
            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
            id isValid = [jsonData valueForKey:@"valid"];
            
            if (isValid ? [isValid boolValue] : NO) {
                messages = [jsonData valueForKey:@"result"];
                [spinnerComments stopAnimating];
                spinnerComments.hidden = YES;
                [messengerTable reloadData];
            }
            else{
                UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                          message:@"Error al enviar mensaje"
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                [alertErrorLogin show];
            }
        });
    }] resume];
}

-(void) viewPassengerDetails:(NSString *) passengerId{
    TIEStatisticsViewController *passangerDetailsVC =[[TIEStatisticsViewController alloc] initWithTripId:passengerId];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:passangerDetailsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
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
    [updateCommentaries invalidate];
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/finishDriverTrip", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"trip_id=%@",
                      [tripData valueForKey:@"id"]];
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
                UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                        message:@"Viaje fianlizado correctamente"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                [alertSaveUser show];
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
                    //Se almacena posicion de usuario
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

-(void) getDriverPosition{
    
    //Se recupera informacion de usuario
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
