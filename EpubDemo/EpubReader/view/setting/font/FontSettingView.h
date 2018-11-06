//
//  FontSettingView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FontSettingView;

NS_ASSUME_NONNULL_BEGIN

@protocol FontSettingViewDelegate <NSObject>

- (void)fontSettingViewReduceSize:(FontSettingView*)fontSettingView;
- (void)fontSettingViewIncreaseSize:(FontSettingView*)fontSettingView;
- (void)fontSettingView:(FontSettingView*)fontSettingView selectFontWithIndex:(NSInteger)index;
- (void)fontSettingView:(FontSettingView *)fontSettingView selectSpacingWithIndex:(NSInteger)index;

@end

@interface FontSettingView : UIView
@property (weak, nonatomic) IBOutlet UIButton *sizeReduce;
@property (weak, nonatomic) IBOutlet UIButton *sizeIncrease;

@property (weak, nonatomic) IBOutlet UIButton *font1;
@property (weak, nonatomic) IBOutlet UIButton *font2;

@property (weak, nonatomic) IBOutlet UIButton *spacingMin;
@property (weak, nonatomic) IBOutlet UIButton *spacingNormal;
@property (weak, nonatomic) IBOutlet UIButton *spacingMax;

@property (weak, nonatomic) id<FontSettingViewDelegate> delegate;

- (void)showingFontSettingView:(BOOL)isShowing;

@end

NS_ASSUME_NONNULL_END
