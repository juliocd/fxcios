//
//  TIERatingDriverViewController.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz M on 6/14/16.
//  Copyright © 2016 IT Economics SAS. All rights reserved.
//

#import "TIERatingDriverViewController.h"
#import "Util.h"

@interface TIERatingDriverViewController ()

@end

@implementation TIERatingDriverViewController

    long ratingValue;

@synthesize starOne, starTwo, starThree, starFour, starFive, activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    ratingValue = 0;
    activityIndicator.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SelectRating:(id)sender {
    
    switch ([sender tag]) {
        case 1:
            ratingValue = [sender tag];
            starOne.image = [UIImage imageNamed:@"star_on.png"];
            starTwo.image = [UIImage imageNamed:@"star_off.png"];
            starThree.image = [UIImage imageNamed:@"star_off.png"];
            starFour.image = [UIImage imageNamed:@"star_off.png"];
            starFive.image = [UIImage imageNamed:@"star_off.png"];
            break;
        case 2:
            ratingValue = [sender tag];
            starOne.image = [UIImage imageNamed:@"star_on.png"];
            starTwo.image = [UIImage imageNamed:@"star_on.png"];
            starThree.image = [UIImage imageNamed:@"star_off.png"];
            starFour.image = [UIImage imageNamed:@"star_off.png"];
            starFive.image = [UIImage imageNamed:@"star_off.png"];
            break;
        case 3:
            ratingValue = [sender tag];
            starOne.image = [UIImage imageNamed:@"star_on.png"];
            starTwo.image = [UIImage imageNamed:@"star_on.png"];
            starThree.image = [UIImage imageNamed:@"star_on.png"];
            starFour.image = [UIImage imageNamed:@"star_off.png"];
            starFive.image = [UIImage imageNamed:@"star_off.png"];
            break;
        case 4:
            ratingValue = [sender tag];
            starOne.image = [UIImage imageNamed:@"star_on.png"];
            starTwo.image = [UIImage imageNamed:@"star_on.png"];
            starThree.image = [UIImage imageNamed:@"star_on.png"];
            starFour.image = [UIImage imageNamed:@"star_on.png"];
            starFive.image = [UIImage imageNamed:@"star_off.png"];
            break;
        case 5:
            ratingValue = [sender tag];
            starOne.image = [UIImage imageNamed:@"star_on.png"];
            starTwo.image = [UIImage imageNamed:@"star_on.png"];
            starThree.image = [UIImage imageNamed:@"star_on.png"];
            starFour.image = [UIImage imageNamed:@"star_on.png"];
            starFive.image = [UIImage imageNamed:@"star_on.png"];
            break;
            
        default:
            break;
    }
}

- (IBAction)SendRating:(id)sender {
    
    //Se recupera host para peticiones
    Util *util = [Util getInstance];
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    NSString *urlServer = [NSString stringWithFormat:@"%@/qualifyDriver", [util.getGlobalProperties valueForKey:@"host"]];
    NSLog(@"url saveUser: %@", urlServer);
    //Se configura data a enviar
    NSString *post = [NSString stringWithFormat:
                      @"user_id=%@&rating=%ld&trip_id=%@",
                      @"34",
                      ratingValue,
                      @"12"];
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
                [util updateUserDefaults:^(bool result){}];
            }
            else{
                UIAlertView *alertSaveUser = [[UIAlertView alloc] initWithTitle:@"Mensaje"
                                                                        message:[jsonData valueForKey:@"description"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                [alertSaveUser show];
            }
            [activityIndicator stopAnimating];
            activityIndicator.hidden = YES;
            [self.view removeFromSuperview];
            
        });
    }] resume];
}

@end
