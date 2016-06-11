//
//  GoogleMapsViewController.m
//  SimpleMap
//
//  Created by masashi on 11/6/13.
//
//

#import "GoogleMapsViewController.h"
#if CORDOVA_VERSION_MIN_REQUIRED < __CORDOVA_4_0_0
#import <Cordova/CDVJSON.h>
#endif

#import "MarkerAnnotation.h"
#import "PolylineOverlay.h"

@interface GoogleMapsViewController ()

-(void)imageForAnnotation:(MarkerAnnotation *)annotation imageBlock:(void( ^ )(UIImage* image))imageBlock;

@end

@implementation GoogleMapsViewController
NSDictionary *initOptions;

#pragma mark - Object by Key Handlers

- (MKPointAnnotation *)getAnnotationByKey:(NSString *)key
{
    return [self.overlayManager objectForKey:key];
}

- (MKShape *)getOverlayByKey:(NSString *)key
{
    return [self.overlayManager objectForKey:key];
}

#pragma mark - Event Handlers

/**
 * Involve App._onCameraEvent
 */

 - (void)triggerCameraEvent: (NSString *)eventName position:(CLLocationCoordinate2D )position
 {
     NSMutableDictionary *target = [NSMutableDictionary dictionary];
     [target setObject:@(position.latitude) forKey:@"lat"];
     [target setObject:@(position.longitude) forKey:@"lng"];
 
     NSMutableDictionary *json = [NSMutableDictionary dictionary];
     [json setObject:@(0.0) forKey:@"bearing"];
     [json setObject:target forKey:@"target"];
     [json setObject:@(0.0) forKey:@"tilt"];
     [json setObject:@((NSInteger)self.map.hash) forKey:@"hashCode"];
     [json setObject:@(self.zoom) forKey:@"zoom"];
 
     NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
     NSString* sourceArrayString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onCameraEvent('%@', %@);", eventName, sourceArrayString];
 
     if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)])
     {
         [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
     }
     else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)])
     {
         [self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
     }
 }

/**
 * Involve App._onMapEvent
 */

- (void)triggerMapEvent: (NSString *)eventName coordinate:(CLLocationCoordinate2D)coordinate
{
    NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onMapEvent('%@', new window.plugin.google.maps.LatLng(%f,%f));",
                          eventName, coordinate.latitude, coordinate.longitude];
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)])
    {
        [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
    }
    else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)])
    {
        [self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
    }
}

/**
 * Involve App._onMarkerEvent
 */
- (void)triggerMarkerEvent: (NSString *)eventName marker:(MKPointAnnotation *)marker
{
    NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onMarkerEvent('%@', 'marker_%lu');",
                          eventName, (unsigned long)marker.hash];
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)])
    {
        [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
    }
    else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)])
    {
        [self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
    }
}

/**
 * Involve App._onOverlayEvent
 */
- (void)triggerOverlayEvent: (NSString *)eventName id:(NSString *) id
{
    NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onOverlayEvent('%@', '%@');",
                          eventName, id];
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)])
    {
        [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
    }
    else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)])
    {
        [self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
    }
}

#pragma mark - Gesture Recognizer Actions

-(void)tap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D coordinate = [self.map convertPoint:tapPoint toCoordinateFromView:self.map];
    
    [self triggerMapEvent:@"click" coordinate:coordinate];
}

-(void)longPress:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D coordinate = [self.map convertPoint:tapPoint toCoordinateFromView:self.map];
    
    [self triggerMapEvent:@"long_click" coordinate:coordinate];
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Init & View LifeCycle

- (id)initWithOptions:(NSDictionary *) options {
    self = [super init];
    initOptions = [[NSDictionary alloc] initWithDictionary:options];
    self.plugins = [NSMutableDictionary dictionary];
    self.isFullScreen = NO;
    self.embedRect = nil;
    self.screenSize = [[UIScreen mainScreen] bounds];

    return self;
}

- (void)loadView {
  [super loadView];
  [self updateMapViewLayout];
}
- (void)updateMapViewLayout {
  
  if (self.isFullScreen == NO) {
    [self.view setFrameWithDictionary:self.embedRect];
  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[NSArray arrayWithObjects:[NSNumber numberWithInt:128],
                                                            [NSNumber numberWithInt:128],
                                                            [NSNumber numberWithInt:128],
                                                            [NSNumber numberWithInt:128], nil] parsePluginColor];
  
    //------------
    // Initialize
    //------------
    self.overlayManager = [NSMutableDictionary dictionary];
    
    //------------------
    // Create a map view
    //------------------
  
    //Intial camera position
    /*
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
    */
    
    // Create MKMapView
    
    self.map = [[MKMapView alloc] init];
    
    // Set Map Frame
    
    CGRect pluginRect = self.view.frame;
    int marginBottom = 0;
    CGRect mapRect = CGRectMake(0, 0, pluginRect.size.width, pluginRect.size.height  - marginBottom);
    self.map.frame = mapRect;
    self.map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Set Map Delegate
    
    self.map.delegate = self;
    
    // Add Map as Subview of View
    
    [self.view addSubview:self.map];
    
    // Init Tap & Long Press Recognizers
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.tapRecognizer.numberOfTapsRequired = 1;
    self.tapRecognizer.delegate = self;
    
    [self.map addGestureRecognizer:self.tapRecognizer];
    
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    self.longPressRecognizer.minimumPressDuration = 2.0;
    self.longPressRecognizer.delegate = self;
    
    [self.map addGestureRecognizer:self.longPressRecognizer];
    
    // Set Map Options
    
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
        
        BOOL isEnabled = NO;
        
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
                
                [rotatedLongitudes addObject:@(longitude)];
                
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
        
        BOOL isEnabled = NO;
        
        if ([controls valueForKey:@"compass"] != nil)
        {
            isEnabled = [[controls valueForKey:@"compass"] boolValue];
            self.map.showsCompass = isEnabled;
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
    NSDictionary *cameraOpts = [initOptions objectForKey:@"camera"];
    NSMutableDictionary *latLng = [NSMutableDictionary dictionary];
    [latLng setObject:[NSNumber numberWithFloat:0.0f] forKey:@"lat"];
    [latLng setObject:[NSNumber numberWithFloat:0.0f] forKey:@"lng"];
    float latitude;
    float longitude;
    GMSCameraPosition *camera;
    GMSCoordinateBounds *cameraBounds = nil;
  
    if ([cameraOpts objectForKey:@"target"]) {
      NSString *targetClsName = [[cameraOpts objectForKey:@"target"] className];
      if ([targetClsName isEqualToString:@"__NSCFArray"] || [targetClsName isEqualToString:@"__NSArrayM"] ) {
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
                                            zoom:0
                                            bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                                            viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
        
      } else {
        latLng = [cameraOpts objectForKey:@"target"];
        latitude = [[latLng valueForKey:@"lat"] floatValue];
        longitude = [[latLng valueForKey:@"lng"] floatValue];
        
        camera = [GMSCameraPosition cameraWithLatitude:latitude
                                            longitude:longitude
                                            zoom:[[cameraOpts valueForKey:@"zoom"] floatValue]
                                            bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                                            viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
      }
    } else {
      camera = [GMSCameraPosition
                              cameraWithLatitude: [[latLng valueForKey:@"lat"] floatValue]
                              longitude: [[latLng valueForKey:@"lng"] floatValue]
                              zoom: [[cameraOpts valueForKey:@"zoom"] floatValue]
                              bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                              viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
    }
    */
    
    /*
    CGRect pluginRect = self.view.frame;
    int marginBottom = 0;
    //if ([PluginUtil isIOS7] == false) {
    //  marginBottom = 20;
    //}
    CGRect mapRect = CGRectMake(0, 0, pluginRect.size.width, pluginRect.size.height  - marginBottom);
    //NSLog(@"mapRect=%f,%f - %f,%f", mapRect.origin.x, mapRect.origin.y, mapRect.size.width, mapRect.size.height);
    //NSLog(@"mapRect=%@", camera);
    self.map = [GMSMapView mapWithFrame:mapRect camera:camera];
    self.map.delegate = self;
    //self.map.autoresizingMask = UIViewAutoresizingNone;
    self.map.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
    //indoor display
    self.map.indoorDisplay.delegate = self;
    */
  
    /*
    BOOL isEnabled = NO;
    //controls
    NSDictionary *controls = [initOptions objectForKey:@"controls"];
    if (controls) {
      //compass
      if ([controls valueForKey:@"compass"] != nil) {
        isEnabled = [[controls valueForKey:@"compass"] boolValue];
        self.map.settings.compassButton = isEnabled;
      }
      //myLocationButton
      if ([controls valueForKey:@"myLocationButton"] != nil) {
        isEnabled = [[controls valueForKey:@"myLocationButton"] boolValue];
        self.map.settings.myLocationButton = isEnabled;
        self.map.myLocationEnabled = isEnabled;
      }
      //indoorPicker
      if ([controls valueForKey:@"indoorPicker"] != nil) {
        isEnabled = [[controls valueForKey:@"indoorPicker"] boolValue];
        self.map.settings.indoorPicker = isEnabled;
      }
    } else {
      self.map.settings.compassButton = TRUE;
    }
    */
    
    /*
    //gestures
    NSDictionary *gestures = [initOptions objectForKey:@"gestures"];
    if (gestures) {
      //rotate
      if ([gestures valueForKey:@"rotate"] != nil) {
        isEnabled = [[gestures valueForKey:@"rotate"] boolValue];
        self.map.settings.rotateGestures = isEnabled;
      }
      //scroll
      if ([gestures valueForKey:@"scroll"] != nil) {
        isEnabled = [[gestures valueForKey:@"scroll"] boolValue];
        self.map.settings.scrollGestures = isEnabled;
      }
      //tilt
      if ([gestures valueForKey:@"tilt"] != nil) {
        isEnabled = [[gestures valueForKey:@"tilt"] boolValue];
        self.map.settings.tiltGestures = isEnabled;
      }
      //zoom
      if ([gestures valueForKey:@"zoom"] != nil) {
        isEnabled = [[gestures valueForKey:@"zoom"] boolValue];
        self.map.settings.zoomGestures = isEnabled;
      }
    }
    */
    /*
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
        self.map.mapType = mapType;
      }
    }
    */
    /*
    [self.view addSubview: self.map];
  
    dispatch_async(dispatch_get_main_queue(), ^{
      if (cameraBounds != nil) {
        float scale = 1;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
          scale = [[UIScreen mainScreen] scale];
        }
        [[UIScreen mainScreen] scale];
        [self.map moveCamera:[GMSCameraUpdate fitBounds:cameraBounds withPadding:10 * scale]];
        
        GMSCameraPosition *cameraPosition2 = [GMSCameraPosition cameraWithLatitude:cameraBounds.center.latitude
                                            longitude:cameraBounds.center.longitude
                                            zoom:self.map.camera.zoom
                                            bearing:[[cameraOpts objectForKey:@"bearing"] doubleValue]
                                            viewingAngle:[[cameraOpts objectForKey:@"tilt"] doubleValue]];
      
        [self.map setCamera:cameraPosition2];

      }
    });
    */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * Called when the My Location button is tapped.
 *
 * @return YES if the listener has consumed the event (i.e., the default behavior should not occur),
 *         NO otherwise (i.e., the default behavior should occur). The default behavior is for the
 *         camera to move such that it is centered on the user location.
 */
/*
- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
	NSString *jsString = @"plugin.google.maps.Map._onMapEvent('my_location_button_click');";
	if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		[self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	} else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	}
	return NO;
}
*/

#pragma mark - Set Zoom

- (void)setZoom:(NSInteger)zoom
{
    [self setCenterCoordinate:self.map.centerCoordinate zoom:zoom animated:NO];
}

- (NSInteger)zoom
{
    return log2(360 * ((self.map.frame.size.width / 256) / self.map.region.span.longitudeDelta)) + 1;
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoom:(NSInteger)zoom animated:(BOOL)animated
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360 / pow(2, zoom) * self.map.frame.size.width / 256);
    [self.map setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}

#pragma mark - MKMapViewDelegate

#pragma mark - Responding to Map Position Changes

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    BOOL gesture = NO;
    
    dispatch_queue_t gueue = dispatch_queue_create("plugin.google.maps.Map._onMapEvent", NULL);
    dispatch_sync(gueue, ^{
        
        NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onMapEvent('will_move', %@);", gesture ? @"true": @"false"];
        
        if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)])
        {
            [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
        }
        else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)])
        {
            [self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
        }
    });
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self triggerCameraEvent:@"camera_change" position:mapView.region.center];
}

#pragma mark - Loading the Map Data

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView
                       withError:(NSError *)error
{
    
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
    
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    
}

#pragma mark - Tracking the User Location

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    
}

#pragma mark - Managing the Annotation Views

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Create AnnotationIdentifier From Image URL
    
    MarkerAnnotation *marker = (MarkerAnnotation *)annotation;
    
    NSArray *components = [marker.iconURL componentsSeparatedByString:@"/"];
    NSString *pngName = (NSString *)components.lastObject;
    NSArray *pngComponents = [pngName componentsSeparatedByString:@"."];
    NSString *imageName = (NSString *)pngComponents.firstObject;
    
    NSString *AnnotationIdentifier = [NSString stringWithFormat:@"%@Annotation", imageName];
    
    MKAnnotationView *annoView;
    
    annoView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    
    if (!annoView)
    {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        
        if (marker.iconURL)
        {
            [self imageForAnnotation:marker imageBlock:^(UIImage *image) {
                annoView.image = image;
            }];
        }
    }
    
    annoView.annotation = annotation;
    annoView.canShowCallout = YES;
    annoView.draggable = marker.draggable;
    
    return annoView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self triggerMarkerEvent:@"info_click" marker:view.annotation];
}

#pragma mark - Dragging an Annotation View

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateStarting)
    {
        [self triggerMarkerEvent:@"drag_start" marker:annotationView.annotation];
    }
    else if (newState == MKAnnotationViewDragStateEnding)
    {
        [self triggerMarkerEvent:@"drag_end" marker:annotationView.annotation];
    }
    else if (newState == MKAnnotationViewDragStateDragging)
    {
        [self triggerMarkerEvent:@"drag" marker:annotationView.annotation];
    }
}

#pragma mark - Selecting Annotation UIAlertViewStyle

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self triggerMarkerEvent:@"click" marker:view.annotation];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer;
    
    if ([overlay isKindOfClass:[PolylineOverlay class]])
    {
        PolylineOverlay *polylineOverlay = (PolylineOverlay *) overlay;
        
        renderer = (MKOverlayRenderer *) [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        
        ((MKOverlayPathRenderer *)renderer).strokeColor = polylineOverlay.strokeColor;
        ((MKOverlayPathRenderer *)renderer).lineWidth = polylineOverlay.strokeWidth;

        ((MKOverlayPathRenderer *)renderer).lineJoin = kCGLineJoinRound;
        ((MKOverlayPathRenderer *)renderer).lineCap = kCGLineCapRound;
    }
    
    return renderer;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray<MKOverlayRenderer *> *)renderers
{
    
}

#pragma mark - Image For Annotation View

-(void)imageForAnnotation:(MarkerAnnotation *)annotation imageBlock:(void( ^ )(UIImage* image))imageBlock
{
    NSString *iconPath = annotation.iconURL;
    
    CGFloat width = annotation.iconWidth;
    CGFloat height = annotation.iconHeight;
    
    UIImage *image;
    
    if (iconPath)
    {
        NSRange range = [iconPath rangeOfString:@"http"];
        
        if (range.location != 0)
        {
            /**
             * Load icon from file or Base64 encoded strings
             */
            
            BOOL isTextMode = true;
            
            if ([iconPath rangeOfString:@"data:image/"].location != NSNotFound && [iconPath rangeOfString:@";base64,"].location != NSNotFound)
            {
                /**
                 * Base64 icon
                 */
                
                isTextMode = false;
                
                NSArray *tmp = [iconPath componentsSeparatedByString:@","];
                
                NSData *decodedData;
#if !defined(__IPHONE_8_0)
                if ([PluginUtil isIOS7_OR_OVER])
                {
                    decodedData = [NSData dataFromBase64String:tmp[1]];
                }
                else
                {
#if !defined(__IPHONE_7_0)
                    decodedData = [[NSData alloc] initWithBase64Encoding:(NSString *)tmp[1]];
#endif
                }
#else
                decodedData = [NSData dataFromBase64String:tmp[1]];
#endif
                image = [[UIImage alloc] initWithData:decodedData];
                
                if (width > 0 && height > 0)
                {
                    image = [image resize:width height:height];
                }
                
                imageBlock(image);
            }
            else
            {
                /**
                 * Load the icon from local path
                 */
                
                range = [iconPath rangeOfString:@"cdvfile://"];
                
                if (range.location != NSNotFound) {
                    
                    iconPath = [PluginUtil getAbsolutePathFromCDVFilePath:self.webView cdvFilePath:iconPath];
                    
                    if (iconPath == nil)
                    {
                        if (self.debuggable)
                        {
                            NSLog(@"(debug)Can not convert '%@' to device full path.", iconPath);
                        }
                        
                        return;
                    }
                }
                
                
                range = [iconPath rangeOfString:@"://"];
                
                if (range.location == NSNotFound)
                {
                    range = [iconPath rangeOfString:@"www/"];
                
                    if (range.location == NSNotFound)
                    {
                        iconPath = [NSString stringWithFormat:@"www/%@", iconPath];
                    }
                    
                    range = [iconPath rangeOfString:@"/"];
                    
                    if (range.location != 0)
                    {
                        // Get the absolute path of the www folder.
                        // https://github.com/apache/cordova-plugin-file/blob/1e2593f42455aa78d7fff7400a834beb37a0683c/src/ios/CDVFile.m#L506
                    
                        NSString *applicationDirectory = [[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]] absoluteString];
                        
                        iconPath = [NSString stringWithFormat:@"%@%@", applicationDirectory, iconPath];
                    }
                    else
                    {
                        iconPath = [NSString stringWithFormat:@"file://%@", iconPath];
                    }
                }
                
                range = [iconPath rangeOfString:@"file://"];
                
                if (range.location != NSNotFound)
                {
                    iconPath = [iconPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if (![fileManager fileExistsAtPath:iconPath])
                    {
                        if (self.debuggable)
                        {
                            NSLog(@"(debug)There is no file at '%@'.", iconPath);
                        }
                        
                        return;
                    }
                }
                
                image = [UIImage imageNamed:iconPath];
                
                if (width > 0 && height > 0)
                {
                    image = [image resize:width height:height];
                }
                
                imageBlock(image);
            }
        }
        else
        {
            if (self.debuggable)
            {
                NSLog(@"---- Load the icon from the internet");
            }
            
            /***
             * Load the icon from the internet
             */

            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                
                NSURL *url = [NSURL URLWithString:iconPath];
                
                [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image)
                {
                    if (!succeeded)
                    {                        
                        return;
                    }
                    
                    if (width > 0 && height > 0)
                    {
                        image = [image resize:width height:height];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageBlock(image);
                    });
                }];
            });
        }
    }
}

#pragma mark - GMSMapViewDelegate

/**
 * @callback the my location button is clicked.
 */
/*
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self triggerMapEvent:@"click" coordinate:coordinate];
}
*/
/**
 * @callback map long_click
 */
/*
- (void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [self triggerMapEvent:@"long_click" coordinate:coordinate];
}
*/
/**
 * @callback map will_move
 */
/*
- (void) mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
  dispatch_queue_t gueue = dispatch_queue_create("plugin.google.maps.Map._onMapEvent", NULL);
  dispatch_sync(gueue, ^{
  
    NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onMapEvent('will_move', %@);", gesture ? @"true": @"false"];
	  if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		  [self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	  } else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		  [self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	  }
  });
}
*/

/**
 * @callback map camera_change
 */
/*
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
  [self triggerCameraEvent:@"camera_change" position:position];
}
*/
/**
 * @callback map camera_idle
 */
/*
- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
  [self triggerCameraEvent:@"camera_idle" position:position];
}
*/

/**
 * @callback marker info_click
 */
/*
- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
  [self triggerMarkerEvent:@"info_click" marker:marker];
}
*/
/**
 * @callback marker drag_start
 */
/*
- (void) mapView:(GMSMapView *) mapView didBeginDraggingMarker:(GMSMarker *)marker
{
  [self triggerMarkerEvent:@"drag_start" marker:marker];
}
*/
/**
 * @callback marker drag_end
 */
/*
- (void) mapView:(GMSMapView *) mapView didEndDraggingMarker:(GMSMarker *)marker
{
  [self triggerMarkerEvent:@"drag_end" marker:marker];
}
*/
/**
 * @callback marker drag
 */
/*
- (void) mapView:(GMSMapView *) mapView didDragMarker:(GMSMarker *)marker
{
  [self triggerMarkerEvent:@"drag" marker:marker];
}
*/
/**
 * @callback marker click
 */
/*
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  [self triggerMarkerEvent:@"click" marker:marker];

  
  NSString *markerPropertyId = [NSString stringWithFormat:@"marker_property_%lu", (unsigned long)marker.hash];
  
  NSDictionary *properties = [self.overlayManager objectForKey:markerPropertyId];
  BOOL disableAutoPan = false;
  if ([properties objectForKey:@"disableAutoPan"] != nil) {
    disableAutoPan = [[properties objectForKey:@"disableAutoPan"] boolValue];
    if (disableAutoPan) {
      self.map.selectedMarker = marker;
      return YES;
    }
  }
	return NO;
}
*/

/*
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
  NSString *overlayClass = NSStringFromClass([overlay class]);
  if ([overlayClass isEqualToString:@"GMSPolygon"] ||
      [overlayClass isEqualToString:@"GMSPolyline"] ||
      [overlayClass isEqualToString:@"GMSCircle"] ||
      [overlayClass isEqualToString:@"GMSGroundOverlay"]) {
    [self triggerOverlayEvent:@"overlay_click" id:overlay.title];
  }
}
*/

/**
 * Involve App._onMapEvent
 */
/*
- (void)triggerMapEvent: (NSString *)eventName coordinate:(CLLocationCoordinate2D)coordinate
{
  NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onMapEvent('%@', new window.plugin.google.maps.LatLng(%f,%f));",
                                      eventName, coordinate.latitude, coordinate.longitude];
	if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		[self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	} else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	}
}
*/
/**
 * Involve App._onCameraEvent
 */
/*
- (void)triggerCameraEvent: (NSString *)eventName position:(GMSCameraPosition *)position
{

  NSMutableDictionary *target = [NSMutableDictionary dictionary];
  [target setObject:[NSNumber numberWithDouble:position.target.latitude] forKey:@"lat"];
  [target setObject:[NSNumber numberWithDouble:position.target.longitude] forKey:@"lng"];

  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  [json setObject:[NSNumber numberWithFloat:position.bearing] forKey:@"bearing"];
  [json setObject:target forKey:@"target"];
  [json setObject:[NSNumber numberWithDouble:position.viewingAngle] forKey:@"tilt"];
  [json setObject:[NSNumber numberWithInt:(int)position.hash] forKey:@"hashCode"];
  [json setObject:[NSNumber numberWithFloat:position.zoom] forKey:@"zoom"];
  
  
  NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
  NSString* sourceArrayString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onCameraEvent('%@', %@);", eventName, sourceArrayString];

	if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		[self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	} else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	}
}
*/

/**
 * Involve App._onMarkerEvent
 */
/*
- (void)triggerMarkerEvent: (NSString *)eventName marker:(GMSMarker *)marker
{
  NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onMarkerEvent('%@', 'marker_%lu');",
                                      eventName, (unsigned long)marker.hash];
	if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		[self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	} else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	}
}
*/
/**
 * Involve App._onOverlayEvent
 */
/*
- (void)triggerOverlayEvent: (NSString *)eventName id:(NSString *) id
{
  NSString* jsString = [NSString stringWithFormat:@"plugin.google.maps.Map._onOverlayEvent('%@', '%@');",
                                      eventName, id];
	if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		[self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	} else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	}
}
*/

/*
//future support: custom info window
-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker*)marker
{
  CGSize rectSize;
  CGSize textSize;
  CGSize snippetSize;
  UIFont *titleFont;
  UIFont *snippetFont;
  UIImage *base64Image;
  
  Boolean isTextMode = false;
  NSString *title = marker.title;
  NSString *snippet = marker.snippet;
  
  if (title == nil) {
    return NULL;
  }
  
  // Load styles
  NSString *markerPropertyId = [NSString stringWithFormat:@"marker_property_%lu", (unsigned long)marker.hash];
  NSDictionary *properties = [self.overlayManager objectForKey:markerPropertyId];
  NSDictionary *styles = nil;
  if ([properties objectForKey:@"styles"]) {
    styles = [properties objectForKey:@"styles"];
  }
  
  // Load images
  UIImage *leftImg = nil;
  UIImage *rightImg = nil;[self loadImageFromGoogleMap:@"bubble_right@2x"];
  leftImg = [self loadImageFromGoogleMap:@"bubble_left@2x"];
  rightImg = [self loadImageFromGoogleMap:@"bubble_right@2x"];
  float scale = leftImg.scale;
  int sizeEdgeWidth = 10;

	int width = 0;

	if (styles && [styles objectForKey:@"width"]) {
		NSString *widthString = [styles valueForKey:@"width"];
        
        // check if string is numeric
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        BOOL isNumeric = [nf numberFromString:widthString] != nil;

		if ([widthString hasSuffix:@"%"]) {
			double widthDouble = [[widthString stringByReplacingOccurrencesOfString:@"%" withString:@""] doubleValue];
			
			width = (int)((double)mapView.frame.size.width * (widthDouble / 100));
		} else if (isNumeric) {
			double widthDouble = [widthString doubleValue];

			if (widthDouble <= 1.0) {
				width = (int)((double)mapView.frame.size.width * (widthDouble));
			} else {
				width = (int)widthDouble;
			}
		}
	}

	int maxWidth = 0;

	if (styles && [styles objectForKey:@"maxWidth"]) {
		NSString *widthString = [styles valueForKey:@"maxWidth"];
		
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        BOOL isNumeric = [nf numberFromString:widthString] != nil;
        
		if ([widthString hasSuffix:@"%"]) {
			double widthDouble = [[widthString stringByReplacingOccurrencesOfString:@"%" withString:@""] doubleValue];
			
			maxWidth = (int)((double)mapView.frame.size.width * (widthDouble / 100));
			
			// make sure to take padding into account.
			maxWidth -= sizeEdgeWidth;
		} else if (isNumeric) {
			double widthDouble = [widthString doubleValue];
			
			if (widthDouble <= 1.0) {
				maxWidth = (int)((double)mapView.frame.size.width * (widthDouble));
			} else {
				maxWidth = (int)widthDouble;
			}
		}
	}

  //-------------------------------------
  // Calculate the size for the contents
  //-------------------------------------
  if ([title rangeOfString:@"data:image/"].location != NSNotFound &&
      [title rangeOfString:@";base64,"].location != NSNotFound) {
    
    isTextMode = false;
    NSArray *tmp = [title componentsSeparatedByString:@","];
    NSData *decodedData;
    #ifdef __IPHONE_7_0
      if ([PluginUtil isIOS7_OR_OVER]) {
        decodedData = [[NSData alloc] initWithBase64Encoding:(NSString *)tmp[1]];
      } else {
        decodedData = [NSData dataFromBase64String:tmp[1]];
      }
    #else
      decodedData = [NSData dataFromBase64String:tmp[1]];
    #endif
    
    base64Image = [[UIImage alloc] initWithData:decodedData];
    rectSize = CGSizeMake(base64Image.size.width + leftImg.size.width, base64Image.size.height + leftImg.size.height / 2);
    
  } else {
  
    isTextMode = true;
    
    BOOL isBold = FALSE;
    BOOL isItalic = FALSE;
    if (styles) {
      if ([[styles objectForKey:@"font-style"] isEqualToString:@"italic"]) {
        isItalic = TRUE;
      }
      if ([[styles objectForKey:@"font-weight"] isEqualToString:@"bold"]) {
        isBold = TRUE;
      }
    }
    if (isBold == TRUE && isItalic == TRUE) {
      if ([PluginUtil isIOS7_OR_OVER] == true) {
        // ref: http://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad#21777132
        titleFont = [UIFont systemFontOfSize:17.0f];
        UIFontDescriptor *fontDescriptor = [titleFont.fontDescriptor
                                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];
        titleFont = [UIFont fontWithDescriptor:fontDescriptor size:0];
      } else {
        titleFont = [UIFont fontWithName:@"Helvetica-BoldOblique" size:17.0];
      }
    } else if (isBold == TRUE && isItalic == FALSE) {
      titleFont = [UIFont boldSystemFontOfSize:17.0f];
    } else if (isBold == TRUE && isItalic == FALSE) {
      titleFont = [UIFont italicSystemFontOfSize:17.0f];
    } else {
      titleFont = [UIFont systemFontOfSize:17.0f];
    }
    
    // Calculate the size for the title strings
    textSize = [title sizeWithFont:titleFont constrainedToSize: CGSizeMake(mapView.frame.size.width - 13, mapView.frame.size.height - 13)];
    rectSize = CGSizeMake(textSize.width + 10, textSize.height + 22);
    
    // Calculate the size for the snippet strings
    if (snippet) {
      snippetFont = [UIFont systemFontOfSize:12.0f];
      snippet = [snippet stringByReplacingOccurrencesOfString:@"\n" withString:@""];
      snippetSize = [snippet sizeWithFont:snippetFont constrainedToSize: CGSizeMake(mapView.frame.size.width - 13, mapView.frame.size.height - 13)];
      rectSize.height += snippetSize.height + 4;
      if (rectSize.width < snippetSize.width + leftImg.size.width) {
        rectSize.width = snippetSize.width + leftImg.size.width;
      }
    }
  }
  if (rectSize.width < leftImg.size.width * scale) {
    rectSize.width = leftImg.size.width * scale;
  } else {
    rectSize.width += sizeEdgeWidth;
  }
	
	if (width > 0) {
		rectSize.width = width;
	}
	if (maxWidth > 0 &&
		maxWidth < rectSize.width) {
		rectSize.width = maxWidth;
	}
  
  //-------------------------------------
  // Draw the the info window
  //-------------------------------------
  UIGraphicsBeginImageContextWithOptions(rectSize, NO, 0.0f);
  
  CGRect trimArea = CGRectMake(15, 0, 5, MIN(45, rectSize.height - 20));
  
  trimArea = CGRectMake(15, 0, 15, leftImg.size.height);
  if (scale > 1.0f) {
    trimArea = CGRectMake(trimArea.origin.x * scale,
                      trimArea.origin.y * scale,
                      trimArea.size.width * scale +1,
                      trimArea.size.height * scale);
  }
  CGImageRef shadowImageRef = CGImageCreateWithImageInRect(leftImg.CGImage, trimArea);
  UIImage *shadowImageLeft = [UIImage imageWithCGImage:shadowImageRef scale:scale orientation:UIImageOrientationUp];
  UIImage *shadowImageRight = [UIImage imageWithCGImage:shadowImageRef scale:scale orientation:UIImageOrientationUpMirrored];

  int y;
  int i = 0;
  int x = shadowImageLeft.size.width;
  float centerPos = rectSize.width * 0.5f;
  while (centerPos - x > shadowImageLeft.size.width) {
    y = 1;
    while (y + shadowImageLeft.size.height < rectSize.height) {
      [shadowImageLeft drawAtPoint:CGPointMake(centerPos - x, y)];
      [shadowImageRight drawAtPoint:CGPointMake(centerPos + x - shadowImageLeft.size.width, y)];
      y += shadowImageRight.size.height;
    }
    y = rectSize.height - shadowImageLeft.size.height;
    [shadowImageLeft drawAtPoint:CGPointMake(centerPos - x, y)];
    [shadowImageRight drawAtPoint:CGPointMake(centerPos + x - shadowImageLeft.size.width, y)];
    
    if (i == 0) {
      x += 5;
    
      trimArea = CGRectMake(15, 0, 5, leftImg.size.height);
      if (scale > 1.0f) {
        trimArea = CGRectMake(trimArea.origin.x * scale,
                          trimArea.origin.y * scale,
                          trimArea.size.width * scale,
                          trimArea.size.height * scale);
      }
      shadowImageRef = CGImageCreateWithImageInRect(leftImg.CGImage, trimArea);
      shadowImageLeft = [UIImage imageWithCGImage:shadowImageRef scale:scale orientation:UIImageOrientationUp];
      shadowImageRight = [UIImage imageWithCGImage:shadowImageRef scale:scale orientation:UIImageOrientationUpMirrored];
    
    } else {
      x += shadowImageLeft.size.width;
    }
    i++;
  }
  
  // Draw left & right side edges
  x -= shadowImageLeft.size.width;
  trimArea = CGRectMake(0, 0, sizeEdgeWidth, leftImg.size.height);
  if (scale > 1.0f) {
    trimArea = CGRectMake(trimArea.origin.x * scale,
                      trimArea.origin.y * scale,
                      trimArea.size.width * scale,
                      trimArea.size.height * scale);
  }
  shadowImageRef = CGImageCreateWithImageInRect(leftImg.CGImage, trimArea);
  shadowImageLeft = [UIImage imageWithCGImage:shadowImageRef scale:scale orientation:UIImageOrientationUp];
  shadowImageRight = [UIImage imageWithCGImage:shadowImageRef scale:scale orientation:UIImageOrientationUpMirrored];
  x += shadowImageLeft.size.width;
  
  y = 1;
  while (y + shadowImageLeft.size.height < rectSize.height) {
    [shadowImageLeft drawAtPoint:CGPointMake(centerPos - x, y)];
    [shadowImageRight drawAtPoint:CGPointMake(centerPos + x - shadowImageLeft.size.width, y)];
    y += shadowImageRight.size.height;
  }
  y = rectSize.height - shadowImageLeft.size.height;
  [shadowImageLeft drawAtPoint:CGPointMake(centerPos - x, y)];
  [shadowImageRight drawAtPoint:CGPointMake(centerPos + x - shadowImageLeft.size.width, y)];
  
  // Fill the body area with WHITE color
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetAllowsAntialiasing(context, true);
  CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
  
  if (isTextMode) {

    if (snippet) {
      CGContextFillRect(context, CGRectMake(centerPos - x + 5, 4, rectSize.width - (centerPos - x + 7), rectSize.height - 16));
    } else {
      CGContextFillRect(context, CGRectMake(centerPos - x + 5, 0, rectSize.width - (centerPos - x + 7), rectSize.height - 11));
    }
  } else {
    CGContextFillRect(context, CGRectMake(centerPos - x + 5, 4, rectSize.width - (centerPos - x + 5), rectSize.height - 16));
  }
  
  //--------------------------------
  // text-align: left/center/right
  //--------------------------------
  NSTextAlignment textAlignment = NSTextAlignmentLeft;
  if (styles && [styles objectForKey:@"text-align"]) {
    NSString *textAlignValue = [styles objectForKey:@"text-align"];
    
    NSDictionary *aligments = [NSDictionary dictionaryWithObjectsAndKeys:
                            ^() {return NSTextAlignmentLeft; }, @"left",
                            ^() {return NSTextAlignmentRight; }, @"right",
                            ^() {return NSTextAlignmentCenter; }, @"center",
                            nil];
  
    typedef NSTextAlignment (^CaseBlock)();
    CaseBlock caseBlock = aligments[textAlignValue];
    if (caseBlock) {
      textAlignment = caseBlock();
    }
  }
  
  //-------------------------------------
  // Draw the contents
  //-------------------------------------
  if (isTextMode) {
    //Draw the title strings
    if (title) {
      UIColor *titleColor = [UIColor blackColor];
      if (styles && [styles objectForKey:@"color"]) {
        titleColor = [[styles valueForKey:@"color"] parsePluginColor];
      }
      
      CGRect textRect = CGRectMake(5, 5 , rectSize.width - 10, textSize.height );
      if ([PluginUtil isIOS7_OR_OVER] == true) {
        // iOS7 and above
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = textAlignment;
        
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName : titleColor,
            NSFontAttributeName : titleFont,
            NSParagraphStyleAttributeName : style
        };
        [title drawInRect:textRect
               withAttributes:attributes];
        
        
      } else {
        // iOS6
        [titleColor set];
        [title drawInRect:textRect
                withFont:titleFont
                lineBreakMode:NSLineBreakByWordWrapping
                alignment:textAlignment];
      }
      //CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.5);
      //CGContextStrokeRect(context, textRect);
    }
    
    //Draw the snippet
    if (snippet) {
      CGRect textRect = CGRectMake(5, textSize.height + 10 , rectSize.width - 10, snippetSize.height );
      if ([PluginUtil isIOS7_OR_OVER] == true) {
          // iOS7 and above
          NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
          style.lineBreakMode = NSLineBreakByWordWrapping;
          style.alignment = textAlignment;
          
          NSDictionary *attributes = @{
              NSForegroundColorAttributeName : [UIColor grayColor],
              NSFontAttributeName : snippetFont,
              NSParagraphStyleAttributeName : style
          };
          [snippet drawInRect:textRect withAttributes:attributes];
        } else {
          // iOS6
          [[UIColor grayColor] set];
          [snippet drawInRect:textRect
                  withFont:snippetFont
                  lineBreakMode:NSLineBreakByWordWrapping
                  alignment:textAlignment];
        }
    }
  } else {
    //Draw the content image
    CGRect imageRect = CGRectMake((rectSize.width - base64Image.size.width) / 2 ,
                                  -1 * ((rectSize.height - base64Image.size.height - 20) / 2 + 7.5),
                                  base64Image.size.width, base64Image.size.height);
    CGContextTranslateCTM(context, 0, base64Image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, imageRect, base64Image.CGImage);
  }
  

  //-------------------------------------
  // Generate new image
  //-------------------------------------
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rectSize.width, rectSize.height)];
  [imageView setContentMode:UIViewContentModeScaleAspectFill];
  [imageView setImage:image];
  return imageView;
}
*/

/*
-(UIImage *)loadImageFromGoogleMap:(NSString *)fileName {
  NSString *imagePath = [[NSBundle bundleWithIdentifier:@"com.google.GoogleMaps"] pathForResource:fileName ofType:@"png"];
  return [[UIImage alloc] initWithContentsOfFile:imagePath];
}

- (void) didChangeActiveBuilding: (GMSIndoorBuilding *)building {
  //Notify to the JS
  NSString* jsString = @"javascript:plugin.google.maps.Map._onMapEvent('indoor_building_focused')";
	if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		[self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	} else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	}
}

- (void) didChangeActiveLevel: (GMSIndoorLevel *)activeLevel {
  
  GMSIndoorBuilding *building = self.map.indoorDisplay.activeBuilding;
  
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
  
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&error];
  
  NSString *JSONstring = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
  NSString *jsString = [NSString stringWithFormat:@"javascript:plugin.google.maps.Map._onMapEvent('indoor_level_activated', %@)", JSONstring];
  
	if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
		[self.webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsString];
	} else if ([self.webView respondsToSelector:@selector(evaluateJavaScript:completionHandler:)]) {
		[self.webView performSelector:@selector(evaluateJavaScript:completionHandler:) withObject:jsString withObject:nil];
	}
}

- (GMSCircle *)getCircleByKey: (NSString *)key {
  return [self.overlayManager objectForKey:key];
}

- (GMSMarker *)getMarkerByKey: (NSString *)key {
  return [self.overlayManager objectForKey:key];
}

- (GMSPolygon *)getPolygonByKey: (NSString *)key {
  return [self.overlayManager objectForKey:key];
}

- (GMSPolyline *)getPolylineByKey: (NSString *)key {
  return [self.overlayManager objectForKey:key];
}
- (GMSTileLayer *)getTileLayerByKey: (NSString *)key {
  return [self.overlayManager objectForKey:key];
}
- (GMSGroundOverlay *)getGroundOverlayByKey: (NSString *)key {
  return [self.overlayManager objectForKey:key];
}
- (UIImage *)getUIImageByKey:(NSString *)key {
  return [self.overlayManager objectForKey:key];
}
*/

- (void)removeObjectForKey: (NSString *)key
{
  [self.overlayManager removeObjectForKey:key];
}

#pragma mark - Download Image Async

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response,  NSError *error) {
                                                if ( !error )
                                                {
                                                    UIImage *image = [[UIImage alloc] initWithData:data];
                                                    completionBlock(YES,image);
                                                }
                                                else
                                                {
                                                    completionBlock(NO,nil);
                                                }
                                            }];
    
    [task resume];
}

@end
