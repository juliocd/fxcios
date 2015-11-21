//
//  Util.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 11/7/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "Util.h"

@implementation Util

static Util *instance =nil;
+(Util *)getInstance {
    @synchronized(self) {
        if(instance==nil) {
            instance= [Util new];
        }
    }
    return instance;
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
    [userDefault setObject:userDataDefault forKey:@"userData"];
    
    return userDataDefault;
}

@end
