//
//  ReaderTopSettingView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/5.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReaderTopSettingView;

NS_ASSUME_NONNULL_BEGIN

@protocol ReaderTopSettingViewDelegate <NSObject>

- (void)readerTopSettingViewTapSearchHandle:(ReaderTopSettingView*)readerTopSettingView;

@end

@interface ReaderTopSettingView : UIView

@property (weak, nonatomic) id<ReaderTopSettingViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
