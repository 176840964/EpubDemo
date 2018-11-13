//
//  EpubImagePreViewController.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/12.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubImagePreViewController.h"

@interface EpubImagePreViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation EpubImagePreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:self.imageFilePath];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = [UIScreen mainScreen].bounds;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if (image.size.height < self.imageView.height && image.size.width < self.imageView.width) {
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    [self.scrollView addSubview:self.imageView];
    
    UITapGestureRecognizer *gestureSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    gestureSingleTap.numberOfTouchesRequired = 1;
    gestureSingleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureSingleTap];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
