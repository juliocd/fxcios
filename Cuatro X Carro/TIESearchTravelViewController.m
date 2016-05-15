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
#import <QuartzCore/QuartzCore.h>
#import "TIETravelCustomCellTableViewCell.h"

@interface TIESearchTravelViewController (){
    NSMutableArray *scheduleDayArray;
    NSMutableArray *stepArray;
    NSMutableArray *searchResults;
    NSMutableDictionary *searchResultsFilterByDay;
    Util *util;
    NSNumber *isGoing;
    NSMutableArray *daysArray;
    NSMutableDictionary *userData;
    GMSPolyline *polyline;
    GMSMarker *markerStart;
    GMSMarker *markerFinish;
    NSMutableDictionary *selectedTrip;
}
@end

@implementation TIESearchTravelViewController

@synthesize searchRouteMap, daySelect, driverName, resultSearchTable;

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
    self.searchRouteMap.settings.myLocationButton = YES;
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
    
    //Se inicializan variables locales
    selectedTrip = [[NSMutableDictionary alloc] init];
    
    //Bordear esquinas de tabla
    resultSearchTable.layer.cornerRadius=5;
    
    //Se recuperan datos de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userData = [defaults objectForKey:@"userData"];
    
    //Se setea primer valor de dìa en combo
    daySelect.text = [daysArray objectAtIndex:0];
    searchResultsFilterByDay = [[NSMutableDictionary alloc] init];
    
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
    if(searchResults.count > 0){
        self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.resultTableView.backgroundView   = nil;
        return [searchResults count];
    }else{
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.resultTableView.bounds.size.width, self.resultTableView.bounds.size.height)];
        noDataLabel.text             = @"No se encontraron registros";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.resultTableView.backgroundView = noDataLabel;
        self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}
//Se configura celda a cargar en la tabla
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Se crea instancia de celda
    TIETravelCustomCellTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    //Se valida que la celda esta vacia para llenarla
    if (!cell)
    {
        //Se registra celda creda a archivo xib
        [tableView registerNib:[UINib nibWithNibName:@"TIETravelCustomCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"tableCell"];
        //Se agrega vista cargada con celda a tabla
        cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    }
    
    return cell;
}

//Se configuran datos de la celda
- (void)tableView:(UITableView *)tableView willDisplayCell:(TIETravelCustomCellTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([searchResults count] > 0) {
        NSMutableDictionary *item = [searchResults objectAtIndex:indexPath.row];
        //Datos comunes
        cell.tripId.text = [[item valueForKey:@"id"] stringValue];
        cell.userNameLabel.text = [item valueForKey:@"user_name"];
        if ([item valueForKey:@"is_going"] ? [[item valueForKey:@"is_going"] boolValue] : NO) {
            cell.tripType.text = @"Ida";
        }
        else{
            cell.tripType.text = @"Regreso";
        }
        NSString *dateTrip = [[item valueForKey:@"date_hour"] substringToIndex:10];
        NSArray *dateTripArray = [dateTrip componentsSeparatedByString:@"-"];
        cell.dateDayLabel.text = [NSString stringWithFormat:@"%@",dateTripArray[2]];
        cell.dateMonthLabel.text = [NSString stringWithFormat:@"%@",dateTripArray[1]];
        cell.dateYearLabel.text = [NSString stringWithFormat:@"%@",dateTripArray[0]];
        cell.timeLabel.text = [util militaryTimeToAMPMTime:[[[item valueForKey:@"date_hour"] substringFromIndex:11] substringToIndex:5]];
        //Sillas disponibles
        int availableSeats = [item valueForKey:@"available_seats"] != nil ? [[item valueForKey:@"available_seats"] intValue] : 0;
        int maxSeats = [item valueForKey:@"max_seats"] != nil ? [[item valueForKey:@"max_seats"] intValue] : 0;
        cell.seatsAvailableLabel.text = [NSString stringWithFormat:@"%i/%i",availableSeats,maxSeats];
        //Calificacion de conductor
        int rating = [item valueForKey:@"driver_rating"] != nil ? [[item valueForKey:@"driver_rating"] intValue] : 0;
        [self updateDriverRating:rating withSecond:cell];
        //Ocultar mensajes
        cell.notificationButton.hidden = YES;
        cell.requestButton.hidden = YES;
        cell.userType.hidden = YES;
        
        UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 277, 58)];
        av.backgroundColor = [UIColor whiteColor];
        av.opaque = NO;
        av.image = [UIImage imageNamed:@"viajes_box.png"];
        cell.backgroundView = av;
    }
}

-(void) updateDriverRating:(int) rating withSecond:(TIETravelCustomCellTableViewCell *) cell{
    for (int i=1; i<=5; i++) {
        switch (i) {
            case 1:
                if(rating >= i){
                    [cell.rateOneImage setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [cell.rateOneImage setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 2:
                if(rating >= i){
                    [cell.rateTwoImage setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [cell.rateTwoImage setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 3:
                if(rating >= i){
                    [cell.rateThreeImage setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [cell.rateThreeImage setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 4:
                if(rating >= i){
                    [cell.rateFourImage setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [cell.rateFourImage setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
            case 5:
                if(rating >= i){
                    [cell.rateFiveImage setImage:[UIImage imageNamed:@"star_on.png"]];
                }
                else{
                    [cell.rateFiveImage setImage:[UIImage imageNamed:@"star_off.png"]];
                }
                break;
                
            default:
                break;
        }
    }
}

#pragma Busqueda de viajes de pasajero
-(void) searchPassengerTrip{
    //Se recupera host para peticiones
    NSString *urlServer = [NSString stringWithFormat:@"%@/searchPassengerTripsIOS", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
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
                if (data == nil) {
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
    driverName.text = [tripInfo valueForKey:@"user_name"];
    //Se carga ruta en mapa
    [self.searchRouteMap clear];
    markerStart = [GMSMarker new];
    markerFinish = [GMSMarker new];
    [util buildRoute:[tripInfo valueForKey:@"route"] withSecond:[[tripInfo valueForKey:@"tenant_id"] longValue] withThird:polyline withFourth:markerStart withFifth:markerFinish withSixth:self.searchRouteMap];
}

#pragma mark - Select day
- (IBAction)DaySelect:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([sender respondsToSelector:@selector(setText:)]) {
            [sender performSelector:@selector(setText:) withObject:selectedValue];
            
            if(![selectedValue isEqualToString:@"Todos"]){
                //Se filtra por el dia de la semana
                NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSMutableArray *resultArrayByDay = [searchResultsFilterByDay objectForKey:@"0"];
                searchResults = [[NSMutableArray alloc] init];
                for(id resultByDay in resultArrayByDay) {
                    NSString *dateStr = [resultByDay valueForKey:@"date_hour"];
                    NSDate *dateNSDate = [dateFormat dateFromString:dateStr];
                    NSDateFormatter *dayOfWeekFormat = [[NSDateFormatter alloc] init] ;
                    [dayOfWeekFormat setDateFormat:@"EEEE"];
                    [dayOfWeekFormat setLocale:usLocale];
                     NSString *dayOfWeek = [dayOfWeekFormat stringFromDate:dateNSDate];
                    dayOfWeek = [dayOfWeek capitalizedString];
                    if([dayOfWeek isEqualToString:selectedValue]){
                        [searchResults addObject:resultByDay];
                    }
                }
            }else{
                //Se pasan todos los resultados
                searchResults = [searchResultsFilterByDay objectForKey:@"0"];
            }
            [self.resultTableView reloadData];
        }
        [self.daySelect  setEnabled:YES];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"No se selecciono dia");
    };
    NSArray *dayItems = daysArray;
    NSUInteger initialIndex = 0;
    if(![self.daySelect.text isEqualToString:@""] && [dayItems indexOfObject:self.daySelect.text] != -1){
        initialIndex = [dayItems indexOfObject:self.daySelect.text];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Dia de viaje" rows:dayItems initialSelection:initialIndex
                                       doneBlock:done cancelBlock:cancel origin:sender];
    [self.daySelect setEnabled:NO];
}

#pragma Solicitud de viajes
- (IBAction)RequestTrip:(id)sender {
    if([selectedTrip count] > 0){
        //Cargar ruta de viaje en mapa y nombre de conductor
        //Se recupera host para peticiones
        NSString *urlServer = [NSString stringWithFormat:@"%@/requestPassengerTripIOS", [util.getGlobalProperties valueForKey:@"host"]];
        NSLog(@"url saveUser: %@", urlServer);
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
        [passengerTrip setValue:[userData valueForKey:@"id"] forKey:@"user_id"];
        [passengerTrip setValue:dateHour forKey:@"date_hour"];
        if(isGoing == 0){
            [passengerTrip setValue:[[stepArray lastObject] valueForKey:@"latitude"] forKey:@"latitude"];
            [passengerTrip setValue:[[stepArray lastObject] valueForKey:@"longitude"] forKey:@"longitude"];
        }else{
            [passengerTrip setValue:[[stepArray firstObject] valueForKey:@"latitude"] forKey:@"latitude"];
            [passengerTrip setValue:[[stepArray firstObject] valueForKey:@"longitude"] forKey:@"longitude"];
        }
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
    }else{
        UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                message:@"Debe seleccionar un viaje."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [alertSaveUser show];
    }
}
@end
