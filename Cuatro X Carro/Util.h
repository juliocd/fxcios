//
//  Util.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 11/7/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+(Util*)getInstance;
- (NSMutableDictionary *) constructUserDefaults:(NSDictionary * )theNumber;

@end
