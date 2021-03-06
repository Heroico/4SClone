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
#import "ItemCell.h"
#import "TopCell.h"
#import "TableHeaderView.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer; //build it 
@property (nonatomic,strong) NSMutableArray * items;
@property (nonatomic,assign) NSInteger generatedItems;
@property (nonatomic,strong) CLLocationManager * locationManager;
@property (nonatomic,assign) BOOL mapModeOn;
@end

@implementation ViewController

static NSString * const kTopCellIdentifier = @"TopCellIdentifier";
static NSString * const kItemCellIdentifier = @"ItemCellIdentifier";

static const CGFloat kInitialVisibleMapHeight = 150.0;
static const CGFloat kHelpViewInitialTop = -100.0;
static const CGFloat kTableViewInitialTop = 0;
static const CGFloat kMapModeCellMargin = 22;
static const CGFloat kBackgroundOffset  = 16;
static const CGFloat kMapModeTop = 0;

static const CGFloat kTopCellHeight  = 60.0;
static const CGFloat kItemCellHeight = 70.0;

static const CGFloat kMapModePanThreshold = 40.0;
static const CGFloat kMapModePanMultiplier = 6.0;

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
    
    self.helperViewHeightConstraint.constant = self.view.frame.size.height+fabs(kHelpViewInitialTop);
    self.tableViewHeightConstraint.constant = self.view.frame.size.height;
    
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
    CGPoint point = scrollView.contentOffset;
    if (point.y <= 0) {
        self.tableBackgroundViewTop.constant = kInitialVisibleMapHeight + kBackgroundOffset - point.y;
        [self.view layoutIfNeeded];
    }
}

- (void)updateHeaderMap:(BOOL)animated {
    CGPoint userCoordinateInView = CGPointZero;
    userCoordinateInView.y = round(-self.mapHelperView.frame.origin.y+0.5*self.tableView.frame.origin.y);
    [self.mapHelperView setUserLocationViewCoordinate:userCoordinateInView animated:animated];
}

- (void)setMapMode:(BOOL)mapMode {
    [self setMapMode:mapMode withTraslate:0];
}

- (void)setMapMode:(BOOL)mapMode withTraslate:(CGFloat)traslate {
    
    [self toggleFlagsForMapMode:mapMode];
    // First remove/add header view from table, then animate map movement
    if (self.mapModeOn) {
        [self setViewsForMapMode];
    } else {
        [self setViewsForInitialModeWithTraslate:traslate];
    }

    // no animation has far better performance
    [self updateHeaderMap:YES];
}

#pragma mark - private methods

- (void)toggleFlagsForMapMode:(BOOL)mapMode {
    self.mapModeOn = mapMode;
    self.panGestureRecognizer.enabled = self.mapModeOn;
    self.tableView.scrollEnabled = !self.mapModeOn;
    self.tableView.allowsSelection = !self.mapModeOn;
    self.mapHelperView.mapView.userInteractionEnabled = self.mapModeOn;
    self.mapHelperView.mapView.zoomEnabled = self.mapModeOn;
    self.mapHelperView.mapView.scrollEnabled = self.mapModeOn;
    
    self.theButton.userInteractionEnabled = NO;
    self.theButton.hidden = self.mapModeOn;
    
    self.navigationItem.rightBarButtonItem.enabled = self.mapModeOn;
}

- (void)setViewsForInitialModeWithTraslate:(CGFloat)traslate {
    [self.locationManager startUpdatingLocation];
    CGFloat height = self.view.frame.size.height;
    self.tableView.tableHeaderView = (UIView *)self.tableHeaderView;
    self.tableViewTopConstraint.constant = height-kInitialVisibleMapHeight-kMapModeCellMargin-traslate;
    self.tableBackgroundViewTop.constant = self.tableViewTopConstraint.constant+kInitialVisibleMapHeight+kBackgroundOffset;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableViewTopConstraint.constant = kTableViewInitialTop;
        self.tableBackgroundViewTop.constant = kInitialVisibleMapHeight+kBackgroundOffset;
        self.helperViewTopConstraint.constant = kHelpViewInitialTop;
        [self.view layoutIfNeeded];
    }];
}

- (void)setViewsForMapMode {
    [self.locationManager stopUpdatingLocation];
    self.tableView.tableHeaderView = nil;
    self.tableViewTopConstraint.constant = kInitialVisibleMapHeight;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat height = self.view.frame.size.height;
        self.tableViewTopConstraint.constant = height-kMapModeCellMargin;
        self.tableBackgroundViewTop.constant = self.tableViewTopConstraint.constant+kBackgroundOffset;
        self.helperViewTopConstraint.constant = 0;

        [self.view layoutIfNeeded];
        
    }];
}

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
    [self.mapHelperView setUserLocation:location animated:YES];
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
    UITableViewCell *cell = nil;
    if (indexPath.row) {
        ItemCell *itemCell = [tableView dequeueReusableCellWithIdentifier:kItemCellIdentifier];
        itemCell.titleLabel.text = item.title;
        itemCell.subtitleLable.text = item.subtitle;
        cell = itemCell;
    } else {
        TopCell *topCell = [tableView dequeueReusableCellWithIdentifier:kTopCellIdentifier];
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [topCell.headerView addGestureRecognizer:self.panGestureRecognizer];
        cell = topCell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = indexPath.row == 0 ? kTopCellHeight : kItemCellHeight;
    return height;
}

#pragma mark - Event handling

- (IBAction)closeMapView:(UIBarButtonItem *)sender {
    [self setMapMode:NO];
}

- (IBAction)enableMapMode:(id)sender {
    if ( !self.mapModeOn )
        [self setMapMode:YES];
}

- (void)panGesture:(UIPanGestureRecognizer*)panRecognizer {
    if (!self.mapModeOn) {
        return;
    }
    
    CGPoint pan = [panRecognizer translationInView:self.tableHeaderView];
    if ( pan.y >0 ) {
        return;
    }
    
    CGFloat traslate = round(kMapModePanMultiplier*sqrt(fabs(pan.y)));
    NSLog(@"%@",NSStringFromCGPoint(pan));
    if (panRecognizer.state == UIGestureRecognizerStateBegan || panRecognizer.state == UIGestureRecognizerStateChanged) {
        if (panRecognizer.state == UIGestureRecognizerStateBegan) {
            NSLog(@"Pan began");
        }
        CGFloat height = self.view.frame.size.height;
        self.tableViewTopConstraint.constant = height-kMapModeCellMargin - traslate;
        self.tableBackgroundViewTop.constant = self.tableViewTopConstraint.constant+kBackgroundOffset;
        self.helperViewTopConstraint.constant = - traslate/2;
        [self.view layoutIfNeeded];
    } else {

        NSLog(@"Pan end");

        if (pan.y < -kMapModePanThreshold) {
            [self setMapMode:NO withTraslate:traslate];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                CGFloat height = self.view.frame.size.height;
                self.tableViewTopConstraint.constant = height-kMapModeCellMargin;
                self.tableBackgroundViewTop.constant = self.tableViewTopConstraint.constant+kBackgroundOffset;
                self.helperViewTopConstraint.constant = 0;
                [self.view layoutIfNeeded];
            }];
        }
    }
}

@end
