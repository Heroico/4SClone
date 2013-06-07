//
//  ViewController.m
//  Animations
//
//  Created by Alvaro Barbeira on 6/7/13.
//  Copyright (c) 2013 Alvaro Barbeira. All rights reserved.
//

#import "ViewController.h"
#import "Item.h"
#import <SVPullToRefresh/SVPullToRefresh.h>

@interface ViewController ()
@property (nonatomic,strong) NSMutableArray * items;
@property (nonatomic,assign) NSInteger generatedItems;
@end

@implementation ViewController

static NSString * const kCellIdentifier = @"CellIdentifier";

- (void)viewDidLoad
{
    self.items = [NSMutableArray array];
    self.generatedItems = 0;
    
    for ( NSInteger i=0; i<10; i++ ) {
        Item * item = [[Item alloc] init];
        item.title = [NSString stringWithFormat:@"Item %d",rand()];
        item.subtitle = i%2 ? @"Something" : @"Or not";
        [self.items addObject:item];
    }
    
    __weak ViewController * weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf infiniteScrolling];
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
    NSInteger count = rand()%2+1;
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

@end
