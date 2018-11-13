//
//  EpubPageWebView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpubPageWebView : UIWebView
+ (NSString*)HTMLContentFromFile:(NSString*)fileFullPath AddJsContent:(NSString*)jsContent;
+ (NSString*)jsContentWithSetting:(ReaderSettingManager*)settingManager;

- (void)loadHTMLWithPath:(NSString*)filePath jsContent:(NSString *)jsContent;

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;

- (NSString *)getImageContentFromPoint:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
