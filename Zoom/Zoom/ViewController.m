//
//  ViewController.m
//  Zoom
//
//  Created by 吕劲 on 2023/1/12.
//
#import "ViewController.h"
#import "ZoomView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"leaves.gif"];
    ZoomView *zoomView = [[ZoomView alloc] initWithFrame:self.view.bounds image:image];
    zoomView.maxScale = 5.0;
    [self.view addSubview:zoomView];
}


@end
