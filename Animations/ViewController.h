//
//  ViewController.h
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapHelperView;

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet MapHelperView *mapHelperView;
@property (weak, nonatomic) IBOutlet UIButton *theButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *helperViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *helperViewTopConstraint;

- (IBAction)closeMapView:(UIBarButtonItem *)sender;
- (IBAction)enableMapMode:(id)sender;

@end
