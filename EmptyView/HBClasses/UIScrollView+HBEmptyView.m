//
//  UIScrollView+HBEmptyView.m
//  EmptyView
//
//  Created by Touker on 2018/1/3.
//

#import "UIScrollView+HBEmptyView.h"
#import <objc/runtime.h>
//默认loading动画对应的key
#define kEmptyImageViewAnimationKey @"com.dzn.emptyDataSet.imageViewAnimation"
//关联空白页`HBEmptyContentView`对应的key
static const char * kEmptyContentView ="kEmptyContentView";
//关联空白页类型对象的key
static const char * kEmptyViewType ="kEmptyViewType";
//关联空白页数据模型key
static const char * kEmptyViewModel ="kEmptyViewModel";
//关联空白页点击执行task
static const char * kEmptyViewLoadTask ="kEmptyViewLoadTask";
@interface UIColor (HBEmptyView)
+ (UIColor *)hb_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end

@interface UIImage (HBEmptyView)
//获取image对象
+ (instancetype)hb_imagePathWithName:(NSString *)imageName targetClass:(Class)targetClass;
@end
@interface HBEmptyContentView : UIView
//空页底部view
@property (unsafe_unretained, nonatomic) IBOutlet UIView *backgroundView;
//空页头部imageview
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
//空页title描述
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
//空页subtitle描述
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *subTitleLabel;
//空页bottom按钮(默认隐藏)
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *tagBtn;
//空页手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
//空页loading小图标imageview
@property (weak, nonatomic) IBOutlet UIImageView *loadImageView;
@property (nonatomic, strong) void(^tagCallback)(id sender);

//初始化方法
+ (instancetype)createEmptyContentView:(CGRect)frame;
@end

@interface HBEmptyViewWeakObject : NSObject
//弱饮用对象（此处为代理对象）
@property (nonatomic, readonly, weak) id weakObject;
//初始化方法 (输入参数为代理对象)
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
static NSValue *_reloadDataIMP;

typedef void(^LoadTask)(void);
@interface UIScrollView (HBEmptyViewExtend)
@property (nonatomic, readwrite) HBEmptyViewType emptyViewType;
@property (nonatomic, readwrite) HBEmptyScrollModel *emptyViewModel;
@property (nonatomic, readwrite) LoadTask loadTask;
@end
@implementation UIScrollView (HBEmptyViewExtend)
- (HBEmptyViewType)emptyViewType
{
    NSNumber * emptyViewType = objc_getAssociatedObject(self, kEmptyViewType);
    return emptyViewType==nil?0:emptyViewType.intValue;
}
- (void)setEmptyViewType:(HBEmptyViewType)emptyViewType
{
    objc_setAssociatedObject(self, kEmptyViewType,@(emptyViewType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (LoadTask)loadTask
{
    return  objc_getAssociatedObject(self, kEmptyViewLoadTask);
}
- (void)setLoadTask:(LoadTask)loadTask
{
    objc_setAssociatedObject(self, kEmptyViewLoadTask,loadTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (HBEmptyScrollModel *)emptyViewModel
{
    HBEmptyScrollModel * emptyViewModel = objc_getAssociatedObject(self, kEmptyViewModel);
    if(!emptyViewModel){
        emptyViewModel =[[HBEmptyScrollModel alloc] init];
        emptyViewModel.title =[[self title_data] objectForKey:[NSNumber numberWithInt:self.emptyViewType]];
        emptyViewModel.subTitle =[[self subtitle_data] objectForKey:[NSNumber numberWithInt:self.emptyViewType]];
        emptyViewModel.headImage =[[self image_data] objectForKey:[NSNumber numberWithInt:self.emptyViewType]];
        emptyViewModel.showLoadingImage =YES;
        objc_setAssociatedObject(self, kEmptyViewModel,emptyViewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return emptyViewModel;
}
- (void)setEmptyViewModel:(HBEmptyScrollModel *)emptyViewModel
{
    objc_setAssociatedObject(self, kEmptyViewModel,emptyViewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - data 配置默认数据源
- (NSMutableDictionary *)image_data
{
    NSDictionary * imageData = @{@(HBEmptyViewType_Network):[UIImage hb_imagePathWithName:@"icon_网络不给力" targetClass:[self class]],
                                 @(HBEmptyViewType_Interface):[UIImage hb_imagePathWithName:@"icon_访问失败" targetClass:[self class]]};
    return [NSMutableDictionary dictionaryWithDictionary:imageData];
}
- (NSMutableDictionary *)title_data
{
    NSDictionary *titleData = @{@(HBEmptyViewType_Network):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor hb_colorWithHexString:@"#4A4A4A" alpha:1] text:@"网络异常，请检查网络连接"],
                                @(HBEmptyViewType_Interface):[self defaultTitle_emptyViewWithFontSize:16 textColor:[UIColor hb_colorWithHexString:@"#4A4A4A" alpha:1]  text:@"系统繁忙，请稍后再试"]
                                };
    return [NSMutableDictionary dictionaryWithDictionary:titleData];
}
- (NSMutableDictionary *)subtitle_data
{
    NSDictionary *subTitleData = @{@(HBEmptyViewType_Network):[self defaultTitle_emptyViewWithFontSize:12 textColor:[UIColor hb_colorWithHexString:@"#888888 " alpha:1] text:@"点击屏幕重新加载"],
                                   @(HBEmptyViewType_Interface):[self defaultTitle_emptyViewWithFontSize:12 textColor:[UIColor hb_colorWithHexString:@"#888888" alpha:1] text:@"点击屏幕重新加载"]
                                   };
    return [NSMutableDictionary dictionaryWithDictionary:subTitleData];
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
@end

@implementation UIScrollView (HBEmptyView)
#pragma mark -setter getter
- (HBEmptyContentView *)emptyContentView
{
    HBEmptyContentView * emptyContentView = objc_getAssociatedObject(self, kEmptyContentView);
    if (!emptyContentView) {
        emptyContentView =[HBEmptyContentView createEmptyContentView:(CGRect){0,0,self.frame.size.width,self.frame.size.height}];
        __weak typeof(self) this =self;
        emptyContentView.tagCallback = ^(id sender) {
            [this startingTask];
        };
        emptyContentView.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startingTask)];
        [emptyContentView addGestureRecognizer:emptyContentView.tapGesture];
        objc_setAssociatedObject(self, kEmptyContentView,emptyContentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return emptyContentView;
}
- (void)setEmptyContentView:(HBEmptyContentView *)emptyContentView
{
    objc_setAssociatedObject(self, kEmptyContentView,emptyContentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -public
#pragma mark - 每次刷新数据后需要调用此接口更新UI

- (void)configEmptyViewWithType:(HBEmptyViewType)type loadingTask:(void(^)())task;
{
    self.emptyViewType=type;
    self.emptyViewModel =nil;//重置模型
    if(self.emptyViewModel){
        if(task){
            self.loadTask = task;
        }
        [self hookSelector:@selector(reloadData)];
    }
}
- (void)endLoading:(BOOL)showEmptyView delay:(CGFloat)delay
{
    [self reloadEmptyView:NO];
    if(!showEmptyView){
        [self removeEmptyView:delay];
    }
}
- (void)endLoading:(BOOL)showEmptyView
{
    [self reloadEmptyView:NO];
    if(!showEmptyView){
        [self removeEmptyView:0];
    }
}
//配置模型(外部)
- (void)configEmptyViewWithModel:(void(^)(HBEmptyScrollModel *))model
{
    self.emptyViewModel =nil;//重置模型
    if(self.emptyViewModel){
        if(model){
            model(self.emptyViewModel);
        }
        [self hookSelector:@selector(reloadData)];
    }
}
#pragma mark - private
#pragma mark -执行loading时的Task
- (void)reloadEmptyView:(BOOL)animation
{
    if (![self haveIterm]){
        self.emptyContentView.imageView.image =self.emptyViewModel.headImage;
        self.emptyContentView.loadImageView.image =[UIImage hb_imagePathWithName:@"loading_image" targetClass:[self class]];
        self.emptyContentView.titleLabel.attributedText =self.emptyViewModel.title;
        self.emptyContentView.subTitleLabel.attributedText =self.emptyViewModel.subTitle;
        if(self.emptyViewModel.showLoadingImage){
            self.emptyContentView.loadImageView.hidden =NO;
            animation?[self.emptyContentView.loadImageView.layer addAnimation:[self imageAnimationForEmptyDataSet:self] forKey:kEmptyImageViewAnimationKey]:[self.emptyContentView.loadImageView.layer removeAnimationForKey:kEmptyImageViewAnimationKey];
        }else{
            self.emptyContentView.loadImageView.hidden =YES;
        }
        self.scrollEnabled = NO;
        [self addSubview:self.emptyContentView];
    }
}
- (void)removeEmptyView:(CGFloat)delay
{
    [UIView animateWithDuration:0 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        
    } completion:^(BOOL finished) {
        [self.emptyContentView removeFromSuperview];
        self.scrollEnabled = YES;
    }];
}
- (void)startingTask
{
    [self reloadEmptyView:YES];
    if(self.loadTask){
        self.loadTask();
    }
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
//loading图标动画
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
#pragma mark -(只在设置代理的时候采取hook)
- (void)hookSelector:(SEL)selector
{
    if (![self respondsToSelector:selector]) {
        return;
    }
    //如果hook过的不需要再hook
    if (_reloadDataIMP) {
        return;
    }
    Method method = class_getInstanceMethod([self class], selector);
    IMP dzn_newImplementation = method_setImplementation(method, (IMP)originalImplementation);
    NSValue *impValue =[NSValue valueWithPointer:dzn_newImplementation];
    _reloadDataIMP = impValue;
}
void originalImplementation(id self, SEL _cmd)
{
    IMP impPointer = [_reloadDataIMP pointerValue];
    [self reloadEmptyView:NO];
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
@implementation HBEmptyScrollModel
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
