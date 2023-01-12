//
//  ZoomView.m
//  OpenGLLearning
//
//  Created by 吕劲 on 2023/1/11.
//

#import "ZoomView.h"

@interface ZoomView()<UIGestureRecognizerDelegate>
@property (nonatomic) UIImageView *zoomView;
@property (nonatomic) UIImage *image;
@property (nonatomic) CGFloat zoomScale;
@property (nonatomic) CGSize sourceSize;
@property (nonatomic) CGRect sourceBounds;

@end

@implementation ZoomView

- (instancetype)initWithFrame:(CGRect)frame image:(id)aImage{
    if (self = [super initWithFrame:frame]) {
        self.image = aImage;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.zoomScale = 1;
    self.sourceSize = [self rectForZoomView].size;
    self.sourceBounds = CGRectMake(0, 0, self.sourceSize.width, self.sourceSize.height);
    self.zoomView = [[UIImageView alloc] initWithFrame:[self rectForZoomView]];
    self.zoomView.image = self.image;
    self.zoomView.userInteractionEnabled = NO;
    [self addSubview:self.zoomView];
    self.backgroundColor = UIColor.blackColor;
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    panGes.maximumNumberOfTouches = 2;
    UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandle:)];
    panGes.delegate = self;
    pinchGes.delegate = self;
    [self addGestureRecognizer:panGes];
    [self addGestureRecognizer:pinchGes];
}

- (UIView *)viewForZoom {
    return self.zoomView;
}

- (CGFloat )minScale {
    return 1.0;
}

- (CGFloat )maxScale {
    if (_maxScale > 1.0) {
        return _maxScale;
    }
    return 10.0;
}

- (void)panHandle:(UIPanGestureRecognizer *)gesture {
    UIView *zoomView = [self viewForZoom];
    CGPoint trans = [gesture translationInView:self];
    zoomView.center = CGPointMake(zoomView.center.x
                                  + trans.x, zoomView.center.y + trans.y);
    [gesture setTranslation:CGPointZero inView:self];

    if (gesture.state >= UIGestureRecognizerStateEnded) {
        [self updateZoomPadding];
    }
}

- (void)pinchHandle:(UIPinchGestureRecognizer *)gesture {
    static CGPoint location;
    UIView *zoomView = [self viewForZoom];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        location = [gesture locationInView:zoomView];
        location = CGPointMake(0.5 - location.x / zoomView.bounds.size.width, 0.5 - location.y / zoomView.bounds.size.height);
    }
    CGFloat scale = gesture.scale - 1.0;
    CGPoint offset = CGPointMake(location.x * scale * zoomView.bounds.size.width, location.y * scale * zoomView.bounds.size.height);
    self.zoomScale *= gesture.scale;
    zoomView.bounds = CGRectMake(0, 0, self.sourceSize.width * self.zoomScale, self.sourceSize.height * self.zoomScale);
    zoomView.center = CGPointMake(zoomView.center.x + offset.x, zoomView.center.y + offset.y);
    [gesture setScale:1.0];
    
    if (gesture.state >= UIGestureRecognizerStateEnded) {
        [self updateZoomScaleAtLocation:location];
    }
}

///Simulate frame bounce effect 模拟反弹效果
- (void)updateZoomPadding {
    UIView *zoomView = [self viewForZoom];
    CGFloat offX = 0, offY = 0;
    UIEdgeInsets padding = [self zoomViewPadding];
    if (padding.left < 0 && padding.right < 0) {
        //dont need to process
    } else if (padding.left + padding.right < 0) {
        offX = padding.left > 0 ? -padding.left : padding.right;
    } else {
        //centerX
        offX = self.center.x - zoomView.center.x;
    }
    if (padding.top < 0 && padding.bottom < 0) {
        //dont need to process
    } else if (padding.top + padding.bottom < 0) {
        offY = padding.top > 0 ? -padding.top : padding.bottom;
    } else {
        //centerX
        offY = self.center.y - zoomView.center.y;
    }
    if (offX != 0 || offY != 0) {
        CGPoint newCenter = CGPointMake(zoomView.center.x + offX, zoomView.center.y + offY);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            zoomView.center = newCenter;
        } completion:^(BOOL finished) {

        }];
    }
}
///Simulate scale bounce effect 模拟反弹效果
- (void)updateZoomScaleAtLocation:(CGPoint)location {
    UIView *zoomView = [self zoomView];
    if (self.zoomScale < [self minScale]) {
        self.zoomScale = [self minScale];
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            zoomView.bounds = self.sourceBounds;
        } completion:^(BOOL finished) {
            
        }];
    } else if (self.zoomScale > [self maxScale]) {
        CGFloat maxScale = [self maxScale];
        CGFloat scale = maxScale/self.zoomScale - 1.0;
        self.zoomScale = maxScale;
        CGPoint offset = CGPointMake(location.x * scale * zoomView.bounds.size.width, location.y * scale * zoomView.bounds.size.height);
        CGRect newBounds = CGRectMake(0, 0, self.sourceSize.width * self.zoomScale, self.sourceSize.height * self.zoomScale);
        CGPoint newCenter = CGPointMake(zoomView.center.x + offset.x, zoomView.center.y + offset.y);
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            zoomView.bounds = newBounds;
            zoomView.center = newCenter;
        } completion:^(BOOL finished) {
            
        }];
        [self updateZoomPadding];
    }
    
}

- (UIEdgeInsets)zoomViewPadding {
    CGRect frame1 = self.bounds;
    CGRect frame2 = [self viewForZoom].frame;
    CGFloat left    = frame2.origin.x - frame1.origin.x;
    CGFloat top     = frame2.origin.y - frame1.origin.y;
    CGFloat right   = frame1.size.width - (frame2.origin.x + frame2.size.width);
    CGFloat bottom  = frame1.size.height - (frame2.origin.y + frame2.size.height);
    return UIEdgeInsetsMake(top, left, bottom, right);
}


- (CGRect)rectForZoomView {
    CGFloat width1 = self.bounds.size.width;
    CGFloat height1 = self.bounds.size.height;
    CGFloat width2 = self.image.size.width;
    CGFloat height2 = self.image.size.height;
    CGFloat asp1 = width1 / height1;
    CGFloat asp2 = width2 / height2;
    if (asp1 > asp2) {
        CGFloat width = height1 * asp2;
        return CGRectMake((width1 - width) * 0.5, 0, width, height1);
    } else {
        CGFloat height = width1 / asp2;
        return CGRectMake(0, (height1 - height) * 0.5, width1, height);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return TRUE;
}

@end
