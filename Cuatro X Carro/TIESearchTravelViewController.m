//
//  TIESearchTravelViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIESearchTravelViewController.h"
#import "ActionSheetPicker.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Util.h"

@interface TIESearchTravelViewController (){
    NSMutableArray *scheduleDayArray;
    NSMutableArray *stepArray;
    NSMutableArray *searchResults;
    NSMutableDictionary *searchResultsFilterByDay;
    Util *util;
    NSNumber *isGoing;
    NSMutableArray *daysArray;
    Boolean applyFilterByDay;
    NSMutableDictionary *userData;
    GMSPolyline *polyline;
    GMSMarker *markerStart;
    GMSMarker *markerFinish;
    NSMutableDictionary *selectedTrip;
}
@end

@implementation TIESearchTravelViewController

@synthesize searchRouteMap, daySelect, driverName;

- (id)initWithSearchData:(NSMutableArray *) aScheduleDayArray withSecond:(NSMutableArray *) aStepArray withThird:(NSNumber *) aIsGoing withFourth:(NSMutableArray *) aDaysArray{
    self = [super initWithNibName:@"TIESearchTravelViewController" bundle:nil];
    if (self) {
        scheduleDayArray = aScheduleDayArray;
        stepArray = aStepArray;
        searchResults = [[NSMutableArray alloc] init];
        isGoing = aIsGoing;
        daysArray = aDaysArray;
    }
    return self;
}

- (void)viewDidLoad {
    if ([isGoing isEqual:[NSNumber numberWithInt:1]]) {
        self.navigationController.navigationBar.topItem.title = @"Viajes de Ida";
    }
    else{
        self.navigationController.navigationBar.topItem.title = @"Viajes de Regreso";
    }
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:6.251099
                                                            longitude:-75.574912
                                                                 zoom:12];
    self.searchRouteMap.camera = camera;
    self.searchRouteMap.myLocationEnabled = YES;
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
    
    //Se inicializan variables locales
    selectedTrip = [[NSMutableDictionary alloc] init];
    
    //Se recuperan datos de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userData = [defaults objectForKey:@"userData"];
    
    //Se setea primer valor de dìa en combo
    daySelect.text = [daysArray objectAtIndex:0];
    searchResultsFilterByDay = [[NSMutableDictionary alloc] init];
    
    //Se activa bandera para filtrar elementos por dia una sola vez
    applyFilterByDay = true;
    
    [self searchPassengerTrip];
}

//Personalizar boton atras
-(void)backButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Se determina numero de filas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResults count];
}
//Se configura celda a cargar en la tabla
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Se crea instancia de celda
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //Se valida que la celda esta vacia para llenarla
    if (!cell)
    {
        //Se agrega vista cargada con celda a tabla
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    result = [searchResults objectAtIndex:indexPath.row];
    
    //Se organiza texto en celda
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
    NSString *dayOfWeek = @"";
    NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
    [yearFormat setDateFormat:@"yyyy"];
    [yearFormat setLocale:usLocale];
    NSDateFormatter *monthFormat = [[NSDateFormatter alloc] init];
    [monthFormat setDateFormat:@"MMM"];
    [monthFormat setLocale:usLocale];
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init] ;
    [dayFormat setDateFormat:@"EEEE dd"];
    [dayFormat setLocale:usLocale];
    NSString *dateStr = [[result valueForKey:@"date_hour"] substringToIndex:10];
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateNSDate = [dateFormat dateFromString:dateStr];
    NSString *cellText = [NSString stringWithFormat:@"%@ de %@ de %@.", [[dayFormat stringFromDate:dateNSDate] capitalizedString], [[monthFormat stringFromDate:dateNSDate] capitalizedString], [yearFormat stringFromDate:dateNSDate]];
    
    if ([result valueForKey:@"is_going"] ? [[result valueForKey:@"is_going"] boolValue] : NO) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", cellText];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    }
    else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@", cellText];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    }
    cell.tag = [[result valueForKey:@"id"] integerValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Hora: %@",[util militaryTimeToAMPMTime:[[[result valueForKey:@"date_hour"] substringFromIndex:11] substringToIndex:5]] ];
    
    if (applyFilterByDay) {
        NSDateFormatter *dayOfWeekFormat = [[NSDateFormatter alloc] init] ;
        [dayOfWeekFormat setDateFormat:@"EEEE"];
        [dayOfWeekFormat setLocale:usLocale];
        dayOfWeek = [dayOfWeekFormat stringFromDate:dateNSDate];
        dayOfWeek = [dayOfWeek capitalizedString];
        NSString *indexStr = [@([daysArray indexOfObject:dayOfWeek]) stringValue];
        //Se obtiene el arreglo almacenado ultimamente para este indice
        NSMutableArray *filterArray = [searchResultsFilterByDay objectForKey:indexStr] != nil ? [searchResultsFilterByDay objectForKey:indexStr] : [[NSMutableArray alloc] init];
        [searchResultsFilterByDay setValue:filterArray forKey:indexStr];
    }
        
    return cell;
}


#pragma Busqueda de viajes de pasajero
-(void) searchPassengerTrip{
    //Se envia peticion por POST
    NSString *urlServer = @"http://127.0.0.1:5000/searchPassengerTripsIOS";
    //Se configura data a enviar
    NSData * jsonData1 = [NSJSONSerialization  dataWithJSONObject:scheduleDayArray options:0 error:nil];
    NSString *scheduleDayArrayString = [[NSString alloc] initWithData:jsonData1   encoding:NSUTF8StringEncoding];
    NSData * jsonData2 = [NSJSONSerialization  dataWithJSONObject:stepArray options:0 error:nil];
    NSString *stepArrayString = [[NSString alloc] initWithData:jsonData2   encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:
                      @"trips=%@&route=%@",
                      scheduleDayArrayString,
                      stepArrayString];
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
            
            if (!isValid ? [isValid boolValue] : NO) {
                UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                        message:[jsonData objectForKey:@"error"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                [alertSaveUser show];
            }
            else{
                NSData *data = [[jsonData objectForKey:@"result"] dataUsingEncoding:NSUTF8StringEncoding];
                if (searchResults == nil) {
                    UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                            message:@"No se encontraron viajes disponibles."
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                    [alertSaveUser show];
                }
                else{
                    //Se carga elemnto con todos los viajes
                    searchResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [searchResultsFilterByDay setValue:searchResults forKey:@"0"];
                    [self.resultTableView reloadData];
                }
            }
        });
    }] resume];
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Se recuperan datos de viaje
    NSMutableDictionary *tripInfo = [searchResults objectAtIndex:indexPath.row];
    //Se actualiza objeto de viaje seleccionado
    selectedTrip = tripInfo;
    //Se carga nombre de conductor
    //driverName.text = [tripInfo valueForKey:@"user_id"];
    //Se carga ruta en mapa
    [self.searchRouteMap clear];
    markerStart = [GMSMarker new];
    markerFinish = [GMSMarker new];
    [util buildRoute:[tripInfo valueForKey:@"route"] withSecond:[[tripInfo valueForKey:@"tenant_id"] longValue] withThird:polyline withFourth:markerStart withFifth:markerFinish withSixth:self.searchRouteMap];
}

- (IBAction)DaySelect:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
            NSString *indexStr = [@([daysArray indexOfObject:selectedValue]) stringValue];
            searchResults = [searchResultsFilterByDay objectForKey:indexStr];
            applyFilterByDay = false;
            [self.resultTableView reloadData];
        }
        [self.daySelect  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"No se selecciono dia");
    };
    
    NSArray *dayItems = daysArray;
    [ActionSheetStringPicker showPickerWithTitle:@"Dia de viaje" rows:dayItems initialSelection:0
                                       doneBlock:done cancelBlock:cancel origin:sender];
    [self.daySelect setEnabled:NO];
}

#pragma Solicitud de viajes
- (IBAction)RequestTrip:(id)sender {
    //Cargar ruta de viaje en mapa y nombre de conductor
    //Se recupera informacion de usuario
    NSString *urlServer = @"http://127.0.0.1:5000/requestPassengerTripIOS";
    //Se configura data a enviar
    //Se obtiene fecha del mismo dia de viaje
    NSString *dateHour = @"";
    for (int j=0; j<scheduleDayArray.count; j++) {
        NSMutableDictionary *dateOpt = [scheduleDayArray objectAtIndex:j];
        if ([[[selectedTrip objectForKey:@"date_hour"] substringToIndex:10] isEqualToString:[[dateOpt valueForKey:@"date_hour"] substringToIndex:10]]) {
            dateHour = [dateOpt valueForKey:@"date_hour"];
        }
    }
    NSMutableDictionary *passengerTrip = [[NSMutableDictionary alloc] init];
    //[passengerTrip setValue:[selectedTrip valueForKey:@"id"] forKey:@"driver_trip_id"];
    [passengerTrip setValue:[userData valueForKey:@"id"] forKey:@"user_id"];
    [passengerTrip setValue:dateHour forKey:@"date_hour"];
    [passengerTrip setValue:[[stepArray lastObject] valueForKey:@"latitude"] forKey:@"latitude"];
    [passengerTrip setValue:[[stepArray lastObject] valueForKey:@"longitude"] forKey:@"longitude"];
    [passengerTrip setValue:isGoing forKey:@"is_going"];
    [passengerTrip setValue:[userData valueForKey:@"tenant_id"] forKey:@"tenant_id"];
    NSData * jsonData1 = [NSJSONSerialization  dataWithJSONObject:passengerTrip options:0 error:nil];
    NSString *passengerTripString = [[NSString alloc] initWithData:jsonData1   encoding:NSUTF8StringEncoding];
    NSData * jsonData2 = [NSJSONSerialization  dataWithJSONObject:selectedTrip options:0 error:nil];
    NSString *selectedTripString = [[NSString alloc] initWithData:jsonData2   encoding:NSUTF8StringEncoding];
    NSString *post = [NSString stringWithFormat:
                      @"passenger=%@&driver=%@",
                      passengerTripString, selectedTripString];
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
            
            NSString *message = @"Solicitud enviada correctamente. Sera notificado si el conductor acepta su solicitud.";
            if (!(isValid ? [isValid boolValue] : NO)) {
                message = [jsonData valueForKey:@"description"];
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
@end
