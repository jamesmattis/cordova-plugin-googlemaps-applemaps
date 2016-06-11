//
//  GoogleMapsViewController.h
//  SimpleMap
//
//  Created by masashi on 11/6/13.
//
//

#import <Cordova/CDV.h>
#import <GoogleMaps/GoogleMaps.h>
#import <UIKit/UIKit.h>
#import "PluginUtil.h"
#import "NSData+Base64.h"

#import <MapKit/MapKit.h>

//@interface GoogleMapsViewController : UIViewController<GMSMapViewDelegate, GMSIndoorDisplayDelegate>
@interface GoogleMapsViewController : UIViewController<MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) MKMapView *map;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

//@property (nonatomic, strong) GMSMapView* map;
@property (nonatomic, strong) UIView* webView;
@property (nonatomic, strong) NSMutableDictionary* overlayManager;
@property (nonatomic, readwrite, strong) NSMutableDictionary* plugins;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) NSDictionary *embedRect;
@property (nonatomic) CGRect screenSize;
@property (nonatomic) BOOL debuggable;

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker;
- (id)initWithOptions:(NSDictionary *) options;

// New Methods

- (MKPointAnnotation *)getAnnotationByKey:(NSString *)key;
- (MKShape *)getOverlayByKey:(NSString *)key;

- (void)setZoom:(NSInteger)zoom;
- (NSInteger)zoom;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)center zoom:(NSInteger)zoom animated:(BOOL)animated;

- (GMSCircle *)getCircleByKey: (NSString *)key;
- (GMSMarker *)getMarkerByKey: (NSString *)key;
- (GMSPolygon *)getPolygonByKey: (NSString *)key;
- (GMSPolyline *)getPolylineByKey: (NSString *)key;
- (GMSTileLayer *)getTileLayerByKey: (NSString *)key;
- (GMSGroundOverlay *)getGroundOverlayByKey: (NSString *)key;
- (UIImage *)getUIImageByKey: (NSString *)key;

// Old Methods

- (void)updateMapViewLayout;

- (void)removeObjectForKey: (NSString *)key;
- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView;

- (void) didChangeActiveBuilding: (GMSIndoorBuilding *)building;
- (void) didChangeActiveLevel: (GMSIndoorLevel *)level;

@end