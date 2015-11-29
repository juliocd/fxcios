#import <Foundation/Foundation.h>
@import GoogleMaps;


typedef enum tagTravelMode
{
    TravelModeDriving,
    TravelModeBicycling,
    TravelModeTransit,
    TravelModeWalking
}TravelMode;


@interface LRouteController : NSObject
{
    NSURLRequest *_request;
}


- (void)getPolylineWithLocations:(NSArray *)locations withsecond:(long)tenant_id travelMode:(TravelMode)travelMode andCompletitionBlock:(void (^)(GMSPolyline *polyline, NSError *error))completitionBlock;
- (void)getPolylineWithLocations:(NSArray *)locations withsecond:(long)tenant_id andCompletitionBlock:(void (^)(GMSPolyline *polyline, NSError *error))completitionBlock;
- (NSString *)getStepArrayString;
@end