//
//  EpubPageViewController.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubPageViewController.h"
#import "EpubPageWebView.h"
#import "CustomFileManager.h"
#import "EpubPageWKWebView.h"

@interface EpubPageViewController () <UIGestureRecognizerDelegate, EpubPageWKWebViewDelegate, EpubPageWebViewDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLab;
@property (nonatomic, weak) IBOutlet UILabel *pageStatusLab;
@property (nonatomic, weak) IBOutlet UILabel *timeStatusLab;

@property (nonatomic, weak) IBOutlet EpubPageWebView *pageWebview;

//wk
@property (nonatomic, weak) IBOutlet EpubPageWKWebView *pageWKWebView;

@end

@implementation EpubPageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pageWebview.hidden = YES;
        self.pageWKWebView.hidden = YES;
        self.chapterIndex = -1;
        self.pageIndex = -1;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
#warning 切换阅读页加载方式
    self.showType = PageViewShowTypeOfUIWebView;
    
    NSString *themeBodyColor = [self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"body"];
    UIColor *bgColor = [CustomTools UIColorFromRGBString:themeBodyColor];
    self.view.backgroundColor = bgColor;
    
    if (self.chapterIndex > -1) {
        self.chapterFileNameStr = [self.parserManager chapterFileNameByIndex:self.chapterIndex];
        
        if (self.showType == PageViewShowTypeOfWKWebView) {//WKWebView
            self.pageWKWebView.hidden = NO;
            
            self.pageWKWebView.delegate = self;
            self.pageWKWebView.parserManager = self.parserManager;
            [self.pageWKWebView loadHTMLChapterFileNameStr:self.chapterFileNameStr];
            
        } else {//UIWebView
            self.pageWebview.hidden = NO;
            
            if (self.parserManager.jsContent.length < 1) {
                self.parserManager.settingManager.containerSize = self.pageWebview.frame.size;
                self.parserManager.jsContent = [EpubPageWebView jsContentWithSetting:self.parserManager.settingManager];
            }
            
            self.pageWebview.delegate = self;
            self.pageWebview.parserManager = self.parserManager;
            [self.pageWebview loadHTMLWithChapterFileName:self.chapterFileNameStr jsContent:self.parserManager.jsContent];
        }
    }
    
    [self createGestureRecognizer];
}

#pragma mark -
- (void)gotoPageIndex {
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
    
    if (self.showType == PageViewShowTypeOfWKWebView) {
        if (self.parserManager.settingManager.currentSearchText.length > 0) {
            [self.pageWKWebView highlightAllOccurencesOfString:self.parserManager.settingManager.currentSearchText searchCount:^(NSInteger count) {
            }];
        }
        [self.pageWKWebView scrollToPageByIndex:self.pageIndex];
        
    } else {
        if (self.parserManager.settingManager.currentSearchText.length > 0) {
            [self.pageWebview highlightAllOccurencesOfString:self.parserManager.settingManager.currentSearchText];
        }
        [self.pageWebview scrollToPageByIndex:self.pageIndex];
    }
    
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
    [self.view addGestureRecognizer:singleTap];
}

- (void)onSingleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    
    void (^block)(NSString *filePath) = ^(NSString * filePath) {
        if (filePath.length > 0) {
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
    };
    
    if (self.showType == PageViewShowTypeOfWKWebView) {
        [self.pageWKWebView getImageContentFromPoint:point completion:^(NSString *filePath) {
            block(filePath);
        }];
    } else {
        NSString *filePath = [self.pageWebview getImageContentFromPoint:point];
        block(filePath);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - EpubPageWKWebViewDelegate
- (void)showEpubPageWKWebView:(EpubPageWKWebView*)epubPageWKWebView {
    [self gotoPageIndex];
}

#pragma mark - EpubPageWebViewDelegate
- (void)showEpubPageWebView:(EpubPageWebView*)epubPageWebView {
    [self gotoPageIndex];
}

@end
