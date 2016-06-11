//
//  Map.m
//  SimpleMap
//
//  Created by masashi on 11/8/13.
//
//

#import "Map.h"

@implementation Map


-(void)setGoogleMapsViewController:(GoogleMapsViewController *)viewCtrl
{
  self.mapCtrl = viewCtrl;
}

/**
 * Move the center of the map
 */
- (void)setCenter:(CDVInvokedUrlCommand *)command {
  
  float latitude = [[command.arguments objectAtIndex:1] floatValue];
  float longitude = [[command.arguments objectAtIndex:2] floatValue];
    
    self.mapCtrl.map setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), self.mapCtrl.map.region.span) animated:YES];
  
  //[self.mapCtrl.map animateToLocation:CLLocationCoordinate2DMake(latitude, longitude)];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setMyLocationEnabled:(CDVInvokedUrlCommand *)command {
  Boolean isEnabled = [[command.arguments objectAtIndex:1] boolValue];
  self.mapCtrl.map.settings.myLocationButton = isEnabled;
  self.mapCtrl.map.myLocationEnabled = isEnabled;
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setIndoorEnabled:(CDVInvokedUrlCommand *)command {
  Boolean isEnabled = [[command.arguments objectAtIndex:1] boolValue];
  self.mapCtrl.map.settings.indoorPicker = isEnabled;
  self.mapCtrl.map.indoorEnabled = isEnabled;
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setTrafficEnabled:(CDVInvokedUrlCommand *)command {
  Boolean isEnabled = [[command.arguments objectAtIndex:1] boolValue];
  self.mapCtrl.map.trafficEnabled = isEnabled;
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCompassEnabled:(CDVInvokedUrlCommand *)command {
  Boolean isEnabled = [[command.arguments objectAtIndex:1] boolValue];
  self.mapCtrl.map.settings.compassButton = isEnabled;
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setTilt:(CDVInvokedUrlCommand *)command {
  
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAllGesturesEnabled:(CDVInvokedUrlCommand *)command {
  Boolean isEnabled = [[command.arguments objectAtIndex:1] boolValue];
  [self.mapCtrl.map.settings setAllGesturesEnabled:isEnabled];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 * Change the zoom level
 */
- (void)setZoom:(CDVInvokedUrlCommand *)command {
  float zoom = [[command.arguments objectAtIndex:1] floatValue];
  
    CLLocationCoordinate2D center = self.mapCtrl.map.centerCoordinate;
    [self.mapCtrl setZoom:zoom];
    
    //CLLocationCoordinate2D center = [self.mapCtrl.map.projection coordinateForPoint:self.mapCtrl.map.center];
  
    //[self.mapCtrl.map setCamera:[GMSCameraPosition cameraWithTarget:center zoom:zoom]];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Pan by
 */
- (void)panBy:(CDVInvokedUrlCommand *)command {
  int x = [[command.arguments objectAtIndex:1] intValue];
  int y = [[command.arguments objectAtIndex:2] intValue];
  
  [self.mapCtrl.map animateWithCameraUpdate:[GMSCameraUpdate scrollByX:x * -1 Y:y * -1]];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Change the Map Type
 */
- (void)setMapTypeId:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    
    NSString *mapTypeString = [command.arguments objectAtIndex:1];
    
    if (mapTypeString)
    {
        if ([mapTypeString isEqualToString:@"NORMAL"] || [mapTypeString isEqualToString:@"MAP_TYPE_NORMAL"])
        {
            self.mapCtrl.map.mapType = MKMapTypeStandard;
        }
        else if ([mapTypeString isEqualToString:@"ROADMAP"] || [mapTypeString isEqualToString:@"MAP_TYPE_NORMAL"])
        {
            self.mapCtrl.map.mapType = MKMapTypeStandard;
        }
        else if ([mapTypeString isEqualToString:@"SATELLITE"] || [mapTypeString isEqualToString:@"MAP_TYPE_SATELLITE"])
        {
            self.mapCtrl.map.mapType = MKMapTypeSatellite;
        }
        else if ([mapTypeString isEqualToString:@"HYBRID"] || [mapTypeString isEqualToString:@"MAP_TYPE_HYBRID"])
        {
            self.mapCtrl.map.mapType = MKMapTypeHybrid;
        }
        else if ([mapTypeString isEqualToString:@"TERRAIN"] || [mapTypeString isEqualToString:@"MAP_TYPE_TERRAIN"])
        {
            self.mapCtrl.map.mapType = MKMapTypeSatellite;
        }
        else if ([mapTypeString isEqualToString:@"NONE"] || [mapTypeString isEqualToString:@"MAP_TYPE_NONE"])
        {
            self.mapCtrl.map.mapType = MKMapTypeStandard;
        }
        else
        {
            self.mapCtrl.map.mapType = MKMapTypeStandard;
        }
    }
    else
    {
        self.mapCtrl.map.mapType = MKMapTypeStandard;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Move the map camera with animation
 */
-(void)animateCamera:(CDVInvokedUrlCommand *)command
{
  [self updateCameraPosition:@"animateCamera" command:command];
}

/**
 * Move the map camera
 */
-(void)moveCamera:(CDVInvokedUrlCommand *)command
{
  [self updateCameraPosition:@"moveCamera" command:command];
}

-(void)getCameraPosition:(CDVInvokedUrlCommand *)command
{
    float latitude;
    float longitude;
    float zoom;
    
    latitude = self.mapCtrl.map.centerCoordinate.latitude;
    longitude = self.mapCtrl.map.centerCoordinate.longitude;
    zoom = self.mapCtrl.zoom;

    //GMSCameraPosition *camera = self.mapCtrl.map.camera;
  
    NSMutableDictionary *latLng = [NSMutableDictionary dictionary];
  
    [latLng setObject:@(latitude) forKey:@"lat"];
    [latLng setObject:@(longitude) forKey:@"lng"];
  
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:@(zoom) forKey:@"zoom"];
    [json setObject:@(0.0) forKey:@"tilt"];
    [json setObject:latLng forKey:@"target"];
    [json setObject:@(0.0) forKey:@"bearing"];
    [json setObject:[NSNumber numberWithInt:(int)self.mapCtrl.map.hash] forKey:@"hashCode"];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)updateCameraPosition: (NSString*)action command:(CDVInvokedUrlCommand *)command
{
    NSDictionary *json = [command.arguments objectAtIndex:1];
  
    /*
    int bearing = (int)[[json valueForKey:@"bearing"] integerValue];
    double angle = [[json valueForKey:@"tilt"] doubleValue];
    */
    
    double zoom = [[json valueForKey:@"zoom"] doubleValue];
  
  
    NSDictionary *latLng = nil;
    float latitude;
    float longitude;
  
    /*
    GMSCameraPosition *cameraPosition;
    GMSCoordinateBounds *cameraBounds = nil;
    */
    
    BOOL animated = NO;
    
    if ([action  isEqual: @"animateCamera"])
        animated = YES;
    
    if ([json objectForKey:@"target"])
    {
        NSString *targetClsName = NSStringFromClass([[json objectForKey:@"target"] class]);

        if ([targetClsName isEqualToString:@"__NSCFArray"] || [targetClsName isEqualToString:@"__NSArrayM"] )
        {
            // int i = 0;
            
            NSArray *latLngList = [json objectForKey:@"target"];
            
            latLng = latLngList.lastObject;
            latitude = [[latLng valueForKey:@"lat"] floatValue];
            longitude = [[latLng valueForKey:@"lng"] floatValue];
            
            /*
            GMSMutablePath *path = [GMSMutablePath path];
            
            for (i = 0; i < [latLngList count]; i++) {
                latLng = [latLngList objectAtIndex:i];
                latitude = [[latLng valueForKey:@"lat"] floatValue];
                longitude = [[latLng valueForKey:@"lng"] floatValue];
                [path addLatitude:latitude longitude:longitude];
            }
            
            float scale = 1;
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                scale = [[UIScreen mainScreen] scale];
            }
            [[UIScreen mainScreen] scale];
            
            cameraBounds = [[GMSCoordinateBounds alloc] initWithPath:path];
            //CLLocationCoordinate2D center = cameraBounds.center;
            
            cameraPosition = [self.mapCtrl.map cameraForBounds:cameraBounds insets:UIEdgeInsetsMake(10 * scale, 10* scale, 10* scale, 10* scale)];
            */
        
        }
        else
        {
            latLng = [json objectForKey:@"target"];
            latitude = [[latLng valueForKey:@"lat"] floatValue];
            longitude = [[latLng valueForKey:@"lng"] floatValue];
            
            /*
            cameraPosition = [GMSCameraPosition cameraWithLatitude:latitude
                                                         longitude:longitude
                                                              zoom:zoom
                                                           bearing:bearing
                                                      viewingAngle:angle];
             */
        }
    }
    else
    {
        latitude = self.mapCtrl.map.centerCoordinate.latitude;
        longitude = self.mapCtrl.map.centerCoordinate.longitude;

        /*
        cameraPosition = [GMSCameraPosition cameraWithLatitude:self.mapCtrl.map.camera.target.latitude
                                                     longitude:self.mapCtrl.map.camera.target.longitude
                                                          zoom:zoom
                                                       bearing:bearing
                                                  viewingAngle:angle];
         */
    }
    
    [self.mapCtrl setCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) zoom:zoom animated:animated];
    
  /*
  if ([json objectForKey:@"target"]) {
    NSString *targetClsName = [[json objectForKey:@"target"] className];
    if ([targetClsName isEqualToString:@"__NSCFArray"] || [targetClsName isEqualToString:@"__NSArrayM"] ) {
      int i = 0;
      NSArray *latLngList = [json objectForKey:@"target"];
      GMSMutablePath *path = [GMSMutablePath path];
      for (i = 0; i < [latLngList count]; i++) {
        latLng = [latLngList objectAtIndex:i];
        latitude = [[latLng valueForKey:@"lat"] floatValue];
        longitude = [[latLng valueForKey:@"lng"] floatValue];
        [path addLatitude:latitude longitude:longitude];
      }
      float scale = 1;
      if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
      }
      [[UIScreen mainScreen] scale];
      
      cameraBounds = [[GMSCoordinateBounds alloc] initWithPath:path];
      //CLLocationCoordinate2D center = cameraBounds.center;
      
      cameraPosition = [self.mapCtrl.map cameraForBounds:cameraBounds insets:UIEdgeInsetsMake(10 * scale, 10* scale, 10* scale, 10* scale)];
    
    } else {
      latLng = [json objectForKey:@"target"];
      latitude = [[latLng valueForKey:@"lat"] floatValue];
      longitude = [[latLng valueForKey:@"lng"] floatValue];
      
      cameraPosition = [GMSCameraPosition cameraWithLatitude:latitude
                                          longitude:longitude
                                          zoom:zoom
                                          bearing:bearing
                                          viewingAngle:angle];
    }
  } else {
    cameraPosition = [GMSCameraPosition cameraWithLatitude:self.mapCtrl.map.camera.target.latitude
                                        longitude:self.mapCtrl.map.camera.target.longitude
                                        zoom:zoom
                                        bearing:bearing
                                        viewingAngle:angle];
  }
  */
    
    /*
  float duration = 5.0f;
  if ([json objectForKey:@"duration"]) {
    duration = [[json objectForKey:@"duration"] floatValue] / 1000;
  }
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  
  if ([action  isEqual: @"animateCamera"]) {
    [CATransaction begin]; {
      [CATransaction setAnimationDuration: duration];
      
      //[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
      [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
      
      [CATransaction setCompletionBlock:^{
        if (cameraBounds != nil){
        
          GMSCameraPosition *cameraPosition2 = [GMSCameraPosition cameraWithLatitude:cameraBounds.center.latitude
                                              longitude:cameraBounds.center.longitude
                                              zoom:self.mapCtrl.map.camera.zoom
                                              bearing:[[json objectForKey:@"bearing"] doubleValue]
                                              viewingAngle:[[json objectForKey:@"tilt"] doubleValue]];
        
          [self.mapCtrl.map setCamera:cameraPosition2];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
      }];
      
      [self.mapCtrl.map animateToCameraPosition: cameraPosition];
    }[CATransaction commit];
  }
  
  if ([action  isEqual: @"moveCamera"]) {
    [self.mapCtrl.map setCamera:cameraPosition];

    if (cameraBounds != nil){
    
      GMSCameraPosition *cameraPosition2 = [GMSCameraPosition cameraWithLatitude:cameraBounds.center.latitude
                                          longitude:cameraBounds.center.longitude
                                          zoom:self.mapCtrl.map.camera.zoom
                                          bearing:[[json objectForKey:@"bearing"] doubleValue]
                                          viewingAngle:[[json objectForKey:@"tilt"] doubleValue]];
    
      [self.mapCtrl.map setCamera:cameraPosition2];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
    */
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)toDataURL:(CDVInvokedUrlCommand *)command {

  NSDictionary *opts = [command.arguments objectAtIndex:1];
  BOOL uncompress = NO;
  if ([opts objectForKey:@"uncompress"]) {
      uncompress = [[opts objectForKey:@"uncompress"] boolValue];
  }
  
  if (uncompress) {
    UIGraphicsBeginImageContextWithOptions(self.mapCtrl.view.frame.size, NO, 0.0f);
  } else {
    UIGraphicsBeginImageContext(self.mapCtrl.view.frame.size);
  }
  [self.mapCtrl.view drawViewHierarchyInRect:self.mapCtrl.map.layer.bounds afterScreenUpdates:NO];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  NSData *imageData = UIImagePNGRepresentation(image);
  NSString *base64Encoded = nil;
  base64Encoded = [NSString stringWithFormat:@"data:image/png;base64,%@", [imageData base64EncodedStringWithSeparateLines:NO]];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:base64Encoded];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Maps an Earth coordinate to a point coordinate in the map's view.
 */
- (void)fromLatLngToPoint:(CDVInvokedUrlCommand*)command {
  
  float latitude = [[command.arguments objectAtIndex:1] floatValue];
  float longitude = [[command.arguments objectAtIndex:2] floatValue];
  
  CGPoint point = [self.mapCtrl.map.projection
                      pointForCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
  
  NSMutableArray *pointJSON = [[NSMutableArray alloc] init];
  [pointJSON addObject:[NSNumber numberWithDouble:point.x]];
  [pointJSON addObject:[NSNumber numberWithDouble:point.y]];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:pointJSON];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Maps a point coordinate in the map's view to an Earth coordinate.
 */
- (void)fromPointToLatLng:(CDVInvokedUrlCommand*)command {
  
  float pointX = [[command.arguments objectAtIndex:1] floatValue];
  float pointY = [[command.arguments objectAtIndex:2] floatValue];
  
  CLLocationCoordinate2D latLng = [self.mapCtrl.map.projection
                      coordinateForPoint:CGPointMake(pointX, pointY)];
  
  NSMutableArray *latLngJSON = [[NSMutableArray alloc] init];
  [latLngJSON addObject:[NSNumber numberWithDouble:latLng.latitude]];
  [latLngJSON addObject:[NSNumber numberWithDouble:latLng.longitude]];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:latLngJSON];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Return the visible region of the map
 * Thanks @fschmidt
 */
- (void)getVisibleRegion:(CDVInvokedUrlCommand*)command {
  GMSVisibleRegion visibleRegion = self.mapCtrl.map.projection.visibleRegion;
  GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];

  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  NSMutableDictionary *northeast = [NSMutableDictionary dictionary];
  [northeast setObject:[NSNumber numberWithFloat:bounds.northEast.latitude] forKey:@"lat"];
  [northeast setObject:[NSNumber numberWithFloat:bounds.northEast.longitude] forKey:@"lng"];
  [json setObject:northeast forKey:@"northeast"];
  NSMutableDictionary *southwest = [NSMutableDictionary dictionary];
  [southwest setObject:[NSNumber numberWithFloat:bounds.southWest.latitude] forKey:@"lat"];
  [southwest setObject:[NSNumber numberWithFloat:bounds.southWest.longitude] forKey:@"lng"];
  [json setObject:southwest forKey:@"southwest"];
  
  NSMutableArray *latLngArray = [NSMutableArray array];
  [latLngArray addObject:northeast];
  [latLngArray addObject:southwest];
  [json setObject:latLngArray forKey:@"latLngArray"];

  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setOptions:(CDVInvokedUrlCommand *)command
{
    NSDictionary *initOptions = [command.arguments objectAtIndex:1];
    
    / Set Map Options
    
    NSString *mapTypeString = [initOptions valueForKey:@"mapType"];
    
    if (mapTypeString)
    {
        if ([mapTypeString isEqualToString:@"NORMAL"] || [mapTypeString isEqualToString:@"MAP_TYPE_NORMAL"])
        {
            self.map.mapType = MKMapTypeStandard;
        }
        else if ([mapTypeString isEqualToString:@"ROADMAP"] || [mapTypeString isEqualToString:@"MAP_TYPE_NORMAL"])
        {
            self.map.mapType = MKMapTypeStandard;
        }
        else if ([mapTypeString isEqualToString:@"SATELLITE"] || [mapTypeString isEqualToString:@"MAP_TYPE_SATELLITE"])
        {
            self.map.mapType = MKMapTypeSatellite;
        }
        else if ([mapTypeString isEqualToString:@"HYBRID"] || [mapTypeString isEqualToString:@"MAP_TYPE_HYBRID"])
        {
            self.map.mapType = MKMapTypeHybrid;
        }
        else if ([mapTypeString isEqualToString:@"TERRAIN"] || [mapTypeString isEqualToString:@"MAP_TYPE_TERRAIN"])
        {
            self.map.mapType = MKMapTypeSatellite;
        }
        else if ([mapTypeString isEqualToString:@"NONE"] || [mapTypeString isEqualToString:@"MAP_TYPE_NONE"])
        {
            self.map.mapType = MKMapTypeStandard;
        }
        else
        {
            self.map.mapType = MKMapTypeStandard;
        }
    }
    else
    {
        self.map.mapType = MKMapTypeStandard;
    }
    
    // Set Gesture Options
    
    NSDictionary *gestures = [initOptions objectForKey:@"gestures"];
    
    if (gestures)
    {
        // Rotate
        
        if ([gestures valueForKey:@"rotate"] != nil) {
            isEnabled = [[gestures valueForKey:@"rotate"] boolValue];
            self.map.rotateEnabled = isEnabled;
        }
        
        // Scroll
        
        if ([gestures valueForKey:@"scroll"] != nil) {
            isEnabled = [[gestures valueForKey:@"scroll"] boolValue];
            self.map.scrollEnabled = isEnabled;
        }
        
        // Tilt (Pitch on Apple Maps)
        
        if ([gestures valueForKey:@"tilt"] != nil) {
            isEnabled = [[gestures valueForKey:@"tilt"] boolValue];
            self.map.pitchEnabled = isEnabled;
        }
        
        // Zoom
        
        if ([gestures valueForKey:@"zoom"] != nil) {
            isEnabled = [[gestures valueForKey:@"zoom"] boolValue];
            self.map.zoomEnabled= isEnabled;
        }
    }
    
    // Get Camera (Region) Options
    
    NSDictionary *cameraOpts = [initOptions objectForKey:@"camera"];
    
    if ([cameraOpts objectForKey:@"target"])
    {
        NSString *targetClsName = NSStringFromClass([[cameraOpts objectForKey:@"target"] class]);

        if ([targetClsName isEqualToString:@"__NSCFArray"] || [targetClsName isEqualToString:@"__NSArrayM"] )
        {
            NSArray *latLngList = [cameraOpts objectForKey:@"target"];
            
            
            float minLatitude = 0.0;
            float maxLatitude = 0.0;
            float minLongitude = 0.0;
            float maxLongitude = 0.0;
            float maxIndex = 0;
            float minIndex = 0;
            float latitudeDelta = 0.0;
            float midLatitude = 0.0;
            float longitudeDelta = 0.0;
            float midLongitude = 0.0;
            
            float radiansConversion = (M_PI / 180.0);
            
            NSMutableArray *rotatedLongitudes = [[NSMutableArray alloc] init];
            
            for (NSInteger i = 0; i < [latLngList count]; i++)
            {
                NSDictionary *latLng = [latLngList objectAtIndex:i];
                float latitude = [[latLng valueForKey:@"lat"] floatValue];
                float longitude = [[latLng valueForKey:@"lng"] floatValue];
                
                if (latitude < minLatitude)
                    minLatitude = latitude;
                if (latitude > maxLatitude)
                    maxLatitude = latitude;
                
                latitudeDelta = maxLatitude - minLatitude;
                midLatitude = minLatitude + 0.5 * latitudeDelta;
                
                longitude += 180.0; // Rotate by 180 degrees
                
                [rotatedLongitudes addObject:longitude];
                
                if (longitude < minLongitude)
                {
                    minLongitude = longitude ;
                    minIndex = i;
                }
                if (longitude > maxLongitude)
                {
                    maxLongitude = longitude;
                    maxIndex = i;
                }
            }
            
            // Check for 180th Meridian Crossing
            
            if ((cos(radiansConversion * maxLongitude) > 0 || cos(radiansConversion * minLongitude) > 0) && (signbit(sin(radiansConversion * maxLongitude)) != signbit(sin(radiansConversion * minLongitude))))
            {
                float maxRotatedLongitude = 0.0;
                float minRotatedLongitude = 0.0;
                NSInteger maxRotatedIndex = 0;
                NSInteger minRotatedIndex = 0;
                
                for (NSInteger j = 0; j < [latLngList count]; j++)
                {
                    NSDictionary *latLng = [latLngList objectAtIndex:j];
                    float longitude = [[latLng valueForKey:@"lng"] floatValue];
                    
                    longitude += 180.0; // Rotate by 180 degrees
                    longitude *= (radiansConversion);
                    longitude = sin(longitude);
                    
                    if (longitude < minRotatedLongitude)
                    {
                        minRotatedLongitude = longitude;
                        minIndex = j;
                    }
                    if (longitude > maxRotatedLongitude)
                    {
                        maxRotatedLongitude = longitude;
                        maxIndex = j;
                    }
                }
                
                if (maxRotatedIndex != minIndex || minRotatedIndex != maxIndex)
                {
                    // Swap Indicies
                    
                    maxIndex = maxRotatedIndex;
                    minIndex = minRotatedIndex;
                }
                
                maxLongitude = [[rotatedLongitudes objectAtIndex:maxIndex] floatValue];
                minLongitude = [[rotatedLongitudes objectAtIndex:minIndex] floatValue];
                
                longitudeDelta = (360.0 - maxLongitude) + (minLongitude);
                midLongitude = (minLongitude - 180.0) - 0.5 * longitudeDelta;
                
                if (longitudeDelta < 0.0)
                    longitudeDelta *= -1.0;
                
                if (midLongitude < -180.0)
                    midLongitude = (maxLongitude - 180.0) + 0.5 *longitudeDelta;
            }
            else
            {
                maxLongitude = [[rotatedLongitudes objectAtIndex:maxIndex] floatValue];
                minLongitude = [[rotatedLongitudes objectAtIndex:minIndex] floatValue];
                
                longitudeDelta = maxLongitude - minLongitude;
                midLongitude = (minLongitude - 180.0) + 0.5 * longitudeDelta;
            }
            
            MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(midLatitude, midLongitude), MKCoordinateSpanMake(latitudeDelta, longitudeDelta));
            
            [self.map setRegion:region];
        }
        else
        {
            NSMutableDictionary *latLng = [cameraOpts objectForKey:@"target"];
            
            float latitude = [[latLng valueForKey:@"lat"] floatValue];
            float longitude = [[latLng valueForKey:@"lng"] floatValue];
            
            [self.map setCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            
            float zoom = [[cameraOpts valueForKey:@"zoom"] floatValue];
            
            [self setZoom:zoom];
        }
    }
    else
    {
        [self.map setCenterCoordinate:CLLocationCoordinate2DMake(0.0, 0.0)];
        
        float zoom = [[cameraOpts valueForKey:@"zoom"] floatValue];
        
        [self setZoom:zoom];
    }
    
    // Set Controls
    
    BOOL isEnabled = NO;
    
    NSDictionary *controls = [initOptions objectForKey:@"controls"];
    
    if (controls)
    {
        // Compass
        
        if ([controls valueForKey:@"compass"] != nil)
        {
            isEnabled = [[controls valueForKey:@"compass"] boolValue];
            self.map.showsCompass = = isEnabled;
        }
        
        // My Location Button (User Location)
        
        if ([controls valueForKey:@"myLocationButton"] != nil)
        {
            isEnabled = [[controls valueForKey:@"myLocationButton"] boolValue];
            self.map.showsUserLocation = isEnabled;
        }
        
    }
    else
    {
        self.map.showsCompass = NO;
    }
    
/*
  if ([initOptions valueForKey:@"camera"]) {
    // camera position
    NSDictionary *cameraOpts = [initOptions objectForKey:@"camera"];
    NSMutableDictionary *latLng = [NSMutableDictionary dictionary];
    [latLng setObject:[NSNumber numberWithFloat:0.0f] forKey:@"lat"];
    [latLng setObject:[NSNumber numberWithFloat:0.0f] forKey:@"lng"];
    
    if (cameraOpts) {
      NSDictionary *latLngJSON = [cameraOpts objectForKey:@"latLng"];
      [latLng setObject:[NSNumber numberWithFloat:[[latLngJSON valueForKey:@"lat"] floatValue]] forKey:@"lat"];
      [latLng setObject:[NSNumber numberWithFloat:[[latLngJSON valueForKey:@"lng"] floatValue]] forKey:@"lng"];
    }
    GMSCameraPosition *camera = [GMSCameraPosition
                                  cameraWithLatitude: [[latLng valueForKey:@"lat"] floatValue]
                                  longitude: [[latLng valueForKey:@"lng"] floatValue]
                                  zoom: [[cameraOpts valueForKey:@"zoom"] floatValue]
                                  bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                                  viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
    
    self.mapCtrl.map.camera = camera;
  }
*/

    /*
  if ([initOptions valueForKey:@"camera"]) {
    NSDictionary *cameraOpts = [initOptions objectForKey:@"camera"];
    NSMutableDictionary *latLng = [NSMutableDictionary dictionary];
    [latLng setObject:[NSNumber numberWithFloat:0.0f] forKey:@"lat"];
    [latLng setObject:[NSNumber numberWithFloat:0.0f] forKey:@"lng"];
    float latitude;
    float longitude;
    GMSCameraPosition *camera;
    GMSCoordinateBounds *cameraBounds = nil;

    if ([cameraOpts objectForKey:@"target"])
    {
      NSString *targetClsName = [[cameraOpts objectForKey:@"target"] className];
      if ([targetClsName isEqualToString:@"__NSCFArray"] || [targetClsName isEqualToString:@"__NSArrayM"] )
      {
        int i = 0;
        NSArray *latLngList = [cameraOpts objectForKey:@"target"];
        GMSMutablePath *path = [GMSMutablePath path];
        for (i = 0; i < [latLngList count]; i++) {
          latLng = [latLngList objectAtIndex:i];
          latitude = [[latLng valueForKey:@"lat"] floatValue];
          longitude = [[latLng valueForKey:@"lng"] floatValue];
          [path addLatitude:latitude longitude:longitude];
        }
        float scale = 1;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
          scale = [[UIScreen mainScreen] scale];
        }
        [[UIScreen mainScreen] scale];
        
        cameraBounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        
        CLLocationCoordinate2D center = cameraBounds.center;
        
        camera = [GMSCameraPosition cameraWithLatitude:center.latitude
                                            longitude:center.longitude
                                            zoom:self.mapCtrl.map.camera.zoom
                                            bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                                            viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
        
      }
      else
      {
        latLng = [cameraOpts objectForKey:@"target"];
        latitude = [[latLng valueForKey:@"lat"] floatValue];
        longitude = [[latLng valueForKey:@"lng"] floatValue];
        
        camera = [GMSCameraPosition cameraWithLatitude:latitude
                                            longitude:longitude
                                            zoom:[[cameraOpts valueForKey:@"zoom"] floatValue]
                                            bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                                            viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
      }
    }
    else
    {
      camera = [GMSCameraPosition
                              cameraWithLatitude: [[latLng valueForKey:@"lat"] floatValue]
                              longitude: [[latLng valueForKey:@"lng"] floatValue]
                              zoom: [[cameraOpts valueForKey:@"zoom"] floatValue]
                              bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                              viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
    }
    self.mapCtrl.map.camera = camera;

    if (cameraBounds != nil){
      float scale = 1;
      if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
      }
      [[UIScreen mainScreen] scale];
      
      [self.mapCtrl.map moveCamera:[GMSCameraUpdate fitBounds:cameraBounds withPadding:10 * scale]];
      GMSCameraPosition *cameraPosition2 = [GMSCameraPosition cameraWithLatitude:cameraBounds.center.latitude
                                          longitude:cameraBounds.center.longitude
                                          zoom:self.mapCtrl.map.camera.zoom
                                          bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                                          viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
    
      [self.mapCtrl.map setCamera:cameraPosition2];
    }

  }
  
  BOOL isEnabled = NO;
  //controls
  NSDictionary *controls = [initOptions objectForKey:@"controls"];
  if (controls) {
    //compass
    if ([controls valueForKey:@"compass"] != nil) {
      isEnabled = [[controls valueForKey:@"compass"] boolValue];
      if (isEnabled == true) {
        self.mapCtrl.map.settings.compassButton = YES;
      } else {
        self.mapCtrl.map.settings.compassButton = NO;
      }
    }
    //myLocationButton
    if ([controls valueForKey:@"myLocationButton"] != nil) {
      isEnabled = [[controls valueForKey:@"myLocationButton"] boolValue];
      if (isEnabled == true) {
        self.mapCtrl.map.settings.myLocationButton = YES;
        self.mapCtrl.map.myLocationEnabled = YES;
      } else {
        self.mapCtrl.map.settings.myLocationButton = NO;
        self.mapCtrl.map.myLocationEnabled = NO;
      }
    }
    //indoorPicker
    if ([controls valueForKey:@"indoorPicker"] != nil) {
      isEnabled = [[controls valueForKey:@"indoorPicker"] boolValue];
      if (isEnabled == true) {
        self.mapCtrl.map.settings.indoorPicker = YES;
      } else {
        self.mapCtrl.map.settings.indoorPicker = NO;
      }
    }
  } else {
    self.mapCtrl.map.settings.compassButton = YES;
  }

  //gestures
  NSDictionary *gestures = [initOptions objectForKey:@"gestures"];
  if (gestures) {
    //rotate
    if ([gestures valueForKey:@"rotate"] != nil) {
      isEnabled = [[gestures valueForKey:@"rotate"] boolValue];
      self.mapCtrl.map.settings.rotateGestures = isEnabled;
    }
    //scroll
    if ([gestures valueForKey:@"scroll"] != nil) {
      isEnabled = [[gestures valueForKey:@"scroll"] boolValue];
      self.mapCtrl.map.settings.scrollGestures = isEnabled;
    }
    //tilt
    if ([gestures valueForKey:@"tilt"] != nil) {
      isEnabled = [[gestures valueForKey:@"tilt"] boolValue];
      self.mapCtrl.map.settings.tiltGestures = isEnabled;
    }
    //zoom
    if ([gestures valueForKey:@"zoom"] != nil) {
      isEnabled = [[gestures valueForKey:@"zoom"] boolValue];
      self.mapCtrl.map.settings.zoomGestures = isEnabled;
    }
  }

  //mapType
  NSString *typeStr = [initOptions valueForKey:@"mapType"];
  if (typeStr) {
    
    NSDictionary *mapTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                              ^() {return kGMSTypeHybrid; }, @"MAP_TYPE_HYBRID",
                              ^() {return kGMSTypeSatellite; }, @"MAP_TYPE_SATELLITE",
                              ^() {return kGMSTypeTerrain; }, @"MAP_TYPE_TERRAIN",
                              ^() {return kGMSTypeNormal; }, @"MAP_TYPE_NORMAL",
                              ^() {return kGMSTypeNone; }, @"MAP_TYPE_NONE",
                              nil];
    
    typedef GMSMapViewType (^CaseBlock)();
    GMSMapViewType mapType;
    CaseBlock caseBlock = mapTypes[typeStr];
    if (caseBlock) {
      // Change the map type
      mapType = caseBlock();
      self.mapCtrl.map.mapType = mapType;
    }
  }
     */
}


- (void)setPadding:(CDVInvokedUrlCommand *)command {
  NSDictionary *paddingJson = [command.arguments objectAtIndex:1];
  float top = [[paddingJson objectForKey:@"top"] floatValue];
  float left = [[paddingJson objectForKey:@"left"] floatValue];
  float right = [[paddingJson objectForKey:@"right"] floatValue];
  float bottom = [[paddingJson objectForKey:@"bottom"] floatValue];
  
  UIEdgeInsets padding = UIEdgeInsetsMake(top, left, bottom, right);
  
  [self.mapCtrl.map setPadding:padding];
}

- (void)getFocusedBuilding:(CDVInvokedUrlCommand*)command {
  GMSIndoorBuilding *building = self.mapCtrl.map.indoorDisplay.activeBuilding;
  if (building != nil) {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
  GMSIndoorLevel *activeLevel = self.mapCtrl.map.indoorDisplay.activeLevel;
  
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  
  NSUInteger activeLevelIndex = [building.levels indexOfObject:activeLevel];
  [result setObject:[NSNumber numberWithInteger:activeLevelIndex] forKey:@"activeLevelIndex"];
  [result setObject:[NSNumber numberWithInteger:building.defaultLevelIndex] forKey:@"defaultLevelIndex"];
  
  GMSIndoorLevel *level;
  NSMutableDictionary *levelInfo;
  NSMutableArray *levels = [NSMutableArray array];
  for (level in building.levels) {
    levelInfo = [NSMutableDictionary dictionary];
    
    [levelInfo setObject:[NSString stringWithString:level.name] forKey:@"name"];
    [levelInfo setObject:[NSString stringWithString:level.shortName] forKey:@"shortName"];
    [levels addObject:levelInfo];
  }
  [result setObject:levels forKey:@"levels"];
  
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
