//
//  ViewController.h
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class HeaderView;

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>
@property(nonatomic,strong) IBOutlet UITableView * tableView;
@property(nonatomic,strong) IBOutlet MKMapView   * mapView;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;
@end
