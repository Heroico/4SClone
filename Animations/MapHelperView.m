//
//  HeaderView.m
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import "MapHelperView.h"

@interface MapHelperView()
@property (nonatomic,strong) CLLocation * location;
@property (nonatomic,assign) CGPoint offset;
@end

@implementation MapHelperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUserLocation:(CLLocation *)location animated:(BOOL)animated {
    self.location = location;
    [self updateMapRegion:animated];
}

- (void)setUserLocationViewCoordinate:(CGPoint)offset animated:(BOOL)animated {
    self.offset = offset;
    [self updateMapRegion:animated];
}

- (void)updateMapRegion:(BOOL)animated {
    if ( !self.location )
        return;
    
    CGSize size = self.frame.size;
    CGFloat fraction = (self.offset.y-self.frame.origin.y)/size.height;
    double viewFraction = self.frame.size.height/self.frame.size.width;

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 500*viewFraction, 500);
    region.center.latitude = region.center.latitude + region.span.latitudeDelta*(fraction - 0.5);
    [self.mapView setRegion:region animated:animated];
    //NSLog(@"location (%f,%f)", region.center.latitude,region.center.longitude);
}

#pragma mark - map delegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
}
@end
