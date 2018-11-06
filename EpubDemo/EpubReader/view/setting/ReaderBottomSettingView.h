//
//  ReaderBottomSettingView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/5.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReaderBottomSettingView;

NS_ASSUME_NONNULL_BEGIN

@protocol ReaderBottomSettingViewDelegate <NSObject>

- (void)readerBottomSettingViewTapPreChapter:(ReaderBottomSettingView*)readerBottomSettingView;
- (void)readerBottomSettingViewTapNextChapter:(ReaderBottomSettingView*)readerBottomSettingView;
- (void)readerBottomSettingViewTapCatalogBtn:(ReaderBottomSettingView*)readerBottomSettingView;

@end

@interface ReaderBottomSettingView : UIView

@property (weak, nonatomic) id<ReaderBottomSettingViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@end

NS_ASSUME_NONNULL_END
