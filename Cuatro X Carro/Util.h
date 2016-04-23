//
//  Util.h
//  Cuatro X Carro
//
//  Created by Julio Cesar Diaz on 11/7/15.
//  Copyright © 2015 IT Economics SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface Util : NSObject{
    void (^_completionHandler)(bool someParameter);
}

@property (nonatomic, strong) NSString *userEmail;

+(Util*)getInstance;
- (NSMutableDictionary *) constructUserDefaults:(NSDictionary * )userData;
- (void) updateUserDefaults:(void(^)(bool))handler;
- (NSString *) ampmTimeToMilitaryTime:(NSString *) time;
- (NSString *) militaryTimeToAMPMTime:(NSString *) time;
- (NSString *) nextDateByDay:(int) day;
- (void) buildRoute:(NSMutableArray *) steps withSecond:(long) tenantId withThird:(GMSPolyline *) polyline withFourth:(GMSMarker *) markerStart withFifth:(GMSMarker *) markerFinish withSixth:(GMSMapView *) routeMap;
-(NSMutableDictionary *) getGlobalProperties;
-(void) userNotifications;

@end
