//
//  PolylineOverlay.h
//  googlemaps-applemaps
//
//  Created by James Mattis on 6/10/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PolylineOverlay : MKPolyline

@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGFloat strokeWidth;

@end
