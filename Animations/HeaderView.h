//
//  HeaderView.h
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HeaderView : UIView
@property(nonatomic,strong)IBOutlet MKMapView * mapView;
- (void)setUserLocation:(CLLocation*)location;
- (void)setUserLocationViewCoordinate:(CGPoint)offset;
@end
