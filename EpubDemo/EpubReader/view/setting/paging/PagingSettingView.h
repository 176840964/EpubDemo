//
//  PagingSettingView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PagingSettingView;

NS_ASSUME_NONNULL_BEGIN

@protocol PagingSettingViewDelegate <NSObject>

- (void)pagingSettingView:(PagingSettingView*)pagingSettingView btnTag:(NSInteger)tag;

@end

@interface PagingSettingView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;

@property (weak, nonatomic) id<PagingSettingViewDelegate> delegate;

- (void)showingPagingSettingView:(BOOL)isShowing;

@end

NS_ASSUME_NONNULL_END
