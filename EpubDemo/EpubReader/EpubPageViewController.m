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
    
    if (self.chapterIndex > -1) {
        self.chapterFileNameStr = [self.parserManager chapterFileNameByIndex:self.chapterIndex];
        NSString *filePath = [NSString stringWithFormat:@"%@%@", self.parserManager.contentFilesFolder, self.chapterFileNameStr];
        
        if (self.parserManager.jsContent.length < 1) {
            self.parserManager.settingManager.containerSize = self.pageWebview.frame.size;
            self.parserManager.jsContent = [EpubPageWebView jsContentWithSetting:self.parserManager.settingManager];
        }
        
        [self.pageWebview loadHTMLWithPath:filePath jsContent:self.parserManager.jsContent];
    }
    
    [self createGestureRecognizer];
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
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTapGestureRecognizer:)];
    singleTap.delegate = self;
    [self.pageWebview addGestureRecognizer:singleTap];
}

- (void)onSingleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    
    NSString *filePath = [self.pageWebview getImageContentFromPoint:point];
    if (filePath) {
        if ([self.delegate respondsToSelector:@selector(epubPageViewController:showImageWithFilePath:)]) {
            [self.delegate epubPageViewController:self showImageWithFilePath:filePath];
        }
    } else {
        if (point.x < CGRectGetWidth([UIScreen mainScreen].bounds) / 3.0) {
            if ([self.delegate respondsToSelector:@selector(singleTapEpubPageViewControllerToShowPrePage:)]) {
                [self.delegate singleTapEpubPageViewControllerToShowPrePage:self];
            }
        } else if (point.x > CGRectGetWidth([UIScreen mainScreen].bounds) / 3.0 * 2.0) {
            if ([self.delegate respondsToSelector:@selector(singleTapEpubPageViewControllerToShowNextPage:)]) {
                [self.delegate singleTapEpubPageViewControllerToShowNextPage:self];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(singleTapEpubPageViewControllerToShowSetting:)]) {
                [self.delegate singleTapEpubPageViewControllerToShowSetting:self];
            }
        }
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
        
        NSInteger theWebSizeWidth = theWebView.bounds.size.width;
        NSInteger countOfPage = (NSInteger)((float)totalWidth / theWebSizeWidth);
        
        [self.parserManager.chapterPageInfoDic setObject:@(countOfPage) forKey:self.chapterFileNameStr];
    }
    
    NSInteger countOfPage = [[self.parserManager.chapterPageInfoDic objectForKey:self.chapterFileNameStr] integerValue];
    NSLog(@"countOfPage:%ld", (long)countOfPage);
    
    //滚动索引
    if (self.isPreChapter) {
        self.pageIndex = countOfPage - 1;
    }
    if (self.pageIndex >= countOfPage) {
        self.pageIndex = countOfPage - 1;
    }
    if (self.pageIndex < 0) {
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

@end
