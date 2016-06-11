//
//  External.h
//  SimpleMap
//
//  Created by Masashi Katsumata on 11/19/13.
//
//

#import "GoogleMaps.h"
#import "MyPlgunProtocol.h"

#import <MapKit/MapKit.h>

@interface External : CDVPlugin

-(void)launchNavigation:(CDVInvokedUrlCommand *)command;

@end
