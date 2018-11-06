//
//  FontSettingView.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "FontSettingView.h"

@implementation FontSettingView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds), 150);
}

- (void)showingFontSettingView:(BOOL)isShowing {
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


#pragma mark - IBAction
- (IBAction)onTapSizeReduce:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fontSettingViewReduceSize:)]) {
        [self.delegate fontSettingViewReduceSize:self];
    }
}

- (IBAction)onTapSizeIncrease:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fontSettingViewIncreaseSize:)]) {
        [self.delegate fontSettingViewIncreaseSize:self];
    }
}

- (IBAction)onTapFont1:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fontSettingView:selectFontWithIndex:)]) {
        [self.delegate fontSettingView:self selectFontWithIndex:1];
    }
}

- (IBAction)onTapFont2:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fontSettingView:selectFontWithIndex:)]) {
        [self.delegate fontSettingView:self selectFontWithIndex:2];
    }
}

- (IBAction)onTapMinSpacing:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fontSettingView:selectSpacingWithIndex:)]) {
        [self.delegate fontSettingView:self selectSpacingWithIndex:1];
    }
}

- (IBAction)onTapNormalSpacing:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fontSettingView:selectSpacingWithIndex:)]) {
        [self.delegate fontSettingView:self selectSpacingWithIndex:2];
    }
}

- (IBAction)onTapMaxSpacing:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fontSettingView:selectSpacingWithIndex:)]) {
        [self.delegate fontSettingView:self selectSpacingWithIndex:3];
    }
}

@end
