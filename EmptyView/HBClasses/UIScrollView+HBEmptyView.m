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
@interface UIColor (HBEmptyView)
+ (UIColor *)hb_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
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
    return @{@(HBEmptyViewType_Network):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor hb_colorWithHexString:@"#4A4A4A" alpha:1] text:@"网络不给力呀"],
             @(HBEmptyViewType_Interface):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor hb_colorWithHexString:@"#4A4A4A" alpha:1]  text:@"页面访问失败"]
             };
}
- (NSDictionary *)subtitle_data
{
    return @{@(HBEmptyViewType_Network):[self defaultTitle_emptyViewWithFontSize:12 textColor:[UIColor hb_colorWithHexString:@"#888888 " alpha:1] text:@"请检查一下网络再试试吧"],
             @(HBEmptyViewType_Interface):[self defaultTitle_emptyViewWithFontSize:12 textColor:[UIColor hb_colorWithHexString:@"#888888" alpha:1] text:@"点击重新加载再试试吧"]
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
        if ([self emptyView_subtitle]) {
            subTitleAttributedString =[self emptyView_subtitle];
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
        self.scrollEnabled = NO;
        [self addSubview:self.emptyContentView];
    }else
    {
        [self removeEmptyView];
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
    self.scrollEnabled = YES;
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
    self.tagBtn.layer.borderColor =[UIColor hb_colorWithHexString:@"#E4E4E4" alpha:1].CGColor;
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

@implementation UIColor (HBEmptyView)

+ (UIColor *)hb_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}
@end
