//
//  EpubPageWebView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EpubPageWebView;

@protocol EpubPageWebViewDelegate <NSObject>

- (void)showEpubPageWebView:(EpubPageWebView*)epubPageWebView;

@end

@interface EpubPageWebView : UIView

@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) EpubParserManager *parserManager;
@property (weak, nonatomic) id<EpubPageWebViewDelegate> delegate;

+ (NSString*)HTMLContentFromFile:(NSString*)fileFullPath AddJsContent:(NSString*)jsContent;
+ (NSString*)jsContentWithSetting:(ReaderSettingManager*)settingManager;

- (void)loadHTMLWithChapterFileName:(NSString*)chapterFileNameStr jsContent:(NSString *)jsContent;

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;

- (NSString *)getImageContentFromPoint:(CGPoint)point;

- (void)scrollToPageByIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
