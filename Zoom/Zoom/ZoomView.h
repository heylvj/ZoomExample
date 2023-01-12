//
//  ZoomView.h
//  OpenGLLearning
//
//  Created by 吕劲 on 2023/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ZoomView : UIView

@property (nonatomic) CGFloat maxScale;

- (instancetype)initWithFrame:(CGRect)frame image:aImage;
@end

NS_ASSUME_NONNULL_END
