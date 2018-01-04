//
//  UIScrollView+HBEmptyView.m
//  EmptyView
//
//  Created by Touker on 2018/1/3.
//

#import "UIScrollView+HBEmptyView.h"
#import <objc/runtime.h>
#define kEmptyImageViewAnimationKey @"com.dzn.emptyDataSet.imageViewAnimation"
static const char * kEmptyDataSource ="kEmptyDataSource";
static const char * kEmptyDataDelegate ="kEmptyDataDelegate";
static const char * kEmptyReloadDataIMP ="kEmptyReloadDataIMP";
static const char * kEmptyContentView ="kEmptyContentView";
static const char * kEmptyViewType ="kEmptyViewType";
@interface UIImage (HBEmptyView)
+ (instancetype)hb_imagePathWithName:(NSString *)imageName targetClass:(Class)targetClass;
@end
@interface HBEmptyContentView : UIView
@property (unsafe_unretained, nonatomic) IBOutlet UIView *backgroundView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *tagBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHightConstraint;
@property (nonatomic, strong) void(^tagCallback)(id sender);

+ (instancetype)createEmptyContentView:(CGRect)frame;
@end

@interface HBEmptyViewWeakObject : NSObject
@property (nonatomic, readonly, weak) id weakObject;
- (instancetype)initWithWeakObject:(id)object;
@end
@implementation HBEmptyViewWeakObject
- (instancetype)initWithWeakObject:(id)object
{
    self = [super init];
    if (self) {
        _weakObject = object;
    }
    return self;
}
@end
@implementation UIScrollView (HBEmptyView)
#pragma mark -setter getter
- (HBEmptyViewType)emptyViewType
{
    NSNumber * emptyViewType = objc_getAssociatedObject(self, kEmptyViewType);
    return emptyViewType==nil?0:emptyViewType.intValue;
}
- (void)setEmptyViewType:(HBEmptyViewType)emptyViewType
{
    objc_setAssociatedObject(self, kEmptyViewType,@(emptyViewType), OBJC_ASSOCIATION_ASSIGN);
}
- (id<HBEmptyDataSource>)emptyDataSource
{
    HBEmptyViewWeakObject * emptyViewWeakObject = objc_getAssociatedObject(self, kEmptyDataSource);
    return  emptyViewWeakObject.weakObject;
}
- (void)setEmptyDataSource:(id<HBEmptyDataSource>)emptyDataSource
{
    [self hookSelector:@selector(reloadData)];
    objc_setAssociatedObject(self, kEmptyDataSource,[[HBEmptyViewWeakObject alloc] initWithWeakObject:emptyDataSource], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id<HBEmptyDataDelegate>)emptyDataDelegate
{
    HBEmptyViewWeakObject * emptyViewWeakObject = objc_getAssociatedObject(self, kEmptyDataDelegate);
    return  emptyViewWeakObject.weakObject;
}
- (void)setEmptyDataDelegate:(id<HBEmptyDataDelegate>)emptyDataDelegate
{
    [self hookSelector:@selector(reloadData)];
    objc_setAssociatedObject(self, kEmptyDataDelegate,[[HBEmptyViewWeakObject alloc] initWithWeakObject:emptyDataDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (HBEmptyContentView *)emptyContentView
{
    HBEmptyContentView * emptyContentView = objc_getAssociatedObject(self, kEmptyContentView);
    if (!emptyContentView) {
        emptyContentView =[HBEmptyContentView createEmptyContentView:(CGRect){0,0,self.frame.size.width,self.frame.size.height}];
        __weak typeof(self) this =self;
        emptyContentView.tagCallback = ^(id sender) {
            [this emptyView_didTapButton:sender];
        };
        objc_setAssociatedObject(self, kEmptyContentView,emptyContentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return emptyContentView;
}
- (void)setEmptyContentView:(HBEmptyContentView *)emptyContentView
{
    objc_setAssociatedObject(self, kEmptyContentView,emptyContentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark -public
#pragma mark - data
- (NSDictionary *)image_data
{
    return @{@(HBEmptyViewType_Network):[UIImage hb_imagePathWithName:@"icon_网络不给力" targetClass:[self class]],
             @(HBEmptyViewType_Interface):[UIImage hb_imagePathWithName:@"icon_访问失败" targetClass:[self class]]};
}
- (NSDictionary *)title_data
{
    return @{@(HBEmptyViewType_Network):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor blackColor] text:@"网络不给力呀"],
             @(HBEmptyViewType_Interface):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor blackColor] text:@"页面访问失败"]
             };
}
- (NSDictionary *)subtitle_data
{
    return @{@(HBEmptyViewType_Network):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor blackColor] text:@"请检查一下网络再试试吧"],
             @(HBEmptyViewType_Interface):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor blackColor] text:@"点击重新加载再试试吧"]
             };
}
- (void)reloadEmptyView
{
    if ([self emptyView_shouldDisplay]&&![self haveIterm]){
        UIImage * image;
        if ([self emptyView_image]) {
            image=[self emptyView_image];
        }else{
            image=[[self image_data] objectForKey:[NSNumber numberWithInt:self.emptyViewType]];
        }
        NSAttributedString *titleAttributedString;
        if ([self emptyView_title]) {
            titleAttributedString =[self emptyView_title];
        }else{
            titleAttributedString =[[self title_data] objectForKey:[NSNumber numberWithInt:self.emptyViewType]];
        }
        NSAttributedString *subTitleAttributedString;
        if ([self emptyView_title]) {
            subTitleAttributedString =[self emptyView_title];
        }else{
            subTitleAttributedString =[[self subtitle_data] objectForKey:[NSNumber numberWithInt:self.emptyViewType]];
        }
        self.emptyContentView.imageView.image =image;
        self.emptyContentView.titleLabel.attributedText =titleAttributedString;
        self.emptyContentView.subTitleLabel.attributedText =subTitleAttributedString;
        if ([self emptyView_loading]) {
            self.emptyContentView.imageWightConstraint.constant =78;
            self.emptyContentView.imageHightConstraint.constant =78;
        }else{
            self.emptyContentView.imageWightConstraint.constant =150;
            self.emptyContentView.imageHightConstraint.constant =150;
        }
        if ([self emptyView_loading]) {
            self.emptyContentView.imageView.image =[UIImage hb_imagePathWithName:@"loading_imgBlue_78x78" targetClass:[self class]];
            [self.emptyContentView.imageView.layer addAnimation:[self imageAnimationForEmptyDataSet:self] forKey:kEmptyImageViewAnimationKey];
        }else{
            [self.emptyContentView.imageView.layer removeAnimationForKey:kEmptyImageViewAnimationKey];
            self.emptyContentView.imageView.image =image;
        }
        [self addSubview:self.emptyContentView];
    }
}
- (NSAttributedString *)defaultTitle_emptyViewWithFontSize:(int)size
                                                 textColor:(UIColor *)textColor
                                                      text:(NSString *)text
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    UIFont *font =[UIFont systemFontOfSize:size];
    UIColor *textcolor = textColor;
    NSString *txt =text;
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textcolor forKey:NSForegroundColorAttributeName];
    return [[NSAttributedString alloc] initWithString:txt attributes:attributes];;
}
- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    return animation;
}
- (void)removeEmptyView
{
    [self.emptyContentView removeFromSuperview];
}
#pragma mark -private
#pragma mark - Delegate Getters & Events
- (BOOL)emptyView_shouldDisplay
{
    if (self.emptyDataDelegate && [self.emptyDataDelegate respondsToSelector:@selector(emptyViewShouldDisplay:)]) {
        return [self.emptyDataDelegate emptyViewShouldDisplay:self];
    }
    return YES;
}
- (BOOL)emptyView_loading
{
    if (self.emptyDataDelegate && [self.emptyDataDelegate respondsToSelector:@selector(emptyViewShouldAnimate:)]) {
        return [self.emptyDataDelegate emptyViewShouldAnimate:self];
    }
    return NO;
}
- (void)emptyView_didTapButton:(id)sender
{
    if (self.emptyDataDelegate && [self.emptyDataDelegate respondsToSelector:@selector(emptyView:didTapButton:)]) {
       [self.emptyDataDelegate emptyView:self didTapButton:sender];
    }
}
- (UIImage *)emptyView_image
{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(imageForEmptyView:)]) {
        return [self.emptyDataSource imageForEmptyView:self];
    }
    return nil;
}
- (NSAttributedString *)emptyView_title
{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(titleForEmptyView:)]) {
        return [self.emptyDataSource titleForEmptyView:self];
    }
    return nil;
}
- (NSAttributedString *)emptyView_subtitle
{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(subTitleForEmptyView:)]) {
       return [self.emptyDataSource subTitleForEmptyView:self];
    }
    return nil;
}
#pragma mark -iterms count
- (BOOL)haveIterm
{
    BOOL have =NO;
    if (![self respondsToSelector:@selector(dataSource)]) {
        return have;
    }
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        NSInteger sections = 1;
        NSInteger items = 0;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
                if (items>0) {
                    have =YES;
                    break;
                }
            }
        }
    }
    if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        NSInteger sections = 1;
        NSInteger items = 0;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
                if (items>0) {
                    have =YES;
                    break;
                }
            }
        }
    }
    return have;
}
#pragma mark -(只在设置代理的时候采取hook)
- (void)hookSelector:(SEL)selector
{
    if (![self respondsToSelector:selector]) {
        return;
    }
    //如果hook过的不需要再hook(method_setImplementation)
    if (objc_getAssociatedObject(self, kEmptyReloadDataIMP)) {
        return;
    }
    Method method = class_getInstanceMethod([self class], selector);
    IMP dzn_newImplementation = method_setImplementation(method, (IMP)originalImplementation);
    NSValue *impValue =[NSValue valueWithPointer:dzn_newImplementation];
    objc_setAssociatedObject(self, kEmptyReloadDataIMP,impValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
void originalImplementation(id self, SEL _cmd)
{
    NSValue * impValue = objc_getAssociatedObject(self, kEmptyReloadDataIMP);
    IMP impPointer = [impValue pointerValue];
    [self reloadEmptyView];
    if (impPointer) {
        ((void(*)(id,SEL))impPointer)(self,_cmd);
    }
}
@end
@implementation HBEmptyContentView
+ (instancetype)createEmptyContentView:(CGRect)frame
{
    HBEmptyContentView * contentView;
    NSBundle * xibBundle =[NSBundle bundleForClass:[self class]];
    for (id nibView in [xibBundle loadNibNamed:NSStringFromClass(self) owner:self options:nil]) {
        if ([nibView isKindOfClass:[self class]]) {
            contentView =nibView;
            break;
        }
    }
    contentView.frame =frame;
    return contentView;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.tagBtn.layer.cornerRadius =4.f;
    self.tagBtn.layer.borderWidth =.5f;
    self.tagBtn.layer.borderColor =[UIColor blackColor].CGColor;
}
- (IBAction)tagEvent:(id)sender {
    if (self.tagCallback) {
        self.tagCallback(sender);
    }
}
@end
@implementation UIImage (HBEmptyView)

+ (instancetype)hb_imagePathWithName:(NSString *)imageName targetClass:(Class)targetClass {
    
    NSInteger scale = [[UIScreen mainScreen] scale];
    NSBundle *currentBundle = [NSBundle bundleForClass:[HBEmptyContentView class]];
    NSString *name = [NSString stringWithFormat:@"%@@%zdx",imageName,scale];
    NSString *path = [currentBundle pathForResource:name ofType:@"png" inDirectory:nil];
    return path ? [UIImage imageWithContentsOfFile:path] : nil;
}
@end

