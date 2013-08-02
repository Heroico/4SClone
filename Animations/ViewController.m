//
//  ViewController.m
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import "ViewController.h"
#import "Item.h"
#import "MapHelperView.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic,strong) NSMutableArray * items;
@property (nonatomic,assign) NSInteger generatedItems;
@property (nonatomic,strong) CLLocationManager * locationManager;
@property (nonatomic,assign) BOOL mapModeOn;
@end

@implementation ViewController

static NSString * const kCellIdentifier = @"CellIdentifier";

static const CGFloat kInitialVisibleMapHeight = 100.0;
static const CGFloat kHelpViewInitialTop = -100.0;
static const CGFloat kTableViewInitialTop = 0;
static const CGFloat kMapModeTop = 0;

- (void)viewDidLoad
{
    self.items = [NSMutableArray array];
    self.generatedItems = 0;
    
    for ( NSInteger i=0; i<10; i++ ) {
        Item * item = [[Item alloc] init];
        item.subtitle = [NSString stringWithFormat:@"Item %d",rand()];
        item.title = [NSString stringWithFormat:@"Item %d",i];
        [self.items addObject:item];
    }
    
    __weak ViewController * weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf infiniteScrolling];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setMapMode:NO];
    if (!self.locationManager ) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updateHeaderMap:NO];
    });

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.locationManager = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //We must queue them or something
    //[self updateHeaderMap:NO];
}

- (void)updateHeaderMap:(BOOL) animated {
    CGPoint userCoordinateInView = CGPointZero;
    userCoordinateInView.y += round(self.mapHelperView.frame.size.height*0.5+0.5*fabs(self.tableView.frame.origin.y) + self.tableView.contentOffset.y*0.5);
    [self.mapHelperView setUserLocationViewCoordinate:userCoordinateInView animated:animated];
}

- (void)setMapMode:(BOOL)mapMode {
    self.mapModeOn = mapMode;
    self.mapHelperView.mapView.userInteractionEnabled = self.mapModeOn;
    self.mapHelperView.mapView.zoomEnabled = self.mapModeOn;
    self.mapHelperView.mapView.scrollEnabled = self.mapModeOn;
    
    self.theButton.userInteractionEnabled = NO;
    self.theButton.hidden = self.mapModeOn;
    
    self.navigationItem.rightBarButtonItem.enabled = self.mapModeOn;

    [UIView animateWithDuration:0.5 animations:^{
        if (self.mapModeOn) {
            CGFloat height = self.view.frame.size.height;
            self.tableViewTopConstraint.constant = height-20; //"20" will change soon 
            self.helperViewTopConstraint.constant = 0;
        } else {
            self.tableViewTopConstraint.constant = kTableViewInitialTop;
            self.helperViewTopConstraint.constant = kHelpViewInitialTop;
        }

        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {
        if ( finished )
            [self updateHeaderMap:YES];
    }];
}

#pragma mark - private methods

- (void) infiniteScrolling {

    
    __weak ViewController *weakSelf = self;
    
    int64_t delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        

        [weakSelf.tableView beginUpdates];
        NSInteger originalCount = weakSelf.items.count;
        NSMutableArray * newItems = [weakSelf randomItems];
        [weakSelf.items addObjectsFromArray:newItems];
        
        NSMutableArray * insertPaths = [[NSMutableArray alloc] initWithCapacity:newItems.count];
        for (NSInteger i=0; i<newItems.count; i++) {
            [insertPaths addObject:[NSIndexPath indexPathForRow:(originalCount+i) inSection:0]];
        }
        [weakSelf.tableView insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationTop];
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
        
        [weakSelf.tableView endUpdates];
    });

}

- (NSMutableArray*) randomItems {
    NSInteger count = rand()%4+1;
    NSMutableArray * randomItems = [[NSMutableArray alloc] initWithCapacity:count];
    for ( NSInteger i=0; i<count; i++ ) {
        Item * item = [[Item alloc] init];
        item.title = [NSString stringWithFormat:@"Item %d",rand()];
        self.generatedItems++;
        item.subtitle = [NSString stringWithFormat:@"Generated %d",self.generatedItems];
        [randomItems addObject:item];
    }
    return randomItems;
}

#pragma mark - CLLocationManager methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation * location = [locations lastObject];
    [self.mapHelperView setUserLocation:location animated:NO];
}

#pragma mark - TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Item * item = [self.items objectAtIndex:indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.subtitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (IBAction)closeMapView:(UIBarButtonItem *)sender {
    [self setMapMode:NO];
}

- (IBAction)enableMapMode:(id)sender {
    if ( !self.mapModeOn )
        [self setMapMode:YES];
}
@end
