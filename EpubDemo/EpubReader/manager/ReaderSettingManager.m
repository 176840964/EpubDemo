//
//  ReaderSettingManager.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "ReaderSettingManager.h"

@implementation ReaderSettingManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentTextSize = 18;
        self.settingStatus = ReaderShowSettingStatusOfNone;
        
        NSDictionary *dic1 = @{@"name": @"系统字体", @"fontName": @"Helvetica", @"fontFile": @""};
        NSDictionary *dic2 = @{@"name": @"华康少女体", @"fontName": @"DFPShaoNvW5", @"fontFile": @"DFPShaoNvW5.ttf"};
        self.fontArr = [NSArray arrayWithObjects:dic1, dic2, nil];
        self.currentFontIndex = 0;
        
        self.currentSpacingIndex = 2;
        
        NSDictionary *theme1 = @{@"body": @"#ffffff", @"text": @"#000000", @"highlight": @"#c7edcc"};
        NSDictionary *theme2 = @{@"body": @"#000000", @"text": @"#ffffff", @"highlight": @"#c7edcc"};
        NSDictionary *theme3 = @{@"body": @"#c7edcc", @"text": @"#000000", @"highlight": @"#333333"};
        self.themeArr = [NSArray arrayWithObjects:theme1, theme2, theme3, nil];
        self.currentThemeIndex = 2;
        
        self.pagingType = 1;
        
        self.currentSearchText = @"";
        self.searchResultArr = [[NSMutableArray alloc] init];
    }
    
    return self;
}
@end
