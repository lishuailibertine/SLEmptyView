//
//  HBViewController.m
//  EmptyView
//
//  Created by lishuailibertine on 01/03/2018.
//  Copyright (c) 2018 lishuailibertine. All rights reserved.
//

#import "HBViewController.h"
#import "UIScrollView+HBEmptyView.h"
#import <objc/runtime.h>
@interface HBViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak typeof(self) this =self;
    //配置空白页数据源
    [self.tableView configEmptyViewWithModel:^(HBEmptyScrollModel * _Nonnull model) {
        model.showLoadingImage =YES;
    }];
    //配置空白页类型
    [self.tableView configEmptyViewWithType:HBEmptyViewType_Network loadingTask:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //空白页状态更新
            [this.tableView endLoading:YES];
        });
    }];
	// Do any additional setup after loading the view, typically from a nib.
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
