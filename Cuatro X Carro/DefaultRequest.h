//
//  DefaultRequest.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 11/7/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultRequest : NSObject

+(DefaultRequest*)getInstance;
-(NSMutableDictionary*) getUserDefault;

@end
