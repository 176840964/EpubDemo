//
//  ReaderBottomSettingView.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/5.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "ReaderBottomSettingView.h"

@interface ReaderBottomSettingView ()
@property (weak, nonatomic) IBOutlet UIButton *preChapterBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextChapterBtn;

@property (weak, nonatomic) IBOutlet UIButton *catalogBtn;
@property (weak, nonatomic) IBOutlet UIButton *fontBtn;
@property (weak, nonatomic) IBOutlet UIButton *brightnessBtn;
@property (weak, nonatomic) IBOutlet UIButton *pagingBtn;
@end

@implementation ReaderBottomSettingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - IBAction
- (IBAction)onTapPreChapterBtn:(id)sender {
    if ([self.delegate respondsToSelector:@selector(readerBottomSettingViewTapPreChapter:)]) {
        [self.delegate readerBottomSettingViewTapPreChapter:self];
    }
}

- (IBAction)onTapNextChapterBtn:(id)sender {
    if ([self.delegate respondsToSelector:@selector(readerBottomSettingViewTapNextChapter:)]) {
        [self.delegate readerBottomSettingViewTapNextChapter:self];
    }
}

- (IBAction)onTapCatalogBtn:(id)sender {
    if ([self.delegate respondsToSelector:@selector(readerBottomSettingViewTapCatalogBtn:)]) {
        [self.delegate readerBottomSettingViewTapCatalogBtn:self];
    }
}

- (IBAction)onTapFontBtn:(id)sender {
}

- (IBAction)onTapBrightnessBtn:(id)sender {
}

- (IBAction)onTapPagingBtn:(id)sender {
}

@end
