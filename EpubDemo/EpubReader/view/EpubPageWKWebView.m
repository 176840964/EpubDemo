//
//  EpubPageWKWebView.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/20.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubPageWKWebView.h"
#import "CustomFileManager.h"

@interface EpubPageWKWebView () <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>
@property (copy, nonatomic) NSString *chapterFileNameStr;
@end

@implementation EpubPageWKWebView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)loadHTMLChapterFileNameStr:(NSString*)chapterFileNameStr{
    self.chapterFileNameStr = chapterFileNameStr;
    NSString *filePath = [NSString stringWithFormat:@"%@%@", self.parserManager.contentFilesFolder, self.chapterFileNameStr];
    [self.webView loadFileURL:[NSURL fileURLWithPath:filePath] allowingReadAccessToURL:[NSURL fileURLWithPath:self.parserManager.contentFilesFolder]];
}

- (void)getImageContentFromPoint:(CGPoint)point completion:(void (^)(NSString* filePath))handler {
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", point.x, point.y];
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable value, NSError * _Nullable error) {
        NSString *tagName = value;
        if ([[tagName uppercaseString] isEqualToString:@"IMG"]) {
            NSString *imgUrl = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", point.x, point.y];
            
            [self.webView evaluateJavaScript:imgUrl completionHandler:^(id _Nullable value, NSError * _Nullable error) {
                NSString *fileUrl = value;
                NSString *filePath = [fileUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""].stringByRemovingPercentEncoding;
                
                if ([CustomFileManager isFileExist:filePath]) {
                    handler(filePath);
                }
            }];
        } else {
            handler(@"");
        }
    }];
}

- (void)scrollToPageByIndex:(NSInteger)index {
    CGFloat pageOffset = index * self.bounds.size.width;
    NSString* goTo = [NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
    [self.webView evaluateJavaScript:goTo completionHandler:^(id _Nullable value, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s, %@", __func__, error);
        }
    }];
}

- (void)highlightAllOccurencesOfString:(NSString*)str searchCount:(void (^)(NSInteger count))searchHandle {
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@');",str];
    [self.webView evaluateJavaScript:startSearch completionHandler:^(id _Nullable value , NSError * _Nullable error) {
        NSInteger count = [value integerValue];
        searchHandle(count);
    }];
}

- (void)removeAllHighlights {
    [self.webView evaluateJavaScript:@"MyApp_RemoveAllHighlights()" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - lazy load
- (WKWebView*)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        webViewConfig.preferences = [[WKPreferences alloc] init];
        webViewConfig.preferences.minimumFontSize = 10;
        webViewConfig.preferences.javaScriptEnabled = YES;
        [webViewConfig.preferences setValue:@(YES) forKey:@"allowFileAccessFromFileURLs"];
        webViewConfig.userContentController = [WKUserContentController new];

        NSString* js_Layout = [self js_layout];
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:js_Layout injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [webViewConfig.userContentController addUserScript:userScript];

        NSString *js_pageScroll = [self js_pageScroll];
        WKUserScript *userScript1 = [[WKUserScript alloc] initWithSource:js_pageScroll injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [webViewConfig.userContentController addUserScript:userScript1];

        NSString *js_resizeImages = [self js_resizeImages];
        WKUserScript *userScript2 = [[WKUserScript alloc] initWithSource:js_resizeImages injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [webViewConfig.userContentController addUserScript:userScript2];
        
        NSString *js_hightlight = [self js_hightlight];
        WKUserScript *userScript3 = [[WKUserScript alloc] initWithSource:js_hightlight injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [webViewConfig.userContentController addUserScript:userScript3];

        _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:webViewConfig];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [self addSubview:_webView];

        for (UIView* v in _webView.subviews){
            v.backgroundColor = [UIColor clearColor];
            if([v isKindOfClass:[UIScrollView class]]) {
                UIScrollView *sv = (UIScrollView*)v;
                sv.scrollEnabled = NO;
                sv.bounces = NO;
            }
        }
    }
    
    return _webView;
}

#pragma mark - js
- (NSString *)js_layout {
    NSMutableArray *jsArr = [[NSMutableArray alloc] init];
    [jsArr addObject:@"var head = document.querySelector('head')"];
    
    [jsArr addObject:@"var meta = document.createElement('meta');"];
    [jsArr addObject:@"meta.setAttribute('name', 'viewport');"];
    [jsArr addObject:@"meta.setAttribute('content', 'width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no');"];
    [jsArr addObject:@"head.appendChild(meta);"];
    
    [jsArr addObject:@"var html = document.querySelector('html');"];
    //    [jsArr addObject:[NSString stringWithFormat:@"html.style['-webkit-column-width']='%@'+'px'", @(self.contentView.width)]];
    [jsArr addObject:@"html.style['-webkit-column-width']=window.innerWidth+'px'"];
    [jsArr addObject:[NSString stringWithFormat:@"html.style['height']='%@'+'px'", @(self.height)]];
    [jsArr addObject:[NSString stringWithFormat:@"html.style['-webkit-column-gap']='%@'+'px'", @(0)]];
    
    NSString *themeBodyColor = [self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"body"];
    [jsArr addObject:[NSString stringWithFormat:@"html.style['background-color']='%@';", themeBodyColor]];
    
    NSString *themeTextColor = [self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"text"];
    [jsArr addObject:[NSString stringWithFormat:@"html.style['color']='%@';", themeTextColor]];
    [jsArr addObject:[NSString stringWithFormat:@"html.style['font-size']='%@'+'px';", @(self.parserManager.settingManager.currentTextSize)]];
    
    [jsArr addObject:@"var p = document.querySelector('p');"];
    [jsArr addObject:@"if (p){"];
    [jsArr addObject:[NSString stringWithFormat:@"p['color']='%@';", themeTextColor]];
    [jsArr addObject:[NSString stringWithFormat:@"p['font-size']='%@';}", @(self.parserManager.settingManager.currentTextSize)]];
    
    [jsArr addObject:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    NSString *jsStr = [jsArr componentsJoinedByString:@"\n"];
    
    return jsStr;
}

- (NSString*)js_resizeImages {
    NSString *js_img = @"var script = document.createElement('script');"
    "script.type = 'text/javascript';"
    "script.text = \"function ResizeImages() { "
    "var myimg,oldwidth;"
    "var maxwidth = %f;"
    "for(i=0;i <document.images.length;i++){"
    "myimg = document.images[i];"
    "if(myimg.width > maxwidth){"
    "oldwidth = myimg.width;"
    "myimg.width = %f;"
    "}"
    "}"
    "}\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    js_img = [NSString stringWithFormat:js_img, self.width, self.width - 15];
    
    return js_img;
}

- (NSString *)js_pageScroll {
    return @"function pageScroll(xOffset){ window.scroll(xOffset,0); }";
}

- (NSString *)js_hightlight {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return jsCode;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s", __func__);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s", __func__);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __func__);
    
    [self.webView evaluateJavaScript:@"ResizeImages()" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
    }];
    
    BOOL isCalc = [self.parserManager.chapterPageInfoDic.allKeys containsObject:self.chapterFileNameStr];
    if (!isCalc) {
        
        //需要计算  页面的信息
        [webView evaluateJavaScript:@"document.documentElement.scrollWidth" completionHandler:^(id _Nullable totalWidth, NSError * _Nullable error) {
            NSLog(@"totalWidth  %@",totalWidth);
            NSInteger theWebSizeWidth = webView.bounds.size.width;
            NSInteger countOfPage = (NSInteger)([totalWidth floatValue] / theWebSizeWidth);
            
            [self.parserManager.chapterPageInfoDic setObject:@(countOfPage) forKey:self.chapterFileNameStr];
            
            if ([self.delegate respondsToSelector:@selector(showEpubPageWKWebView:)]) {
                [self.delegate showEpubPageWKWebView:self];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(showEpubPageWKWebView:)]) {
            [self.delegate showEpubPageWKWebView:self];
        }
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%s", __func__);
}

@end
