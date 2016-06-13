//
//  Util.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 11/7/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "Util.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation Util{
    NSMutableDictionary *globalProperties;
}

@synthesize userEmail;

static Util *instance =nil;
+(Util *)getInstance {
    @synchronized(self) {
        if(instance==nil) {
            instance= [Util new];
        }
    }
    return instance;
}
-(NSMutableDictionary *) getGlobalProperties{
    globalProperties = [NSMutableDictionary new];
    [globalProperties setValue:@"http://192.168.0.12:5000" forKey:@"host"];
    //[globalProperties setValue:@"http://localhost:5000" forKey:@"host"];
    //[globalProperties setValue:@"http://52.10.216.232:5000" forKey:@"host"];
    return globalProperties;
}

- (NSMutableDictionary *) constructUserDefaults:(NSDictionary * ) jsonData{
    
    NSArray *result = [jsonData valueForKey:@"result"];
    NSDictionary *userData = result[0];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userDataDefault = [[NSMutableDictionary alloc] init];
    [userDataDefault setValue:[userData valueForKey:@"id"] forKey:@"id"];
    [userDataDefault setValue:[userData valueForKey:@"password"] forKey:@"password"];
    [userDataDefault setValue:([userData valueForKey:@"car_model"] != (id)[NSNull null]) ? [userData valueForKey:@"car_model"]: @"" forKey:@"car_model"];
    [userDataDefault setValue:[userData valueForKey:@"tenant_id"] forKey:@"tenant_id"];
    [userDataDefault setValue:[userData valueForKey:@"is_tracked"] forKey:@"is_tracked"];
    [userDataDefault setValue:[userData valueForKey:@"is_deleted"] forKey:@"is_deleted"];
    [userDataDefault setValue:([userData valueForKey:@"address"] != (id)[NSNull null]) ? [userData valueForKey:@"address"]: @"" forKey:@"address"];
    [userDataDefault setValue:[userData valueForKey:@"city_id"] forKey:@"city_id"];
    [userDataDefault setValue:[userData valueForKey:@"email"] forKey:@"email"];
    [userDataDefault setValue:([userData valueForKey:@"rating"] != (id)[NSNull null]) ? [userData valueForKey:@"rating"]: @"" forKey:@"rating"];
    [userDataDefault setValue:([userData valueForKey:@"car_color"] != (id)[NSNull null]) ? [userData valueForKey:@"car_color"]: @"" forKey:@"car_color"];
    [userDataDefault setValue:([userData valueForKey:@"license_plate"] != (id)[NSNull null]) ? [userData valueForKey:@"license_plate"]: @"" forKey:@"license_plate"];
    [userDataDefault setValue:[userData valueForKey:@"name"] forKey:@"name"];
    [userDataDefault setValue:([userData valueForKey:@"phone"] != (id)[NSNull null]) ? [userData valueForKey:@"phone"]: @"" forKey:@"phone"];
    [userDataDefault setValue:([userData valueForKey:@"schedule"] != (id)[NSNull null]) ? [userData valueForKey:@"schedule"]: @"" forKey:@"schedule"];
    [userDataDefault setValue:([userData valueForKey:@"is_driver"] != (id)[NSNull null]) ? [userData valueForKey:@"is_driver"]: @"" forKey:@"is_driver"];
    [userDataDefault setValue:[userData valueForKey:@"start_date"] forKey:@"start_date"];
    [userDataDefault setValue:[userData valueForKey:@"is_enabled"] forKey:@"is_enabled"];
    [userDataDefault setValue:([userData valueForKey:@"profile_picture_url"] != (id)[NSNull null]) ? [userData valueForKey:@"profile_picture_url"]: @"" forKey:@"profile_picture_url"];
    [userDefault setObject:userDataDefault forKey:@"userData"];
    
    return userDataDefault;
}

- (void) updateUserDefaults:(void(^)(bool))handler{
    
    //Se recupera email de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
    userEmail = [dataUser objectForKey:@"email"];
    
    //Se recupera informacion de usuario
    NSMutableDictionary *globalProp = [self getGlobalProperties];
    NSString *urlServer = [NSString stringWithFormat:@"%@/getUserDataByEmail", [globalProp valueForKey:@"host"]];
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"email=%@",
                      userEmail];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //Se captura numero d eparametros a enviar
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    //Se configura request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: urlServer]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    //Gestionar callback
    _completionHandler = [handler copy];
    
    //Se ejecuta request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        dispatch_async(dispatch_get_main_queue(),^{
            //Se convierte respuesta en JSON
            NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
            id isValid = [jsonData valueForKey:@"valid"];
            
            if (isValid ? [isValid boolValue] : NO) {
                [self constructUserDefaults:jsonData];
                NSLog(@"requestReply: %@", requestReply);
                _completionHandler(true);
            }
            else{
                _completionHandler(false);
                NSLog(@"requestReply: %@", requestReply);
            }
            
            _completionHandler = nil;
        });
     }] resume];
}

- (NSString *) ampmTimeToMilitaryTime:(NSString *) time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *AMPMDepartTimeFormat = [dateFormatter dateFromString: time];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *militaryDepartTime = [dateFormatter stringFromDate:AMPMDepartTimeFormat];
    
    return militaryDepartTime;
}

- (NSString *) militaryTimeToAMPMTime:(NSString *) time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *MilitaryDepartTimeFormat = [dateFormatter dateFromString: time];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *AMPMDepartTime = [dateFormatter stringFromDate:MilitaryDepartTimeFormat];
    
    return AMPMDepartTime;
}

- (NSString *) nextDateByDay:(int) day{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    NSInteger todayWeekday = [weekdayComponents weekday];
    
    enum Weeks {
        SUNDAY = 1,
        MONDAY,
        TUESDAY,
        WEDNESDAY,
        THURSDAY,
        FRIDAY,
        SATURDAY
    };
    
    NSInteger moveDays=day-todayWeekday;
    if (moveDays<=0) {
        moveDays+=7;
    }
    
    NSDateComponents *components = [NSDateComponents new];
    components.day=moveDays;
    
    NSCalendar *calendar=[[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate* newDate = [calendar dateByAddingComponents:components toDate:date options:0];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormat stringFromDate:newDate];
    
    return dateString;
}

-(void) buildRoute:(NSMutableArray *) steps withSecond:(long) tenantId withThird:(GMSPolyline *) polyline withFourth:(GMSMarker *) markerStart withFifth:(GMSMarker *) markerFinish withSixth:(GMSMapView *) routeMap {
    NSMutableDictionary *initialPosition = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *finalPosition = [[NSMutableDictionary alloc] init];
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<steps.count; i++) {
        NSMutableDictionary *step = [[NSMutableDictionary alloc] init];
        step = [steps objectAtIndex:i];
        [path addCoordinate:CLLocationCoordinate2DMake([[step valueForKey:@"latitude"] doubleValue], [[step valueForKey:@"longitude"] doubleValue])];
        if (i == 0) {
            initialPosition = step;
        }
        if (i == (steps.count - 1)) {
            finalPosition = step;
        }
    }
    
    polyline.map = nil;
    markerStart.map = nil;
    markerFinish.map = nil;
    
    if ([steps count] > 1){
        
        //Se actualiza posicion de camara en mapa con primer puento de aprtida
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[initialPosition valueForKey:@"latitude"] doubleValue]
                                                                longitude:[[initialPosition valueForKey:@"longitude"] doubleValue]
                                                                     zoom:14];
        routeMap.camera = camera;
        
        //Se construye polilinea
        GMSPolyline *routPolyline = [GMSPolyline polylineWithPath:path];
        polyline = routPolyline;
        //Color de linea por gradiente
        GMSStrokeStyle *greenToRed = [GMSStrokeStyle gradientFromColor:[UIColor greenColor] toColor:[UIColor blueColor]];
        polyline.spans = @[[GMSStyleSpan spanWithStyle:greenToRed]];
        polyline.strokeWidth = 3.f;
        polyline.map = routeMap;
        //Marca final
        CLLocationCoordinate2D finalPositionLocation = CLLocationCoordinate2DMake([[finalPosition valueForKey:@"latitude"] doubleValue], [[finalPosition valueForKey:@"longitude"] doubleValue]);
        markerFinish.position = finalPositionLocation;
        markerFinish.map = routeMap;
        markerFinish.title = @"Llegada";
        markerFinish.snippet = @"Medellin";
        markerFinish.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        //Marca inicial
        CLLocationCoordinate2D initialPositionLocation = CLLocationCoordinate2DMake([[initialPosition valueForKey:@"latitude"] doubleValue], [[initialPosition valueForKey:@"longitude"] doubleValue]);
        markerStart.position = initialPositionLocation;
        markerStart.map = routeMap;
        markerStart.title = @"Salida";
        markerStart.snippet = @"Medellin";
        markerStart.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    }
}

-(void) userNotifications:(NSString *)deleteToken {
    //1.Se valida que el usuario este logueado
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userData = [defaults objectForKey:@"userData"];
    NSMutableDictionary *deviceTokenData = [defaults objectForKey:@"deviceTokenData"];
    if(userData != nil && deviceTokenData != nil){
        //2.Validar que el token no se encuentre asignado al usuario logueado
        if([[deviceTokenData valueForKey:@"associateToUser"] isEqualToString:@"false"] || [deleteToken isEqualToString:@"true"]){
            
            //Se ejecuta validacion de usuario
            NSLog(@"Se inicia actualizacion de token de usuario");
            //Se recupera host para peticiones
            NSMutableDictionary *globalProp = [self getGlobalProperties];
            NSString *urlServer = [NSString stringWithFormat:@"%@/queryUserDeviceToken", [globalProp valueForKey:@"host"]];
            NSLog(@"url saveUser: %@", urlServer);
            
            //Se configura data a enviar
            NSString *post = [NSString stringWithFormat:
                              @"user_id=%@&token=%@&device_type=%@&is_deleted=%@",[userData objectForKey:@"id"], [deviceTokenData valueForKey:@"deviceToken"], @"ios", deleteToken];
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
                        NSMutableDictionary *updateDeviceTokenData = [NSMutableDictionary new];
                        [updateDeviceTokenData setValue:[deviceTokenData valueForKey:@"deviceToken"] forKey:@"deviceToken"];
                        if([deleteToken isEqualToString:@"false"]){
                            [updateDeviceTokenData setValue:@"true" forKey:@"associateToUser"];
                            [defaults setObject:updateDeviceTokenData forKey:@"deviceTokenData"];
                            [self updateUserDefaults:^(bool result){}];
                        }else{
                            [updateDeviceTokenData setValue:@"false" forKey:@"associateToUser"];
                            [defaults setObject:updateDeviceTokenData forKey:@"deviceTokenData"];
                        }
                    }
                });
            }] resume];
        }
    }
}

@end
