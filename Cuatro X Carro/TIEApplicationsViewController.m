//
//  TIEApplicationsViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/27/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIEApplicationsViewController.h"

@interface TIEApplicationsViewController (){
    NSString *tripId;
    NSString *maxSeats;
    NSMutableArray *applications;
    NSMutableDictionary *selectedApplication;
}

@end

@implementation TIEApplicationsViewController

@synthesize applicantName, applicantEmail, applicantPhone, applicantAddress;

- (id) initWithTripId:(NSString *) aTripId withSecond:(NSString *) aMaxSeats{
    self = [super initWithNibName:@"TIEApplicationsViewController" bundle:nil];
    if (self) {
        tripId = aTripId;
        maxSeats = aMaxSeats;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Solicitudes";
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Atras"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(backButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = newBackButton;
    
    //Se inicalizan variables locales
    applications = [[NSMutableArray alloc] init];
    selectedApplication = [[NSMutableDictionary alloc] init];
    
    [self getApplications];
}

- (void) getApplications{
    //Se recupera informacion de usuario
    NSString *urlServer = @"http://127.0.0.1:5000/queryRequestTrips";
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"id=%@",
                      tripId];
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
                applications = [jsonData valueForKey:@"result"];
                [self.applicationsTableView reloadData];
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

//Se determina numero de filas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [applications count];
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
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([applications count] > 0) {
        NSMutableDictionary *application = [applications objectAtIndex:indexPath.row];
        cell.textLabel.text = [application valueForKey:@"name"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *application = [applications objectAtIndex:indexPath.row];
    selectedApplication = application;
    applicantName.text = [application valueForKey:@"name"];
    applicantEmail.text = [application valueForKey:@"email"];
    applicantPhone.text = ([application valueForKey:@"phone"] != (id)[NSNull null]) ? [application valueForKey:@"phone"] : @"000000000";
    applicantAddress.text = ([application valueForKey:@"address"] != (id)[NSNull null]) ? [application valueForKey:@"address"] : @"Clle XXX Nro XX-XXXX";
}

- (IBAction)AcceptingApplication:(id)sender {
    if ([selectedApplication count] > 0) {
        //Se recupera informacion de usuario
        NSString *urlServer = @"http://127.0.0.1:5000/saveRequestTripIOS";
        //Se configura data a enviar
        NSMutableDictionary *driverTrip = [[NSMutableDictionary alloc] init];
        [driverTrip setValue:maxSeats forKey:@"max_seats"];
        [driverTrip setValue:tripId forKey:@"id"];
        NSData * jsonData1 = [NSJSONSerialization  dataWithJSONObject:driverTrip options:0 error:nil];
        NSString *driverTripString = [[NSString alloc] initWithData:jsonData1   encoding:NSUTF8StringEncoding];
        NSMutableDictionary *passengerTrip = [[NSMutableDictionary alloc] init];
        [passengerTrip setValue:[selectedApplication valueForKey:@"passenger_trip_id"] forKey:@"passenger_trip_id"];
        NSData * jsonData2 = [NSJSONSerialization  dataWithJSONObject:passengerTrip options:0 error:nil];
        NSString *passengerTripString = [[NSString alloc] initWithData:jsonData2   encoding:NSUTF8StringEncoding];
        NSString *post = [NSString stringWithFormat:
                          @"trip=%@&passenger=%@",
                          driverTripString, passengerTripString];
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
                
                NSString *message = @"Solicitud alamcenada correctamnte";
                if (!(isValid ? [isValid boolValue] : NO)) {
                    message = [jsonData valueForKey:@"description"];
                }
                else{
                    [self getApplications];
                    applications = [[NSMutableArray alloc] init];
                    selectedApplication = [[NSMutableDictionary alloc] init];
                }
                UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                        message: message
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                [alertSaveUser show];
            });
        }] resume];
    }
    else{
        UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                message: @"Debe seleccionar una solicitud."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [alertSaveUser show];
    }
}

- (IBAction)CancelApplication:(id)sender {
}
@end
