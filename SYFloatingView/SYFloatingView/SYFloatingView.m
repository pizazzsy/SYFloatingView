//
//  HLDemandFloatingView.m
//  HuLianZhan
//
//  Created by Mac on 2022/7/1.
//

#import "SYFloatingView.h"
#import "Masonry.h"

#define Screen_Width        [UIScreen mainScreen].bounds.size.width
#define Screen_Height       [UIScreen mainScreen].bounds.size.height
#define Is_Iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Is_IPhoneX (Screen_Width >=375.0f && Screen_Height >=812.0f && Is_Iphone)
#define StatusBar_Height    (Is_IPhoneX ? (44.0):(20.0))
#define Bottom_SafeHeight   (Is_IPhoneX ? (34.0):(0))


@interface SYFloatingView()

// 记录手势开始地址
@property (nonatomic, assign) CGPoint beganPoint;
// 记录当前试图开始的FrameOrigin
@property (nonatomic, assign) CGPoint beganOrigin;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *desLabel;

@end
@implementation SYFloatingView
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<SYFloatingViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self initSubviews];
        [self activateConstraints];
        [self bindInteraction];
    }
    return self;
}
- (void)initSubviews {
    [self addSubview:self.bgView];
    [self addSubview:self.containerView];
    [self addSubview:self.imageView];
    [self addSubview:self.desLabel];
}
- (void)activateConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bgView);
        make.top.left.mas_equalTo(self.bgView).offset(8);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(15);
        make.centerX.mas_equalTo(self.containerView);
        make.width.height.mas_equalTo(20);
    }];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.mas_equalTo(self.containerView);
        make.bottom.mas_equalTo(self.containerView).offset(-5);
    }];
}
- (void)bindInteraction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:tap];
    [pan requireGestureRecognizerToFail:tap];
    [self addGestureRecognizer:pan];
}
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingViewDidClickView)]) {
        [self.delegate floatingViewDidClickView];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (!panGesture || !panGesture.view) {
        return;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            self.beganPoint = [panGesture translationInView:panGesture.view];
            self.beganOrigin = self.frame.origin;
            [self roundedRect:UIRectCornerAllCorners withCornerRatio:15 withView:self.bgView];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint point = [panGesture translationInView:panGesture.view];
            CGFloat offsetX = (point.x - _beganPoint.x);
            CGFloat offsetY = (point.y - _beganPoint.y);
            self.frame = CGRectMake(_beganOrigin.x + offsetX, _beganOrigin.y + offsetY, self.frame.size.width, self.frame.size.height);
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGFloat leftDefine = 0;
            CGRect screenrect = self.superview.bounds;
            CGFloat currentCenterX = self.frame.origin.x + self.frame.size.width / 2.0;
            CGFloat finalOriginX = (currentCenterX <= screenrect.size.width / 2.0) ? leftDefine : (screenrect.size.width - self.frame.size.width);
            CGFloat finalOriginY = self.frame.origin.y;
            
            if (self.frame.origin.y <= StatusBar_Height) {
                finalOriginY = StatusBar_Height;
            }
            
            if ((self.frame.origin.y + self.frame.size.height) >= screenrect.size.height) {
                finalOriginY = screenrect.size.height - self.frame.size.height - Bottom_SafeHeight;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                if (self) {
                    self.frame = CGRectMake(finalOriginX , finalOriginY, self.frame.size.width, self.frame.size.height);
                }
            } completion:^(BOOL finished) {
                [self floatingViewRoundedRect];
            }];
        }
            break;
        default:
            break;
    }
}
- (void)floatingViewRoundedRect {
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    if (self.frame.origin.x < Screen_Width / 2.0f) {
        corner = UIRectCornerTopRight | UIRectCornerBottomRight;
    }
    [self roundedRect:corner withCornerRatio:15 withView:self.bgView];
}
- (void)roundedRect:(UIRectCorner)corner withCornerRatio:(CGFloat)cornerRatio withView:(UIView*)changeView{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = changeView.bounds;
    maskLayer.path = maskPath.CGPath;
    changeView.layer.mask = maskLayer;
}
#pragma mark - Getter And Setter
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor grayColor];
        _bgView.alpha = 0.2;
        _bgView.layer.borderWidth = 1;
        _bgView.layer.borderColor = [UIColor clearColor].CGColor;
        _bgView.layer.masksToBounds = YES;
        _bgView.alpha = 0.2;
    }
    return _bgView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.layer.cornerRadius = 10.0f;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setImage:[UIImage imageNamed:@"help_me_history"]];
        _imageView.hidden = NO;
    }
    return _imageView;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        [_desLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_desLabel setTextColor:[UIColor blackColor]];
        _desLabel.textAlignment = NSTextAlignmentCenter;
        _desLabel.hidden = YES;
    }
    return _desLabel;
}
@end
