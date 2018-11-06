//
//  ThemeSettingView.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "ThemeSettingView.h"

@implementation ThemeSettingView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds), 50);
    self.themeBtn1.tag = 0;
    self.themeBtn2.tag = 1;
    self.themeBtn3.tag = 2;
}

- (void)showingThemeSettingView:(BOOL)isShowing {
    [UIView animateWithDuration:0.25 animations:^{
        if (isShowing) {
            self.transform = CGAffineTransformMakeTranslation(0, -self.height);
        } else {
            self.transform = CGAffineTransformIdentity;
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onTapThemeBtn:(id)sender {
    UIButton *btn = sender;
    if ([self.delegate respondsToSelector:@selector(themeSettingView:themeBtnTag:)]) {
        [self.delegate themeSettingView:self themeBtnTag:btn.tag];
    }
}

@end
