//
//  HLDemandFloatingView.h
//  HuLianZhan
//
//  Created by Mac on 2022/7/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SYFloatingViewDelegate <NSObject>
/// 点击悬浮窗回调
- (void)floatingViewDidClickView;

@end
@interface SYFloatingView : UIView
@property (nonatomic, weak) id<SYFloatingViewDelegate> delegate;
- (void)floatingViewRoundedRect;
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<SYFloatingViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
