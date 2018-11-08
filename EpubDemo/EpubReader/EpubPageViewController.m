//
//  EpubPageViewController.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubPageViewController.h"
#import "EpubPageWebView.h"

@interface EpubPageViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLab;
@property (nonatomic, weak) IBOutlet UILabel *pageStatusLab;
@property (nonatomic, weak) IBOutlet UILabel *timeStatusLab;
@property (nonatomic, weak) IBOutlet EpubPageWebView *pageWebview;

@end

@implementation EpubPageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.chapterIndex = -1;
        self.pageIndex = -1;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    for (UIView* v in self.pageWebview.subviews){
        if([v isKindOfClass:[UIScrollView class]]) {
            UIScrollView *sv = (UIScrollView*)v;
            sv.scrollEnabled = NO;
            sv.bounces = NO;
        }
    }
    
    NSString *themeBodyColor = [self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"body"];
    UIColor *bgColor = [CustomTools UIColorFromRGBString:themeBodyColor];
    self.view.backgroundColor = bgColor;
    
//    self.pageWebview.hidden = YES;
    
    if (self.chapterIndex > -1) {
        self.chapterFileNameStr = [self.parserManager chapterFileNameByIndex:self.chapterIndex];
        NSString *filePath = [NSString stringWithFormat:@"%@%@", self.parserManager.contentFilesFolder, self.chapterFileNameStr];
        
        if (self.parserManager.jsContent.length < 1) {
            self.parserManager.jsContent = [self jsContentWithViewSize:self.pageWebview.frame.size];
            self.parserManager.settingManager.containerSize = self.pageWebview.frame.size;
        }
        
        [self.pageWebview loadHTMLWithPath:filePath jsContent:self.parserManager.jsContent];
    }
    
    [self createGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self endAppearanceTransition];
}

#pragma mark -
- (void)gotoIndexOfPageWithIndex:(NSInteger)pageIndex andCountOfPage:(NSInteger)countOfPage {
    //页码内跳转
    if(pageIndex >= countOfPage) {
        pageIndex = countOfPage - 1;
    }
    
    CGFloat pageOffset = pageIndex * self.pageWebview.bounds.size.width;
    
    NSString* goToOffsetFunc = [NSString stringWithFormat:@" function pageScroll(xOffset){ window.scroll(xOffset,0); } "];
    NSString* goTo = [NSString stringWithFormat:@"pageScroll(%f)", pageOffset];
    
    [self.pageWebview stringByEvaluatingJavaScriptFromString:goToOffsetFunc];
    [self.pageWebview stringByEvaluatingJavaScriptFromString:goTo];
    
    [self reloadSubviews];
}

- (void)reloadSubviews {
    self.titleLab.text = [self.parserManager chapterNameByIndex:self.chapterIndex];
    
    NSNumber *countOfPage = [self.parserManager.chapterPageInfoDic objectForKey:self.chapterFileNameStr];
    self.pageStatusLab.text = [NSString stringWithFormat:@"%@ / %@" , @(self.pageIndex + 1), countOfPage];
    if ([self.delegate respondsToSelector:@selector(epubPageViewController:curPageInChapter:countPageInChapter:)]) {
        [self.delegate epubPageViewController:self curPageInChapter:@(self.pageIndex) countPageInChapter:@(countOfPage.integerValue - 1)];
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    self.timeStatusLab.text = timeStr;
}

#pragma mark - GestureRecognizer
- (void)createGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTapGestureRecognizer:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [self.pageWebview addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTapGestureRecognizer:)];
    singleTap.delegate = self;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.pageWebview addGestureRecognizer:singleTap];
    
}

- (void)onSingleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    if ([self.delegate respondsToSelector:@selector(singleTapEpubPageViewController:)]) {
        [self.delegate singleTapEpubPageViewController:self];
    }
}

- (void)onDoubleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    if ([self.delegate respondsToSelector:@selector(doubleTapEpubPageViewController:)]) {
        [self.delegate doubleTapEpubPageViewController:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked )
    {
        //禁止内容里面的超链接
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    BOOL isCalc = [self.parserManager.chapterPageInfoDic.allKeys containsObject:self.chapterFileNameStr];
    
    if (!isCalc && self.chapterIndex > -1) {
        //需要计算  页面的信息
        NSInteger totalWidth = [[theWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollWidth"] integerValue];
        NSLog(@"totalWidth  %lo",totalWidth);
        
        NSInteger theWebSizeWidth=theWebView.bounds.size.width;
        NSInteger countOfPage = (NSInteger)((float)totalWidth / theWebSizeWidth);
        
        [self.parserManager.chapterPageInfoDic setObject:@(countOfPage) forKey:self.chapterFileNameStr];
    }
    
    NSInteger countOfPage = [[self.parserManager.chapterPageInfoDic objectForKey:self.chapterFileNameStr] integerValue];
    NSLog(@"countOfPage:%lo", countOfPage);
    
    //滚动索引
    if (self.isPreChapter) {
        self.pageIndex = countOfPage - 1;
    }
    if (self.pageIndex >= countOfPage) {
        self.pageIndex = countOfPage - 1;
    }
    if (self.pageIndex <0) {
        self.pageIndex = 0;
    }
    
    NSLog(@"self.pageIndex:%lo", self.pageIndex);
    
    if (self.pageIndex > -1 && self.pageIndex < countOfPage && countOfPage > 0) {
        if (self.parserManager.settingManager.currentSearchText.length > 0) {
            [(EpubPageWebView*)theWebView highlightAllOccurencesOfString:self.parserManager.settingManager.currentSearchText];
        }

        [self gotoIndexOfPageWithIndex:self.pageIndex andCountOfPage:countOfPage];
    }
}

#pragma mark -
- (NSString*)jsContentWithViewSize:(CGSize)viewSize {
    
    NSString *js0 = @"";
    if (self.parserManager.settingManager.currentFontIndex == 1) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DFPShaoNvW5.ttf" ofType:nil];
        js0 = [self jsFontStyle:path];
    }
    
    NSString *js1=@"<style>img {  max-width:100% ; }</style>\n";
    
    //    NSArray *arrJs2=@[@"<script>"
    //                      ,@"var mySheet = document.styleSheets[0];"
    //                      ,@"function addCSSRule(selector, newRule){"
    //                      ,@"if (mySheet.addRule){"
    //                      ,@"mySheet.addRule(selector, newRule);"
    //                      ,@"} else {"
    //                      ,@"ruleIndex = mySheet.cssRules.length;"
    //                      ,@"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"
    //                      ,@"}"
    //                      ,@"}"
    //                      ,@"addCSSRule('p', 'text-align: justify;');"
    //                      ,@"addCSSRule('p', 'line-height: 1;');"
    //                      ,@"addCSSRule('highlight', 'background-color: yellow;');"
    //                      //,@"addCSSRule('body', '-webkit-text-size-adjust: 100%; font-size:10px;');"
    //                      ,@"addCSSRule('body', ' font-size:18px;');"
    //                      ,@"addCSSRule('body', ' font-family:\"fontName\"');"
    //                      ,@"addCSSRule('body', ' background-color:#000000');"
    //                      ,@"addCSSRule('h1', ' color:#ffffff"');"
    //                      ,@"addCSSRule('h2', ' color:#ffffff"');"
    //                      ,@"addCSSRule('p', ' color:#ffffff"');"
    //                      ,@"addCSSRule('body', ' margin:2.2em 5%% 0 5%%;');"   //上，右，下，左 顺时针
    //                      ,@"addCSSRule('html', 'padding: 0px; height: 480px; -webkit-column-gap: 0px; -webkit-column-width: 320px;');"
    //                      ,@"</script>"];
    
    NSMutableArray *arrJs=[NSMutableArray array];
    [arrJs addObject:@"<script>"];
    [arrJs addObject:@"var mySheet = document.styleSheets[0];"];
    [arrJs addObject:@"function addCSSRule(selector, newRule){"];
    [arrJs addObject:@"if (mySheet.addRule){"];
    [arrJs addObject:@"mySheet.addRule(selector, newRule);"];
    [arrJs addObject:@"} else {"];
    [arrJs addObject:@"ruleIndex = mySheet.cssRules.length;"];
    [arrJs addObject:@"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"];
    [arrJs addObject:@"}"];
    [arrJs addObject:@"}"];
    
    [arrJs addObject:@"addCSSRule('p', 'text-align: justify;');"];
    {//行间距
        // <p>
        NSString *addcss_spacing1 = [NSString stringWithFormat:@"addCSSRule('p', 'line-height: %@;');", @(self.parserManager.settingManager.currentSpacingIndex)];
        [arrJs addObject:addcss_spacing1];//字的行间距 默认是1 或者 使用px方式 默认值是20px
        
        // <p class="content">
        NSString *addcss_spacing2 = [NSString stringWithFormat:@"addCSSRule('p.content', 'line-height: %@;');", @(self.parserManager.settingManager.currentSpacingIndex)];
        [arrJs addObject:addcss_spacing2];//字的行间距 默认是1 或者 使用px方式 默认值是20px
    }
    {//搜索高亮
        NSString *themeHighlightColor = [self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"highlight"];
        NSString *addcss_hightlight = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: %@;');", themeHighlightColor];
        [arrJs addObject:addcss_hightlight];
    }
    {//字号
        NSString *addcss_fontSize = [NSString stringWithFormat:@"addCSSRule('body', ' font-size:%@px;');", @(self.parserManager.settingManager.currentTextSize)];
        [arrJs addObject:addcss_fontSize];
    }
    {//字体
        NSString *fontName = [[self.parserManager.settingManager.fontArr objectAtIndex:self.parserManager.settingManager.currentFontIndex] objectForKey:@"fontName"];
        NSString *addcss_font = [NSString stringWithFormat:@"addCSSRule('body', ' font-family:\"%@\";');", fontName];
        [arrJs addObject:addcss_font];
    }
    {//背景主题
        NSString *themeBodyColor = [self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"body"];
        NSString *addcss_bodyColor = [NSString stringWithFormat:@"addCSSRule('body', 'background-color: %@;')", themeBodyColor];
        [arrJs addObject:addcss_bodyColor];
        
        NSString *themeTextColor=[self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"text"];
        NSString *addcss_h1TextColor = [NSString stringWithFormat:@"addCSSRule('h1', 'color: %@;')", themeTextColor];
        [arrJs addObject:addcss_h1TextColor];
        NSString *addcss_h2TextColor = [NSString stringWithFormat:@"addCSSRule('h2', 'color: %@;')", themeTextColor];
        [arrJs addObject:addcss_h2TextColor];
        NSString *addcss_pTextColor = [NSString stringWithFormat:@"addCSSRule('p', 'color: %@;')", themeTextColor];
        [arrJs addObject:addcss_pTextColor];
    }
    [arrJs addObject:@"addCSSRule('body', ' margin:0 0 0 0;');"];//上，右，下，左 顺时针
    {
        NSString *css1=[NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %@px; -webkit-column-gap: 0px; -webkit-column-width: %@px;');",@(viewSize.height),@(viewSize.width)];//padding 内边距属性 ； -webkit-column-gap 列间距 ； -webkit-column-width 列宽
        [arrJs addObject:css1];
    }
    
    [arrJs addObject:@"</script>"];
    
    NSString *jsJoin=[arrJs componentsJoinedByString:@"\n"];
    
    NSString *jsRet=[NSString stringWithFormat:@"%@\n%@\n%@",js0,js1,jsJoin];
    return jsRet;
}

-(NSString*)jsFontStyle:(NSString*)fontFilePath {
    //注意 fontName, DFPShaoNvW5.ttf 如果改为 aa.ttf, 那么fontname也应该是“DFPShaoNvW5”，
    //fontName是系统认的名称,非文件名， 我这里把文件名改了，参考本文件的 customFontWithPath 方法得到真正的fontName
    
    NSString *fontFile = [fontFilePath lastPathComponent];
    NSString *fontName = [fontFile stringByDeletingPathExtension];
    //NSString *jsFont=@"<style type=\"text/css\"> @font-face{ font-family: 'DFPShaoNvW5'; src: url('DFPShaoNvW5-GB.ttf'); } </style> ";
    NSString *jsFontStyle = [NSString stringWithFormat:@"<style type=\"text/css\"> @font-face{ font-family: '%@'; src: url('%@'); } </style>", fontName, fontFile];
    
    return jsFontStyle;
}

@end
