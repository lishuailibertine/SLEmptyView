//
//  UIScrollView+HBEmptyView.h
//  EmptyView
//
//  Created by Touker on 2018/1/3.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class HBEmptyScrollModel;
typedef NS_ENUM(NSInteger, HBEmptyViewType) {
    HBEmptyViewType_Network =1,//网络错误空白页
    HBEmptyViewType_Interface =2,//接口错误空白页
    HBEmptyViewType_Other =3//其他自定义source
};
@interface UIScrollView (HBEmptyView)
/**
 * 配置空白页类型点击空白页的任务Task
 */
- (void)configEmptyViewWithType:(HBEmptyViewType)type loadingTask:(void(^)())task;
/**
 * task结束时需要调用此方法
 * showEmptyView: task结束后，是否需要展示空白页
 */
- (void)endLoading:(BOOL)showEmptyView;

- (void)endLoading:(BOOL)showEmptyView delay:(CGFloat)delay;
/**
 * 配置空白页数据源
 * model: 配置数据的模型对象
 */
- (void)configEmptyViewWithModel:(void(^)(HBEmptyScrollModel *))model;
@end
@interface HBEmptyScrollModel :NSObject
//title描述
@property (nonatomic, strong) NSAttributedString *title;
//详细描述
@property (nonatomic, strong) NSAttributedString *subTitle;
//显示loading imageView
@property (nonatomic, strong) UIImage *loadingImage;
//image(header)
@property (nonatomic, strong) UIImage *headImage;
//loading小图标是否展示(默认为NO)
@property (nonatomic, assign) BOOL showLoadingImage;
@end

NS_ASSUME_NONNULL_END

