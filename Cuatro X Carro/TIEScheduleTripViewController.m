//
//  TIEScheduleTripViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIEScheduleTripViewController.h"
#import "TIESearchTravelViewController.h"
#import "ActionSheetPicker.h"
#import "Util.h"

@implementation TIEScheduleTripViewController{
    NSMutableDictionary *dataUser;
    Util *util;
    NSNumber *staticLatitude;
    NSNumber *staticLongitude;
    NSMutableArray *daysArray;
    NSString *lastTripTypeSelected;
}

@synthesize  selectRouteMap, travelTypeSelect, searchPassengerTravels, switchUserType, saveDriverTravel, availableSeats, availableSeatsLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    lastTripTypeSelected = @"Ida";
    
    //Se inicializa selector de filtro de dias
    daysArray = [[NSMutableArray alloc] init];
    
    //Se obtiene informacion de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    dataUser = [defaults objectForKey:@"userData"];
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
    
    //Se fijan coodenadas inciales
    staticLatitude = [NSNumber numberWithDouble:6.2000649];
    staticLongitude = [NSNumber numberWithDouble:-75.5791193];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[staticLatitude doubleValue]
                                                            longitude:[staticLongitude doubleValue]
                                                                 zoom:16];
    selectRouteMap.camera = camera;
    selectRouteMap.myLocationEnabled = YES;
    selectRouteMap.settings.myLocationButton = YES;
    selectRouteMap.delegate = self;
    _coordinates = [NSMutableArray new];
    _routeController = [LRouteController new];
    
    _markerStart = [GMSMarker new];
    _markerFinish = [GMSMarker new];
    
    //Se cargan valores de dias seleccionados;
    [buttonMonday setSelected:NO];
    [buttonTuesday setSelected:NO];
    [buttonWednesday setSelected:NO];
    [buttonThursday setSelected:NO];
    [buttonFriday setSelected:NO];
    [buttonSaturday setSelected:NO];
    
    [self reloadMarkersByUserType];
}

- (void) viewWillAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    dataUser = [defaults objectForKey:@"userData"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)searchRoute:(id)sender {
    //Se envia a vista el horario seleccionado, segun configuarcion de usuario en perfiles y ruta para armar cada passangerTrip
    //Se crea arreglo de viajes de conductor
    NSMutableArray *driverTripArray = [[NSMutableArray alloc] init];
    
    //Se obtiene tipo de viaje
    NSString *travelType = @"_going";
    NSNumber *isGoing = [NSNumber numberWithInt:1];
    if (![[self.travelTypeSelect text] isEqualToString:@"Ida"]) {
        travelType = @"_return";
        isGoing = [NSNumber numberWithInt:0];
    }
    //Construir formato de hora a partir de horario
    NSString *strSchedule = [dataUser objectForKey:@"schedule"];
    if (![strSchedule isEqual:@""]) {
        //Se organiza horario de usuario
        [self getUserSchedule:strSchedule withSecond:travelType withThird:isGoing withFourth:driverTripArray];
        //Se recupera data de arreglo de puntos
        NSMutableArray *stepArray = [_routeController getStepArray];
        //Se valida que exista una ruta
        if (stepArray.count > 0) {
            if(driverTripArray.count > 0){
                [daysArray addObject:@"Todos"];
                //Se cargan dias disponibles en filtro
                if(buttonMonday.isSelected){[daysArray addObject:@"Lunes"];};
                if(buttonTuesday.isSelected){[daysArray addObject:@"Martes"];};
                if(buttonWednesday.isSelected){[daysArray addObject:@"Miércoles"];};
                if(buttonThursday.isSelected){[daysArray addObject:@"Jueves"];};
                if(buttonFriday.isSelected){[daysArray addObject:@"Viernes"];};
                if(buttonSaturday.isSelected){[daysArray addObject:@"Sábado"];};
                //Se envia parametros a siguinete controlador
                TIESearchTravelViewController *searchTravelsVC = [[TIESearchTravelViewController alloc] initWithSearchData:driverTripArray withSecond:stepArray withThird:isGoing withFourth:daysArray];
                UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:searchTravelsVC];
                [self presentViewController:trasformerNavC animated:YES completion:nil];
            }else{
                UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                          message:@"Usted no tiene horario establecido para este dia de la semana."
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                [alertErrorLogin show];
            }
        }
        else{
            UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                      message:@"Debe indicar en el mapa su punto de salida o llegada."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
            [alertErrorLogin show];
        }
    }
    else{
        UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                  message:@"Debe configurar inicalmente un horario en perfil de usuario."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [alertErrorLogin show];
    }
}

#pragma Switch para seleccionar tipo de pasajero
- (IBAction)SwitchUserType:(id)sender {
    self.travelTypeSelect.text = @"Ida";
    [self.travelTypeSelect  setEnabled:YES];
    [self clearMap];
    [self reloadMarkersByUserType];
}

#pragma Botones de chekbox
- (IBAction)CheckMonday:(id)sender {
    buttonMonday = sender;
    if([buttonMonday isSelected]){
        [buttonMonday setSelected:NO];
        [buttonMonday setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonMonday setSelected:YES];
        [buttonMonday setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckTuesday:(id)sender {
    buttonTuesday = sender;
    if([buttonTuesday isSelected]){
        [buttonTuesday setSelected:NO];
        [buttonTuesday setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonTuesday setSelected:YES];
        [buttonTuesday setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckWednesday:(id)sender {
    buttonWednesday = sender;
    if([buttonWednesday isSelected]){
        [buttonWednesday setSelected:NO];
        [buttonWednesday setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonWednesday setSelected:YES];
        [buttonWednesday setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckThursday:(id)sender {
    buttonThursday = sender;
    if([buttonThursday isSelected]){
        [buttonThursday setSelected:NO];
        [buttonThursday setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonThursday setSelected:YES];
        [buttonThursday setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckFriday:(id)sender {
    buttonFriday = sender;
    if([buttonFriday isSelected]){
        [buttonFriday setSelected:NO];
        [buttonFriday setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonFriday setSelected:YES];
        [buttonFriday setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckSaturday:(id)sender {
    buttonSaturday = sender;
    if([buttonSaturday isSelected]){
        [buttonSaturday setSelected:NO];
        [buttonSaturday setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonSaturday setSelected:YES];
        [buttonSaturday setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

#pragma Boton de combo box de tipo de viaje
- (IBAction)SelectTravelType:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
            //Recargar mapa si se cambia de opcion
            NSLog(@"%@", self.travelTypeSelect.text);
            if(![self.travelTypeSelect.text isEqualToString:lastTripTypeSelected]){
                [self clearMap];
                [self reloadMarkersByUserType];
                lastTripTypeSelected = selectedValue;
            }
        }
        [self.travelTypeSelect  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    
    NSArray *dayItems = [NSArray arrayWithObjects:@"Ida", @"Regreso", nil];
    NSUInteger initialIndex = 0;
    if(![self.travelTypeSelect.text isEqualToString:@""] && [dayItems indexOfObject:self.travelTypeSelect.text] != -1){
        initialIndex = [dayItems indexOfObject:self.travelTypeSelect.text];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Tipo de viaje" rows:dayItems initialSelection:initialIndex
                                       doneBlock:done cancelBlock:cancel origin:sender];
    [self.travelTypeSelect setEnabled:NO];
}

#pragma Botone para limpiar mapa
- (IBAction)ClearMap:(id)sender {
    [self clearMap];
    [self reloadMarkersByUserType];
}

#pragma Botones guardar, buscar y cancelar
- (IBAction)SaveDriverTravel:(id)sender {
    
    //Se crea arreglo de viajes de conductor
    NSMutableArray *driverTripArray = [[NSMutableArray alloc] init];
    
    //Se obtiene tipo de viaje
    NSString *travelType = @"_going";
    NSNumber *isGoing = [NSNumber numberWithInt:1];
    if (![[self.travelTypeSelect text] isEqualToString:@"Ida"]) {
        travelType = @"_return";
        isGoing = [NSNumber numberWithInt:0];
    }
    //Se valida que los cupos no sean cero o mayor a seis
    if ([availableSeats.text intValue] > 0 && [availableSeats.text intValue] < 5) {
    
        //Construir formato de hora a parti de horario
        NSString *strSchedule = [dataUser objectForKey:@"schedule"];
        if (![strSchedule isEqual:@""]) {
            [self getUserSchedule:strSchedule withSecond:travelType withThird:isGoing withFourth:driverTripArray];
            
            NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:driverTripArray options:0 error:nil];
            NSString *driverTripString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
            
            //Se recupera data de arreglo de puntos
            NSString *stepsArrayString = [_routeController getStepArrayString];
            
            if (![stepsArrayString isEqualToString:@""] && stepsArrayString != nil){
                
                if(![driverTripString isEqualToString:@"[]"]) {
                    
                    //Se recupera host para peticiones
                    NSString *urlServer = [NSString stringWithFormat:@"%@/saveDriverTripsIOS", [util.getGlobalProperties valueForKey:@"host"]];
                    NSLog(@"url saveUser: %@", urlServer);
                    //Se configura data a enviar
                    NSString *post = [NSString stringWithFormat:
                                      @"trips=%@&route=%@",
                                      driverTripString,
                                      stepsArrayString];
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
                        NSLog(@"requestReply: %@", requestReply);
                        dispatch_async(dispatch_get_main_queue(),^{
                            
                            //Se convierte respuesta en JSON
                            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
                            id isValid = [jsonData valueForKey:@"valid"];
                            
                            NSString *message = @"Viaje almacenado correctamente.";
                            if (!isValid ? [isValid boolValue] : NO) {
                                message = [jsonData objectForKey:@"error"];
                            }
                            else{
                                [util updateUserDefaults:^(bool result){}];
                                [self clearMap];
                                [self reloadMarkersByUserType];
                            }
                            
                            UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                                    message:message
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil];
                            [alertSaveUser show];
                        });
                    }] resume];
                }else{
                    NSString *messagePassengerOrDriver = @"Por favor seleccione un día de la semana y recuerde que debe tener un hoario configurado.";
                    UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                              message:messagePassengerOrDriver
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                    [alertErrorLogin show];
                }
            }else{
                NSString *messagePassengerOrDriver = @"Debe indicar un punto en el mapa.";
                UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                          message:messagePassengerOrDriver
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                [alertErrorLogin show];
            }
            
        }
        else{
            UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                      message:@"Debe configurar inicalmente un horario en perfil de usuario."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
            [alertErrorLogin show];
        }
    }
    else{
        UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                  message:@"El número de cupos no debe ser inferior a 1 o superior a 4."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [alertErrorLogin show];
    }
}

#pragma Metodos de Google Maps
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    //Accion si es pasajero (solo poner funto de destino)
    if([switchUserType isOn]){
        [self.selectRouteMap clear];
        [self reloadMarkersByUserType];
        _coordinates = [NSMutableArray new];
        GMSMarker *personalMarker = [[GMSMarker alloc] init];
        
        //Se evalua si es de ida o de vuelta el viaje
        if ([[self.travelTypeSelect text] isEqualToString:@"Ida"]) {
            //Se agrega coordenada seleccionada y final (tenant), apra generar ruta y generar coincidencias
            [_coordinates addObject:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
            [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[staticLatitude doubleValue] longitude:[staticLongitude doubleValue]]];
            //Se agrega marca
            personalMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
            personalMarker.title = @"Salida";
            personalMarker.snippet = @"Medellin";
            personalMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
            personalMarker.map = self.selectRouteMap;
        }
        else{
            [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[staticLatitude doubleValue] longitude:[staticLongitude doubleValue]]];
            [_coordinates addObject:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
            //Se agrega marca
            personalMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
            personalMarker.title = @"Llegada";
            personalMarker.snippet = @"Medellin";
            personalMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
            personalMarker.map = self.selectRouteMap;
        }
        
        //Se solicita ruta
        if ([_coordinates count] == 2){
            [_routeController getPolylineWithLocations:_coordinates withsecond:[[dataUser objectForKey:@"tenant_id"] longValue] travelMode:TravelModeDriving andCompletitionBlock:^(GMSPolyline *polyline, NSError *error) {
            }];
        }
        
    }
    else{
        _polyline.map = nil;
        _markerStart.map = nil;
        _markerFinish.map = nil;
        
        //Se debe agregar la posicion del tenant al final cuando es ida, pero ya se ha agregado por
        //cada punto, por tal motivo debe elimianrse antes y volverlo a agregar
        if ([[self.travelTypeSelect text] isEqualToString:@"Ida"]) {
            [_coordinates removeLastObject];
            //Se agrega punto intermedio
            [_coordinates insertObject:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] atIndex:0];
            //Se agrega la del tenant
            [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[staticLatitude doubleValue] longitude:[staticLongitude doubleValue]]];
        }
        else{
            //Si es de regreso se agregan sin problema, pq la final es la seleccionada
            [_coordinates addObject:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
        }
    
        if ([_coordinates count] > 1){
            [_routeController getPolylineWithLocations:_coordinates withsecond:[[dataUser objectForKey:@"tenant_id"] longValue] travelMode:TravelModeDriving andCompletitionBlock:^(GMSPolyline *polyline, NSError *error) {
                if (error){
                    NSLog(@"%@", error);
                }else if (!polyline){
                    NSLog(@"No route");
                    [_coordinates removeAllObjects];
                }else{
                    _polyline = polyline;
                    //Color de linea por gradiente
                    GMSStrokeStyle *greenToRed = [GMSStrokeStyle gradientFromColor:[UIColor greenColor] toColor:[UIColor blueColor]];
                    _polyline.spans = @[[GMSStyleSpan spanWithStyle:greenToRed]];
                    _polyline.map = selectRouteMap;
                    //Pintar marcas
                    if (![[self.travelTypeSelect text] isEqualToString:@"Ida"]) {
                        //Marca final
                        _markerStart.position = [[_coordinates lastObject] coordinate];
                        _markerStart.map = selectRouteMap;
                        _markerStart.title = @"Llegada";
                        _markerStart.snippet = @"Medellin";
                        _markerStart.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                        //Marca inicial
                        _markerFinish.position = [[_coordinates objectAtIndex:0] coordinate];
                        _markerFinish.map = selectRouteMap;
                        _markerFinish.title = @"Salida";
                        _markerFinish.snippet = @"Medellin";
                        _markerFinish.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
                    }
                    else{
                        //Marca inicial
                        _markerStart.position = [[_coordinates objectAtIndex:0] coordinate];
                        _markerStart.map = selectRouteMap;
                        _markerStart.title = @"Salida";
                        _markerStart.snippet = @"Medellin";
                        _markerStart.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
                        //Marca final
                        _markerFinish.position = [[_coordinates lastObject] coordinate];
                        _markerFinish.map = selectRouteMap;
                        _markerFinish.title = @"Llegada";
                        _markerFinish.snippet = @"Medellin";
                        _markerFinish.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                    }
                }
            }];
        }
    }
}

#pragma Metodos propios
-(void) getUserSchedule:(NSString *) strSchedule withSecond:(NSString *) travelType withThird:(NSNumber *) isGoing withFourth: (NSMutableArray *) driverTripArray{
    NSMutableDictionary *schedule = [[NSMutableDictionary alloc] init];
    schedule = [NSJSONSerialization JSONObjectWithData:[strSchedule dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSString *daySchedule = @"";
    NSString *dateHour = @"";
    //Lunes
    if ([buttonMonday isSelected]) {
        //Se recupera hora para dia lunes
        daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"monday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"monday%@", travelType]];
        //Se valida que tenga horario programado para ese dia
        if (![daySchedule isEqualToString:@""] && daySchedule != nil) {
            //Se recupera fecha del procimo dia seleccionado
            dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:2],daySchedule];
            NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
            [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"id"] longValue]] forKey:@"user_id"];
            [driverTrip setValue:dateHour forKey:@"date_hour"];
            [driverTrip setValue:isGoing forKey:@"is_going"];
            [driverTrip setValue:availableSeats.text forKey:@"max_seats"];
            [driverTrip setValue:availableSeats.text forKey:@"available_seats"];
            [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] intValue]] forKey:@"tenant_id"];
            [driverTripArray addObject:driverTrip];
        }
    }
    //Martes
    if ([buttonTuesday isSelected]) {
        //Se recupera hora para dia lunes
        daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"tuesday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"tuesday%@", travelType]];
        //Se valida que tenga horario programado para ese dia
        if (![daySchedule isEqualToString:@""] && daySchedule != nil) {
            //Se recupera fecha del procimo dia seleccionado
            dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:3],daySchedule];
            NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
            [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"id"] intValue]] forKey:@"user_id"];
            [driverTrip setValue:dateHour forKey:@"date_hour"];
            [driverTrip setValue:isGoing forKey:@"is_going"];
            [driverTrip setValue:availableSeats.text forKey:@"max_seats"];
            [driverTrip setValue:availableSeats.text forKey:@"available_seats"];
            [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] intValue]] forKey:@"tenant_id"];
            [driverTripArray addObject:driverTrip];
        }
    }
    //Miercoles
    if ([buttonWednesday isSelected]) {
        //Se recupera hora para dia lunes
        daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"wednesday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"wednesday%@", travelType]];
        //Se valida que tenga horario programado para ese dia
        if (![daySchedule isEqualToString:@""] && daySchedule != nil) {
            //Se recupera fecha del procimo dia seleccionado
            dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:4],daySchedule];
            NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
            [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"id"] longValue]] forKey:@"user_id"];
            [driverTrip setValue:dateHour forKey:@"date_hour"];
            [driverTrip setValue:isGoing forKey:@"is_going"];
            [driverTrip setValue:availableSeats.text forKey:@"max_seats"];
            [driverTrip setValue:availableSeats.text forKey:@"available_seats"];
            [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] intValue]] forKey:@"tenant_id"];
            [driverTripArray addObject:driverTrip];
        }
    }
    //Jueves
    if ([buttonThursday isSelected]) {
        //Se recupera hora para dia lunes
        daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"thursday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"thursday%@", travelType]];
        //Se valida que tenga horario programado para ese dia
        if (![daySchedule isEqualToString:@""] && daySchedule != nil) {
            //Se recupera fecha del procimo dia seleccionado
            dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:5],daySchedule];
            NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
            [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"id"] longValue]] forKey:@"user_id"];
            [driverTrip setValue:dateHour forKey:@"date_hour"];
            [driverTrip setValue:isGoing forKey:@"is_going"];
            [driverTrip setValue:availableSeats.text forKey:@"max_seats"];
            [driverTrip setValue:availableSeats.text forKey:@"available_seats"];
            [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] intValue]] forKey:@"tenant_id"];
            [driverTripArray addObject:driverTrip];
        }
    }
    //Viernes
    if ([buttonFriday isSelected]) {
        //Se recupera hora para dia lunes
        daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"friday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"friday%@", travelType]];
        //Se valida que tenga horario programado para ese dia
        if (![daySchedule isEqualToString:@""] && daySchedule != nil) {
            //Se recupera fecha del procimo dia seleccionado
            dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:1],daySchedule];
            NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
            [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"id"] longValue]] forKey:@"user_id"];
            [driverTrip setValue:dateHour forKey:@"date_hour"];
            [driverTrip setValue:isGoing forKey:@"is_going"];
            [driverTrip setValue:availableSeats.text forKey:@"max_seats"];
            [driverTrip setValue:availableSeats.text forKey:@"available_seats"];
            [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] intValue]] forKey:@"tenant_id"];
            [driverTripArray addObject:driverTrip];
        }
    }
    //Sabado
    if ([buttonSaturday isSelected]) {
        //Se recupera hora para dia lunes
        daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"saturday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"saturday%@", travelType]];
        //Se valida que tenga horario programado para ese dia
        if (![daySchedule isEqualToString:@""] && daySchedule != nil) {
            //Se recupera fecha del procimo dia seleccionado
            dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:6],daySchedule];
            NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
            [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"id"] longValue]] forKey:@"user_id"];
            [driverTrip setValue:dateHour forKey:@"date_hour"];
            [driverTrip setValue:isGoing forKey:@"is_going"];
            [driverTrip setValue:availableSeats.text forKey:@"max_seats"];
            [driverTrip setValue:availableSeats.text forKey:@"available_seats"];
            [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] intValue]] forKey:@"tenant_id"];
            [driverTripArray addObject:driverTrip];
        }
    }
}

-(void) clearMap {
    [self.selectRouteMap clear];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[staticLatitude doubleValue]
                                                            longitude:[staticLongitude doubleValue]
                                                                 zoom:16];
    selectRouteMap.camera = camera;
    selectRouteMap.myLocationEnabled = YES;
    _coordinates = [NSMutableArray new];
    _routeController = [LRouteController new];
    
    _markerStart = [GMSMarker new];
    _markerFinish = [GMSMarker new];
}

-(void) reloadMarkersByUserType{
    //Se actualiza valor de switch
    if([switchUserType isOn]){
        [searchPassengerTravels setHidden:NO];
        [saveDriverTravel setHidden:YES];
        [availableSeats setHidden:YES];
        [availableSeatsLabel setHidden:YES];
    }
    else{
        [searchPassengerTravels setHidden:YES];
        [saveDriverTravel setHidden:NO];
        [availableSeats setHidden:NO];
        [availableSeatsLabel setHidden:NO];
    }
    
    //Se crea marca inicial en caso de ser conductor para definir destino por tenant
    GMSMarker *rootMarker = [[GMSMarker alloc] init];
    rootMarker.position = CLLocationCoordinate2DMake([staticLatitude doubleValue], [staticLongitude doubleValue]);
    NSMutableDictionary *markPosition = [[NSMutableDictionary alloc] init];
    [markPosition setValue:[NSString stringWithFormat:@"%f", [staticLatitude doubleValue]] forKey:@"latitude"];
    [markPosition setValue:[NSString stringWithFormat:@"%f", [staticLongitude doubleValue]] forKey:@"longitude"];
    if (![[self.travelTypeSelect text] isEqualToString:@"Ida"]) {
        [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[staticLatitude doubleValue] longitude:[staticLongitude doubleValue]]];
        rootMarker.title = @"Salida";
        rootMarker.snippet = @"Medellin";
        rootMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        rootMarker.map = self.selectRouteMap;
    }
    else{
        rootMarker.title = @"Llegada";
        rootMarker.snippet = @"Medellin";
        rootMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        rootMarker.map = self.selectRouteMap;
    }
}

@end
