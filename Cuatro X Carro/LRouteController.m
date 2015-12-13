#define kDirectionsURL @"http://maps.googleapis.com/maps/api/directions/json?"


#import "LRouteController.h"


@implementation LRouteController{
    NSString *scheduleString;
    NSMutableArray *stepsArray;
}


- (void)getPolylineWithLocations:(NSArray *)locations withsecond:(long)tenant_id andCompletitionBlock:(void (^)(GMSPolyline *polyline, NSError *error))completitionBlock
{
    scheduleString = @"";
    [self getPolylineWithLocations:locations withsecond:tenant_id travelMode:TravelModeDriving andCompletitionBlock:completitionBlock];
}


- (void)getPolylineWithLocations:(NSArray *)locations withsecond:(long)tenant_id travelMode:(TravelMode)travelMode andCompletitionBlock:(void (^)(GMSPolyline *polyline, NSError *error))completitionBlock
{
    NSUInteger locationsCount = [locations count];
    
    if (locationsCount < 2) return;
    
    NSMutableArray *locationStrings = [NSMutableArray new];
    
    for (CLLocation *location in locations)
    {
        [locationStrings addObject:[[NSString alloc] initWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude]];
    }
    
    NSString *sensor = @"false";
    NSString *origin = [locationStrings objectAtIndex:0];
    NSString *destination = [locationStrings lastObject];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@origin=%@&destination=%@&sensor=%@", kDirectionsURL, origin, destination, sensor];
    
    if (locationsCount > 2)
    {
        [url appendString:@"&waypoints=optimize:false"];
        for (int i = 1; i < [locationStrings count] - 1; i++)
        {
            [url appendFormat:@"|%@", [locationStrings objectAtIndex:i]];
        }
    }
    
    switch (travelMode)
    {
        case TravelModeWalking:
            [url appendString:@"&mode=walking"];
            break;
        case TravelModeBicycling:
            [url appendString:@"&mode=bicycling"];
            break;
        case TravelModeTransit:
            [url appendString:@"&mode=transit"];
            break;
        default:
            [url appendString:@"&mode=driving"];
            break;
    }
    
    url = [NSMutableString stringWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    NSURL *urlConnection =[NSURL URLWithString:url];
    
    _request = [NSURLRequest requestWithURL:urlConnection];
    
    [NSURLConnection sendAsynchronousRequest:_request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (!error)
        {
            NSArray *routesArray = [json objectForKey:@"routes"];
            stepsArray = [[NSMutableArray alloc] init];
            
            if ([routesArray count] > 0)
            {
                NSDictionary *routeDict = [routesArray objectAtIndex:0];
                NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                GMSMutablePath *pathArray = [[GMSMutablePath alloc] init];
                GMSPath *path = [GMSPath pathFromEncodedPath:points];
                for (int p=0; p<path.count; p++) {
                    [pathArray addCoordinate:[path coordinateAtIndex:p]];
                    CLLocationCoordinate2D strCoord = [path coordinateAtIndex:p];
                    //NSString *a = [NSString stringWithFormat:@"lat:%f,long:%f", strCoord.latitude, strCoord.longitude];
                    NSMutableDictionary * step = [[NSMutableDictionary alloc] init];
                    [step setValue:[NSNumber numberWithInteger: p] forKey:@"step"];
                    [step setValue:[NSNumber numberWithDouble: strCoord.latitude] forKey:@"latitude"];
                    [step setValue:[NSNumber numberWithDouble: strCoord.longitude] forKey:@"longitude"];
                    [step setValue:[NSNumber numberWithInteger: tenant_id] forKey:@"tenant_id"];
                    [stepsArray addObject:step];
                }
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathArray];
                polyline.strokeWidth = 3.f;
                
                NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:stepsArray options:0 error:nil];
                scheduleString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                
                completitionBlock(polyline, nil);
            }
            else
            {
                #if DEBUG
                if (locationsCount > 10)
                    NSLog(@"If you're using Google API's free service you will not get the route. Free service supports up to 8 waypoints + origin + destination.");
                #endif
                completitionBlock(nil, nil);
            }
        }
        else
        {
            completitionBlock(nil, error);
        }
    }];
    
}

- (NSString *) getStepArrayString{
    return scheduleString;
};

- (NSMutableArray *) getStepArray{
    return stepsArray;
};
@end