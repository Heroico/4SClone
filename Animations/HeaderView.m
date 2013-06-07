//
//  HeaderView.m
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import "HeaderView.h"

@interface HeaderView()
@property (nonatomic,strong) CLLocation * location;
@property (nonatomic,assign) CGPoint offset;
@end

@implementation HeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    NSLog(@"Header: %@",NSStringFromCGRect(rect));
}*/

- (void)setUserLocation:(CLLocation *)location {
    self.location = location;
    [self updateMapRegion];
}

- (void)setUserLocationViewCoordinate:(CGPoint)offset {
    self.offset = offset;
    [self updateMapRegion];
}

- (void)updateMapRegion {
    if ( !self.location )
        return;
    
    CGSize size = self.frame.size;
    CGFloat fraction = (self.offset.y-self.frame.origin.y)/size.height;
    CGFloat viewFraction = self.frame.size.height/self.frame.size.width;

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 500*viewFraction, 500);
    region.center.latitude = region.center.latitude + region.span.latitudeDelta*(fraction - 0.5);
    [self.mapView setRegion:region animated:YES];
}
@end
