//
//  TIETrayTravelsTableViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 9/20/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "TIETrayTravelsTableViewController.h"
#import "TIETravelCustomCellTableViewCell.h"
#import "TIETravelDetailsViewController.h"
#import "Util.h"

@interface TIETrayTravelsTableViewController (){
    Util *util;
}

@end

@implementation TIETrayTravelsTableViewController

@synthesize items;

- (NSArray *)items
{
    if (!items)
    {
        items = [[NSArray alloc] init];
    }
    return items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.contentInset = inset;
    
    //Se inicializa funcion de utilidades
    util = [Util getInstance];
}

- (void) viewWillAppear:(BOOL)animated{
    [self loadTrips];
}

- (void)didReceiveMemoryWarning {
    
}

- (void) loadTrips{
    //Se recupera email de usuario
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [defaults objectForKey:@"userData"];
    int userId = [[dataUser objectForKey:@"id"] intValue];
    
    NSString *urlServer = [NSString stringWithFormat:@"%@/queryAllUserTrips", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"userId=%i",
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
                items = [jsonData valueForKey:@"result"];
                [self.tableView reloadData];
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

//Se determina numero de filas de la tabla
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
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
    if ([items count] > 0) {
        NSMutableDictionary *item = [items objectAtIndex:indexPath.row];
        //Datos comunes
        cell.tripId.text = [[item valueForKey:@"id"] stringValue];
        cell.userNameLabel.text = [item valueForKey:@"driver_name"];
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
        //Datos de conductor
        if ([[item valueForKey:@"trip_type"] isEqualToString:@"Conductor"]) {
            cell.userType.text = @"CONDUCTOR";
            //////////////////Sillas disponibles
            int availableSeats = [item valueForKey:@"available_seats"] != nil ? [[item valueForKey:@"available_seats"] intValue] : 0;
            int maxSeats = [item valueForKey:@"max_seats"] != nil ? [[item valueForKey:@"max_seats"] intValue] : 0;
            cell.seatsAvailableLabel.text = [NSString stringWithFormat:@"%i/%i",availableSeats,maxSeats];
            //[self updateSeats:availableSeats withSecond:maxSeats withThirds:cell];
            //////////////////Calificacion de conductor
            int rating = [item valueForKey:@"driver_rating"] != nil ? [[item valueForKey:@"driver_rating"] intValue] : 0;
            [self updateDriverRating:rating withSecond:cell];
            //////////////////Solicitudes
            int request = [[item valueForKey:@"request"] intValue];
            if (request > 0) {
                cell.requestButton.tintColor = [UIColor orangeColor];
            }
            else{
                cell.requestButton.tintColor = [UIColor whiteColor];
            }
            //////////////////Notificaciones
            int notifications = [[item valueForKey:@"notifications"] intValue];
            if (notifications > 0) {
                cell.notificationButton.tintColor = [UIColor yellowColor];
            }
            else{
                cell.notificationButton.tintColor = [UIColor whiteColor];
            }
            cell.backgroundColor = [UIColor blueColor];
        }
        else{
            //Se actualizan cupos
            cell.quotasLabel.hidden = YES;
            cell.seatsAvailableLabel.hidden = YES;
            //Se oculta notificacion de solicitud
            cell.userType.text = @"PASAJERO";
            cell.requestButton.hidden = YES;
            cell.backgroundColor = [UIColor greenColor];
        }
        //Notificaciones
        //int notification = [[item valueForKey:@"notification"] intValue];
        int notification = 1;
        if (notification > 0) {
            cell.notificationButton.tintColor = [UIColor redColor];
        }
        UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 277, 58)];
        av.backgroundColor = [UIColor colorWithRed:(30/255.0) green:(190/255.0) blue:(219/255.0)alpha:1.0];
        av.opaque = NO;
        av.image = [UIImage imageNamed:@"viajes_box.png"];
        cell.backgroundView = av;
    }
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *item = [items objectAtIndex:indexPath.row];
    TIETravelDetailsViewController *detailViewController = [[TIETravelDetailsViewController alloc] initWithTripData:item];
    
    // Push the view controller.
    UINavigationController *trasformerNavC = [[UINavigationController alloc]initWithRootViewController:detailViewController];
    [self presentViewController:trasformerNavC animated:YES completion:nil];
}

#pragma mark - Funciones propias
- (void) updateSeats:(int) availableSeats withSecond:(int) maxSeats withThirds: (TIETravelCustomCellTableViewCell *) cell{
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self loadTrips];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

@end
