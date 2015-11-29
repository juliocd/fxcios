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
}

@synthesize  selectRouteMap, travelTypeSelect, searchPassengerTravels, switchUserType, saveDriverTravel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
    
    //Se obtiene informacion de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    dataUser = [defaults objectForKey:@"userData"];
    
    //Se fijan coodenadas inciales
    origLatitude = [NSNumber numberWithDouble:6.249710];
    origLongitude = [NSNumber numberWithDouble:-75.592273];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[origLatitude doubleValue]
                                                            longitude:[origLongitude doubleValue]
                                                                 zoom:16];
    selectRouteMap.camera = camera;
    selectRouteMap.myLocationEnabled = YES;
    selectRouteMap.delegate = self;
    _coordinates = [NSMutableArray new];
    _routeController = [LRouteController new];
    
    _markerStart = [GMSMarker new];
    _markerStart.title = @"Start";
    
    _markerFinish = [GMSMarker new];
    _markerFinish.title = @"Finish";
    
    //Se cargan valores de dias seleccionados;
    [buttonMonday setSelected:NO];
    [buttonTuesday setSelected:NO];
    [buttonWednesday setSelected:NO];
    [buttonThursday setSelected:NO];
    [buttonFriday setSelected:NO];
    [buttonSaturday setSelected:NO];
    
    //Se actualiza valor de switch
    if([switchUserType isOn]){
        [searchPassengerTravels setHidden:NO];
        [saveDriverTravel setHidden:YES];
    }
    else{
        //Se crea marca inicial en caso de ser conductor para definir destino por tenant
        GMSMarker *rootMarker = [[GMSMarker alloc] init];
        rootMarker.position = CLLocationCoordinate2DMake([origLatitude doubleValue], [origLongitude doubleValue]);
        NSMutableDictionary *markPosition = [[NSMutableDictionary alloc] init];
        [markPosition setValue:[NSString stringWithFormat:@"%f", [origLatitude doubleValue]] forKey:@"latitude"];
        [markPosition setValue:[NSString stringWithFormat:@"%f", [origLongitude doubleValue]] forKey:@"longitude"];
        [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[origLatitude doubleValue] longitude:[origLongitude doubleValue]]];
        rootMarker.title = @"Partida";
        rootMarker.snippet = @"Medellin";
        rootMarker.map = self.selectRouteMap;
        
        [searchPassengerTravels setHidden:YES];
        [saveDriverTravel setHidden:NO];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)searchRoute:(id)sender {
    TIESearchTravelViewController *searchTravelsVC = [[TIESearchTravelViewController alloc] init];
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:searchTravelsVC];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

#pragma Switch para seleccionar tipo de pasajero
- (IBAction)SwitchUserType:(id)sender {
    if ([sender isOn]) {
        [searchPassengerTravels setHidden:NO];
        [saveDriverTravel setHidden:YES];
        [self.selectRouteMap clear];
    }
    else{
        
        [self.selectRouteMap clear];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[origLatitude doubleValue]
                                                                longitude:[origLongitude doubleValue]
                                                                     zoom:16];
        selectRouteMap.camera = camera;
        //Se crea marca inicial en caso de ser conductor para definir destino por tenant
        GMSMarker *rootMarker = [[GMSMarker alloc] init];
        rootMarker.position = CLLocationCoordinate2DMake([origLatitude doubleValue], [origLongitude doubleValue]);
        NSMutableDictionary *markPosition = [[NSMutableDictionary alloc] init];
        [markPosition setValue:[NSString stringWithFormat:@"%f", [origLatitude doubleValue]] forKey:@"latitude"];
        [markPosition setValue:[NSString stringWithFormat:@"%f", [origLongitude doubleValue]] forKey:@"longitude"];
        [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[origLatitude doubleValue] longitude:[origLongitude doubleValue]]];
        rootMarker.title = @"Partida";
        rootMarker.snippet = @"Medellin";
        rootMarker.map = self.selectRouteMap;
        
        [searchPassengerTravels setHidden:YES];
        [saveDriverTravel setHidden:NO];
    }
}

#pragma Botones de chekbox
- (IBAction)CheckMonday:(id)sender {
    buttonMonday = sender;
    if([buttonMonday isSelected]){
        [buttonMonday setSelected:NO];
        [buttonMonday setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonMonday setSelected:YES];
        [buttonMonday setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckTuesday:(id)sender {
    buttonTuesday = sender;
    if([buttonTuesday isSelected]){
        [buttonTuesday setSelected:NO];
        [buttonTuesday setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonTuesday setSelected:YES];
        [buttonTuesday setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckWednesday:(id)sender {
    buttonWednesday = sender;
    if([buttonWednesday isSelected]){
        [buttonWednesday setSelected:NO];
        [buttonWednesday setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonWednesday setSelected:YES];
        [buttonWednesday setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckThursday:(id)sender {
    buttonThursday = sender;
    if([buttonThursday isSelected]){
        [buttonThursday setSelected:NO];
        [buttonThursday setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonThursday setSelected:YES];
        [buttonThursday setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckFriday:(id)sender {
    buttonFriday = sender;
    if([buttonFriday isSelected]){
        [buttonFriday setSelected:NO];
        [buttonFriday setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonFriday setSelected:YES];
        [buttonFriday setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)CheckSaturday:(id)sender {
    buttonSaturday = sender;
    if([buttonSaturday isSelected]){
        [buttonSaturday setSelected:NO];
        [buttonSaturday setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    else{
        [buttonSaturday setSelected:YES];
        [buttonSaturday setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
}

#pragma Boton de combo box de tipo de viaje
- (IBAction)SelectTravelType:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
        }
        [self.travelTypeSelect  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    
    NSArray *dayItems = [NSArray arrayWithObjects:@"Ida", @"Regreso", nil];
    [ActionSheetStringPicker showPickerWithTitle:@"Tipo de viaje" rows:dayItems initialSelection:0
                                       doneBlock:done cancelBlock:cancel origin:sender];
    [self.travelTypeSelect setEnabled:NO];
}

#pragma Botone para limpiar mapa
- (IBAction)ClearMap:(id)sender {
    
    [self.selectRouteMap clear];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[origLatitude doubleValue]
                                                            longitude:[origLongitude doubleValue]
                                                                 zoom:16];
    selectRouteMap.camera = camera;
    selectRouteMap.myLocationEnabled = YES;
    _coordinates = [NSMutableArray new];
    _routeController = [LRouteController new];
    
    _markerStart = [GMSMarker new];
    _markerStart.title = @"Start";
    
    _markerFinish = [GMSMarker new];
    _markerFinish.title = @"Finish";
    
    // Creates a marker in the center of the map.
    GMSMarker *rootMarker = [[GMSMarker alloc] init];
    rootMarker.position = CLLocationCoordinate2DMake([origLatitude doubleValue], [origLongitude doubleValue]);
    NSMutableDictionary *markPosition = [[NSMutableDictionary alloc] init];
    [markPosition setValue:[NSString stringWithFormat:@"%f", [origLatitude doubleValue]] forKey:@"latitude"];
    [markPosition setValue:[NSString stringWithFormat:@"%f", [origLongitude doubleValue]] forKey:@"longitude"];
    [_coordinates addObject:[[CLLocation alloc] initWithLatitude:[origLatitude doubleValue] longitude:[origLongitude doubleValue]]];
    rootMarker.title = @"Partida";
    rootMarker.snippet = @"Medellin";
    rootMarker.map = self.selectRouteMap;
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
    //Construir formato de hora a parti de horario
    NSString *dateHour = @"";
    NSString *strSchedule = [dataUser objectForKey:@"schedule"];
    NSMutableDictionary *schedule = [[NSMutableDictionary alloc] init];
    if (![strSchedule isEqual:@""]) {
        schedule = [NSJSONSerialization JSONObjectWithData:[strSchedule dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *daySchedule = @"";
        //Lunes
        if ([buttonMonday isSelected]) {
            //Se recupera hora para dia lunes
            daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"monday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"monday%@", travelType]];
            //Se valida que tenga horario programado para ese dia
            if (![daySchedule isEqualToString:@""]) {
                //Se recupera fecha del procimo dia seleccionado
                dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:2],daySchedule];
                NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
                [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"user_id"];
                [driverTrip setValue:dateHour forKey:@"date_hour"];
                [driverTrip setValue:isGoing forKey:@"is_going"];
                [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"tenant_id"];
                [driverTripArray addObject:driverTrip];
            }
        }
        //Martes
        if ([buttonTuesday isSelected]) {
            //Se recupera hora para dia lunes
            daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"tuesday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"tuesday%@", travelType]];
            //Se valida que tenga horario programado para ese dia
            if (![daySchedule isEqualToString:@""]) {
                //Se recupera fecha del procimo dia seleccionado
                dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:3],daySchedule];
                NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
                [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"user_id"];
                [driverTrip setValue:dateHour forKey:@"date_hour"];
                [driverTrip setValue:isGoing forKey:@"is_going"];
                [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"tenant_id"];
                [driverTripArray addObject:driverTrip];
            }
        }
        //Miercoles
        if ([buttonWednesday isSelected]) {
            //Se recupera hora para dia lunes
            daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"wednesday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"wednesday%@", travelType]];
            //Se valida que tenga horario programado para ese dia
            if (![daySchedule isEqualToString:@""]) {
                //Se recupera fecha del procimo dia seleccionado
                dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:4],daySchedule];
                NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
                [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"user_id"];
                [driverTrip setValue:dateHour forKey:@"date_hour"];
                [driverTrip setValue:isGoing forKey:@"is_going"];
                [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"tenant_id"];
                [driverTripArray addObject:driverTrip];
            }
        }
        //Jueves
        if ([buttonThursday isSelected]) {
            //Se recupera hora para dia lunes
            daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"thursday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"thursday%@", travelType]];
            //Se valida que tenga horario programado para ese dia
            if (![daySchedule isEqualToString:@""]) {
                //Se recupera fecha del procimo dia seleccionado
                dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:5],daySchedule];
                NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
                [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"user_id"];
                [driverTrip setValue:dateHour forKey:@"date_hour"];
                [driverTrip setValue:isGoing forKey:@"is_going"];
                [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"tenant_id"];
                [driverTripArray addObject:driverTrip];
            }
        }
        //Viernes
        if ([buttonFriday isSelected]) {
            //Se recupera hora para dia lunes
            daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"friday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"friday%@", travelType]];
            //Se valida que tenga horario programado para ese dia
            if (![daySchedule isEqualToString:@""]) {
                //Se recupera fecha del procimo dia seleccionado
                dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:1],daySchedule];
                NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
                [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"user_id"];
                [driverTrip setValue:dateHour forKey:@"date_hour"];
                [driverTrip setValue:isGoing forKey:@"is_going"];
                [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"tenant_id"];
                [driverTripArray addObject:driverTrip];
            }
        }
        //Sabado
        if ([buttonSaturday isSelected]) {
            //Se recupera hora para dia lunes
            daySchedule = ([schedule valueForKey:[NSString stringWithFormat:@"saturday%@", travelType]] == (id)[NSNull null]) ? @"" : [schedule valueForKey:[NSString stringWithFormat:@"saturday%@", travelType]];
            //Se valida que tenga horario programado para ese dia
            if (![daySchedule isEqualToString:@""]) {
                //Se recupera fecha del procimo dia seleccionado
                dateHour = [NSString stringWithFormat:@"%@ %@:00",[util nextDateByDay:6],daySchedule];
                NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
                [driverTrip setValue:[NSNumber numberWithLong:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"user_id"];
                [driverTrip setValue:dateHour forKey:@"date_hour"];
                [driverTrip setValue:isGoing forKey:@"is_going"];
                [driverTrip setValue:[NSNumber numberWithInt:[[dataUser objectForKey:@"tenant_id"] longValue]] forKey:@"tenant_id"];
                [driverTripArray addObject:driverTrip];
            }
        }
        
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:driverTripArray options:0 error:nil];
        NSString *driverTripString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        
        //Se recupera data de arreglo de puntos
        NSString *stepsString = [_routeController getStepArrayString];
        
        if (![stepsString isEqualToString:@""] && ![driverTripString isEqualToString:@"[]"]) {
            
            //Se envia peticion por POST
            NSString *urlServer = @"http://127.0.0.1:5000/saveSchedule";
            //Se configura data a enviar
            NSString *post = [NSString stringWithFormat:
                              @"schedule=%@&id=%@&tenant_id=%@",
                              @"",
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
                    else{
                        [util updateUserDefaults];
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
            UIAlertView *alertErrorLogin = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                      message:@"Debe crear una ruta en el mapa y seleccionar los dias correspondientes."
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

- (IBAction)SearchPassengerTravels:(id)sender {
}

#pragma Metodos de Google Maps
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    //Accion si es pasajero (solo poner funto de destino)
    if([switchUserType isOn]){
        [self.selectRouteMap clear];
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = @"Llegada";
        marker.snippet = @"Medellin";
        marker.map = selectRouteMap;
    }
    else{
        _polyline.map = nil;
        _markerStart.map = nil;
        _markerFinish.map = nil;
    
        [_coordinates addObject:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
    
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
                    //Marca final
                    _markerFinish.position = [[_coordinates lastObject] coordinate];
                    _markerFinish.map = selectRouteMap;
                    _markerFinish.title = @"Llegada";
                    _markerFinish.snippet = @"Medellin";
                    //Marcas intermedias
                    for (int i = 0;i < [_coordinates count]; i++) {
                        if (i !=0 && i != ([_coordinates count] -1)) {
                            GMSMarker *marker = [GMSMarker markerWithPosition:[[_coordinates objectAtIndex:i] coordinate]];
                            marker.title = [NSString stringWithFormat:@"Punto %d", i];
                            marker.map = selectRouteMap;
                        }
                    }
                    //Marca inicial
                    _markerStart.position = [[_coordinates objectAtIndex:0] coordinate];
                    _markerStart.map = selectRouteMap;
                }
            }];
        }
    }
}

@end
