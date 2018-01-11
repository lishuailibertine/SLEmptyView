# SLEmptyView
平时在业务场景中因为网络问题、接口问题导致无法正常显示页面时需要显示一个空白页面来告知用户原因。这个repository就是解决这样的问题。
# 简介
这个功能基本上是参照`DZNEmptyDataSet`思路来写的(`https://github.com/dzenbot/DZNEmptyDataSet`)。

### 适用地方
 >UITableView、UICollectionView、UIWebView等继承`UIScrollView`或与`UIScrollView`有关联的对象。

### 与`DZNEmptyDataSet`不同之处

 >hook方法的IMP指针存储方式不同(具体可见源码)；

 >布局是通过xib，这样修改起来比较容易,用纯代码的Autolayout布局也行就是太繁琐；

 >针对网络异常、接口异常会默认两种展示type(可以再新增),这样是为了对业务的定制性更高；

### API定义
```objective-c
//默认空白页类型
typedef NS_ENUM(NSInteger, HBEmptyViewType) {
    HBEmptyViewType_Network =1,//网络错误空白页
    HBEmptyViewType_Interface =2,//接口错误空白页
    HBEmptyViewType_Other =3//其他自定义source
};

/**
 * 配置空白页类型点击空白页的任务Task
 */
- (void)configEmptyViewWithType:(HBEmptyViewType)type loadingTask:(void(^)(void))task;
/**
 * 配置空白页数据源
 * model: 配置数据的模型对象
 */
- (void)configEmptyViewWithModel:(void(^)(HBEmptyScrollModel *))model;
/**
 * task结束时需要调用此方法
 * showEmptyView: task结束后，是否需要展示空白页
 */
- (void)endLoading:(BOOL)showEmptyView;

```

### 使用方法
```objecttive-c
__weak typeof(self) this =self;
//配置空白页数据源
[self.tableView configEmptyViewWithModel:^(HBEmptyScrollModel * _Nonnull model) {
      model.showLoadingImage =YES;
}];
配置空白页类型
[self.tableView configEmptyViewWithType:HBEmptyViewType_Network loadingTask:^{
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          //空白页状态更新
          [this.tableView endLoading:YES];
      });
 }];
```

### 简单效果图
![img](https://github.com/lishuailibertine/SLEmptyView/blob/master/EmptyView.gif) 