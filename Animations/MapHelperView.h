//
//  HeaderView.h
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapHelperView : UIView<MKMapViewDelegate>
@property(nonatomic,strong)IBOutlet MKMapView * mapView;
- (void)setUserLocation:(CLLocation*)location animated:(BOOL)animated;
- (void)setUserLocationViewCoordinate:(CGPoint)offset animated:(BOOL)animated;
@end
