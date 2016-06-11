//
//  MarkerAnnotation.h
//  googlemaps-applemaps
//
//  Created by James Mattis on 6/9/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MarkerAnnotation : MKPointAnnotation

@property (strong, nonatomic) NSString *iconURL;

@property (assign, nonatomic) CGFloat iconWidth;
@property (assign, nonatomic) CGFloat iconHeight;

@property (assign, nonatomic) BOOL draggable;
@property (assign, nonatomic) BOOL showCallout;

@end
