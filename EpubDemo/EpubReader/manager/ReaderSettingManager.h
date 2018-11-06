//
//  ReaderSettingManager.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ReaderShowSettingStatus) {
    ReaderShowSettingStatusOfNone,
    ReaderShowSettingStatusOfTopAndBottom,
    ReaderShowSettingStatusOfFont,
    ReaderShowSettingStatusOfTheme,
    ReaderShowSettingStatusOfPaging,
};

#define TextSizeMax 38
#define TextSizeMin 12
#define TextSizeStep 2

NS_ASSUME_NONNULL_BEGIN

@interface ReaderSettingManager : NSObject

@property (assign, nonatomic) ReaderShowSettingStatus settingStatus;

@property (assign, nonatomic) NSInteger currentTextSize;

@property (strong, nonatomic) NSArray *fontArr;
@property (assign, nonatomic) NSInteger currentFontIndex;

@property (assign, nonatomic) NSInteger currentSpacingIndex;

@property (strong, nonatomic) NSArray *themeArr;
@property (assign, nonatomic) NSInteger currentThemeIndex;

@property (assign, nonatomic) NSInteger pagingType;

@end

NS_ASSUME_NONNULL_END
