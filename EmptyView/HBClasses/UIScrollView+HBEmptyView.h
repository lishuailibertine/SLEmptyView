//
//  UIScrollView+HBEmptyView.h
//  EmptyView
//
//  Created by Touker on 2018/1/3.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol HBEmptyDataSource;
@protocol HBEmptyDataDelegate;

typedef NS_ENUM(NSInteger, HBEmptyViewType) {
    HBEmptyViewType_Network =1,//网络错误空白页
    HBEmptyViewType_Interface =2//接口错误空白页
};
@interface UIScrollView (HBEmptyView)
@property (nonatomic, weak, nullable) IBOutlet id <HBEmptyDataSource> emptyDataSource;
@property (nonatomic, weak, nullable) IBOutlet id <HBEmptyDataDelegate> emptyDataDelegate;
@property (nonatomic, assign) HBEmptyViewType emptyViewType;
//每次请求完接口再调用这个接口
- (void)reloadEmptyView;
@end

@protocol HBEmptyDataSource <NSObject>

//image(header)
- (UIImage *)imageForEmptyView:(UIScrollView *)scrollView;
//title描述
- (NSAttributedString *)titleForEmptyView:(UIScrollView *)scrollView;
//详细描述
- (NSAttributedString *)subTitleForEmptyView:(UIScrollView *)scrollView;
@end
@protocol HBEmptyDataDelegate <NSObject>

//加载按钮点击事件
- (void)emptyView:(UIScrollView *)scrollView didTapButton:(UIButton *)button;
//是否需要展示空白页
- (BOOL)emptyViewShouldDisplay:(UIScrollView *)scrollView;
//是否显示loading动画
- (BOOL)emptyViewShouldAnimate:(UIScrollView *)scrollView;
@end

NS_ASSUME_NONNULL_END
