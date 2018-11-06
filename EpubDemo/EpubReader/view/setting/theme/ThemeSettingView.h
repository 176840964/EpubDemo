//
//  ThemeSettingView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThemeSettingView;

NS_ASSUME_NONNULL_BEGIN

@protocol ThemeSettingViewDelegate <NSObject>

- (void)themeSettingView:(ThemeSettingView*)themeSettingView themeBtnTag:(NSInteger)tag;

@end

@interface ThemeSettingView : UIView
@property (weak, nonatomic) IBOutlet UIButton *themeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *themeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *themeBtn3;

@property (weak, nonatomic) id<ThemeSettingViewDelegate> delegate;

- (void)showingThemeSettingView:(BOOL)isShowing;

@end

NS_ASSUME_NONNULL_END
