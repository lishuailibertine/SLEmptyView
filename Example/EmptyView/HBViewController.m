//
//  HBViewController.m
//  EmptyView
//
//  Created by lishuailibertine on 01/03/2018.
//  Copyright (c) 2018 lishuailibertine. All rights reserved.
//

#import "HBViewController.h"
#import "UIScrollView+HBEmptyView.h"

@interface HBViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, getter=isLoading) BOOL loading;
@end

@implementation HBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.emptyViewType =HBEmptyViewType_Network;
    [self.tableView reloadData];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)setLoading:(BOOL)loading
{
    if (self.isLoading == loading) {
        return;
    }
    _loading = loading;
    
    [self.tableView reloadData];
}
//是否显示loading动画
- (BOOL)emptyViewShouldAnimate:(UIScrollView *)scrollView
{
    return self.loading;
}
//加载按钮点击事件
- (void)emptyView:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    self.loading = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.loading = NO;
    });
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
