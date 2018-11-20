//
//  EpubPageWKWebView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/20.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EpubPageWKWebView;

@protocol EpubPageWKWebViewDelegate <NSObject>

- (void)showEpubPageWKWebView:(EpubPageWKWebView*)epubPageWKWebView;

@end

@interface EpubPageWKWebView : UIView

@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) EpubParserManager *parserManager;
@property (weak, nonatomic) id<EpubPageWKWebViewDelegate> delegate;

- (void)loadHTMLChapterFileNameStr:(NSString*)chapterFileNameStr;
- (void)getImageContentFromPoint:(CGPoint)point completion:(void (^)(NSString* filePath))handler;
- (void)scrollToPageByIndex:(NSInteger)index;
- (void)highlightAllOccurencesOfString:(NSString*)str searchCount:(void (^)(NSInteger count))searchHandle;
- (void)removeAllHighlights;
@end

NS_ASSUME_NONNULL_END
