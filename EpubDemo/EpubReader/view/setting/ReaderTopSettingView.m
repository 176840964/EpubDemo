//
//  ReaderTopSettingView.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/5.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "ReaderTopSettingView.h"

@interface ReaderTopSettingView ()
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@end

@implementation ReaderTopSettingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - IBAction
- (IBAction)onTapBackBtn:(id)sender {
}

- (IBAction)onTapSearchBtn:(id)sender {
    if ([self.delegate respondsToSelector:@selector(readerTopSettingViewTapSearchHandle:)]) {
        [self.delegate readerTopSettingViewTapSearchHandle:self];
    }
}

@end
