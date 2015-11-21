//
//  DefaultRequest.m
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 11/7/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import "DefaultRequest.h"
#import "Util.h"

@implementation DefaultRequest

static DefaultRequest *instance =nil;
+(DefaultRequest *)getInstance {
    @synchronized(self) {
        if(instance==nil) {
            instance= [DefaultRequest new];
        }
    }
    return instance;
}

-(NSMutableDictionary*) getUserDefault{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataUser = [userDefault objectForKey:@"userData"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString =[NSString stringWithFormat:@"http://127.0.0.1:5000/userData/%@/%@", [dataUser objectForKey:@"id"], [dataUser objectForKey:@"tenant_id"]];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    __block NSMutableDictionary *userDefaultData = [[NSMutableDictionary alloc] init];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
        
        NSData *dataResult = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataResult options:0 error:nil];
        id isValid = [jsonData valueForKey:@"valid"];
        
        if (!(isValid ? [isValid boolValue] : NO)) {
            Util *util=[Util getInstance];
            userDefaultData = [util constructUserDefaults:jsonData];
        }
        
    }] resume];
    
    return userDefaultData;
}

@end
