//
//  EpubReaderViewController.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/23.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubReaderViewController.h"
#import "EpubParserManager.h"
#import "EpubPageViewController.h"
#import "ReaderTopSettingView.h"
#import "ReaderBottomSettingView.h"
#import "EpubCatalogViewController.h"
#import "FontSettingView.h"
#import "ThemeSettingView.h"
#import "PagingSettingView.h"
#import "EpubSearchViewController.h"

@interface EpubReaderViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, EpubPageViewControllerDelegate, ReaderTopSettingViewDelegate, ReaderBottomSettingViewDelegate, EpubCatalogViewControllerDelegate, FontSettingViewDelegate, ThemeSettingViewDelegate, PagingSettingViewDelegate, EpubSearchViewControllerDelegate>
@property (strong, nonatomic) EpubParserManager *parserManager;
@property (strong, nonatomic) UIPageViewController * pageViewController;
@property (strong, nonatomic) ReaderTopSettingView *topView;
@property (strong, nonatomic) ReaderBottomSettingView *bottomView;
@property (strong, nonatomic) FontSettingView *fontSettingView;
@property (strong, nonatomic) ThemeSettingView *themeSettingView;
@property (strong, nonatomic) PagingSettingView *pagingSettingView;

@property (assign, nonatomic) NSInteger chapterIndex;
@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) BOOL isShowStatusBar;

@end

@implementation EpubReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSString *fileFullPath = [[NSBundle mainBundle] pathForResource:self.bookNameStr ofType:@"epub"];
    self.parserManager = [[EpubParserManager alloc] init];
    [self.parserManager parserEpubSourceByFullPath:fileFullPath];
    
    [self addSettingObserver];
    
    [self showPageViewController];
    [self createSettingViews];
    
    if (self.parserManager.settingManager.settingStatus == ReaderShowSettingStatusOfTopAndBottom) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfNone;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self removeSettingObserver];
}

- (BOOL)prefersStatusBarHidden {
    return !self.isShowStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"presentEpubCatalogViewController"]) {
        EpubCatalogViewController *catelogVc = segue.destinationViewController;
        catelogVc.delegate = self;
        catelogVc.parserManager = self.parserManager;
    }else if ([segue.identifier isEqualToString:@"presentEpubSearchViewController"]) {
        EpubSearchViewController *searchVc = segue.destinationViewController;
        searchVc.delegate = self;
        searchVc.parserManager = self.parserManager;
    }
}

#pragma mark -
- (void)createSettingViews {
    if (!self.topView) {
        self.topView = [[NSBundle mainBundle] loadNibNamed:@"ReaderTopSettingView" owner:nil options:nil].lastObject;
        self.topView.delegate = self;
        self.topView.backgroundColor = [UIColor redColor];
        self.topView.frame = CGRectMake(0, -70, CGRectGetWidth([UIScreen mainScreen].bounds), 70);
        [self.view addSubview:self.topView];
    }
    
    if (!self.bottomView) {
        self.bottomView = [[NSBundle mainBundle] loadNibNamed:@"ReaderBottomSettingView" owner:nil options:nil].lastObject;
        self.bottomView.delegate = self;
        self.bottomView.backgroundColor = [UIColor redColor];
        self.bottomView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds), 70);
        [self.view addSubview:self.bottomView];
    }
    
    self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfTopAndBottom;
}

- (void)showOrHiddenSettingViews:(BOOL)isShow {
    [UIView animateWithDuration:0.25 animations:^{
        if (isShow) {
            self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.height);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, -self.bottomView.height);
        } else {
            self.topView.transform = CGAffineTransformIdentity;
            self.bottomView.transform = CGAffineTransformIdentity;
        }
        self.isShowStatusBar = isShow;
        [self setNeedsStatusBarAppearanceUpdate];
        
    }];
}

- (void)showPageViewController {
    NSInteger pageRefIndex = self.chapterIndex;
    NSInteger offYIndexInPage = self.pageIndex;    // 当前滚动索引
    
    if (self.pageViewController)
    {
        if ([self.pageViewController.viewControllers count]>0) {
            EpubPageViewController *currentPageVC = (EpubPageViewController*)[_pageViewController.viewControllers objectAtIndex:0];
            pageRefIndex = currentPageVC.chapterIndex;
            offYIndexInPage = currentPageVC.pageIndex;
        }
        
        [self.pageViewController.view removeFromSuperview];
        [self.pageViewController removeFromParentViewController];
        self.pageViewController = nil;
    }
    
    NSMutableDictionary * options = [NSMutableDictionary dictionary];
    NSNumber *spineLocationValue = [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin];
    [options setObject:spineLocationValue forKey:UIPageViewControllerOptionSpineLocationKey];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:self.parserManager.settingManager.pagingType navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    self.pageViewController.view.frame = self.view.bounds;
    self.pageViewController.view.backgroundColor=[UIColor clearColor];
    {
        NSString *themeBodyColor = [self.parserManager.settingManager.themeArr[self.parserManager.settingManager.currentThemeIndex] objectForKey:@"body"];
        UIColor *bgColor = [CustomTools UIColorFromRGBString:themeBodyColor];
        self.view.backgroundColor = bgColor;
        self.pageViewController.view.backgroundColor = bgColor;
    }
    
    NSArray * viewControllers = nil;
    {
        EpubPageViewController *firstVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
        firstVC.delegate = self;
        firstVC.parserManager = self.parserManager;
        firstVC.chapterIndex = self.chapterIndex;
        firstVC.pageIndex = self.pageIndex;
        
        viewControllers = [NSArray arrayWithObjects:firstVC,nil];
    }
    
    [_pageViewController setViewControllers:viewControllers direction:(UIPageViewControllerNavigationDirectionForward) animated:NO completion:nil];
    
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    [self.view addSubview:_pageViewController.view];
    [self.view sendSubviewToBack:_pageViewController.view];
    [self addChildViewController:_pageViewController];
}

- (EpubPageViewController*)showPrePageVCWithCurPageVC:(EpubPageViewController*)curPageVC {
    NSInteger chapterIndex = curPageVC.chapterIndex;
    NSInteger pageIndex = curPageVC.pageIndex;
    
    NSInteger countOfPage = [[self.parserManager.chapterPageInfoDic objectForKey:curPageVC.chapterFileNameStr] integerValue];
    if (countOfPage < 1) {
        return nil;
    }
    
    if (chapterIndex == 0 && pageIndex == 0) {
        //第一页 或 没有找到
        return nil;
    }
    
    EpubPageViewController *pageVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
    pageVC.delegate = self;
    pageVC.parserManager = self.parserManager;
    
    if (pageIndex > 0) { //pre page
        pageVC.chapterIndex = chapterIndex;
        pageVC.pageIndex = pageIndex - 1;
        self.pageIndex = pageIndex - 1;
        
        return pageVC;
    } else { //pre chapter
        pageVC.chapterIndex = chapterIndex - 1;
        pageVC.isPreChapter = YES;
        self.chapterIndex = chapterIndex - 1;
        
        return pageVC;
    }
    
    return nil;
}

- (EpubPageViewController*)showNextPageVCWithCurPageVC:(EpubPageViewController*)curPageVC {
    NSInteger chapterIndex = curPageVC.chapterIndex;
    NSInteger pageIndex = curPageVC.pageIndex;
    
    NSInteger countOfPage = [[self.parserManager.chapterPageInfoDic objectForKey:curPageVC.chapterFileNameStr] integerValue];
    if (countOfPage < 1) {
        return nil;
    }
    
    if (chapterIndex < 0) {
        //说明是 补充页
        return nil;
    }
    
    EpubPageViewController *pageVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
    pageVC.delegate = self;
    pageVC.parserManager = self.parserManager;
    
    if (pageIndex + 1 < countOfPage) { //next page
        pageVC.chapterIndex = chapterIndex;
        pageVC.pageIndex = pageIndex + 1;
        self.pageIndex = pageIndex + 1;
        
        return pageVC;
    } else { //next chapter
        NSInteger chapterCount = self.parserManager.catelogInfoArr.count;
        if (chapterIndex < chapterCount - 1) {
            pageVC.chapterIndex = chapterIndex + 1;
            self.chapterIndex = chapterIndex + 1;
            
            return pageVC;
        } else {
            return nil;
        }
    }
    return nil;
}

#pragma mark - KVO
- (void)addSettingObserver {
    [self.parserManager.settingManager addObserver:self forKeyPath:@"settingStatus" options:NSKeyValueObservingOptionNew context:nil];
    [self.parserManager.settingManager addObserver:self forKeyPath:@"currentTextSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.parserManager.settingManager addObserver:self forKeyPath:@"currentFontIndex" options:NSKeyValueObservingOptionNew context:nil];
    [self.parserManager.settingManager addObserver:self forKeyPath:@"currentSpacingIndex" options:NSKeyValueObservingOptionNew context:nil];
    [self.parserManager.settingManager addObserver:self forKeyPath:@"currentThemeIndex" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeSettingObserver {
    [self.parserManager.settingManager removeObserver:self forKeyPath:@"settingStatus"];
    [self.parserManager.settingManager removeObserver:self forKeyPath:@"currentTextSize"];
    [self.parserManager.settingManager removeObserver:self forKeyPath:@"currentFontIndex"];
    [self.parserManager.settingManager removeObserver:self forKeyPath:@"currentSpacingIndex"];
    [self.parserManager.settingManager removeObserver:self forKeyPath:@"currentThemeIndex"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"settingStatus"]) {
        ReaderSettingManager *manager = (ReaderSettingManager*)object;
        switch (manager.settingStatus) {
            case ReaderShowSettingStatusOfTopAndBottom:{
                [self showOrHiddenSettingViews:YES];
            }
                break;
                
            case ReaderShowSettingStatusOfFont: {
                [self showOrHiddenSettingViews:NO];
                [self.fontSettingView showingFontSettingView:YES];
            }
                break;
                
            case ReaderShowSettingStatusOfTheme: {
                [self showOrHiddenSettingViews:NO];
                [self.themeSettingView showingThemeSettingView:YES];
            }
                break;
                
            case ReaderShowSettingStatusOfPaging: {
                [self showOrHiddenSettingViews:NO];
                [self.pagingSettingView showingPagingSettingView:YES];
            }
                break;
            default: {
                [self.themeSettingView showingThemeSettingView:NO];
                [self.fontSettingView showingFontSettingView:NO];
                [self.pagingSettingView showingPagingSettingView:NO];
                [self showOrHiddenSettingViews:NO];
            }
                break;
        }
    } else if ([keyPath isEqualToString:@"currentTextSize"] || [keyPath isEqualToString:@"currentFontIndex"] || [keyPath isEqualToString:@"currentSpacingIndex"]) {
        [self.parserManager.chapterPageInfoDic removeAllObjects];
        self.parserManager.jsContent = @"";
    } else if ([keyPath isEqualToString:@"currentThemeIndex"]) {
        self.parserManager.jsContent = @"";
    }
}

#pragma mark - Lazy load
- (FontSettingView*)fontSettingView {
    if (_fontSettingView == nil) {
        _fontSettingView = [[NSBundle mainBundle] loadNibNamed:@"FontSettingView" owner:nil options:nil].lastObject;
        _fontSettingView.delegate = self;
        [self.view addSubview:_fontSettingView];
    }
    
    return _fontSettingView;
}

- (ThemeSettingView*)themeSettingView {
    if (_themeSettingView == nil) {
        _themeSettingView = [[NSBundle mainBundle] loadNibNamed:@"ThemeSettingView" owner:nil options:nil].lastObject;
        _themeSettingView.delegate = self;
        [self.view addSubview:_themeSettingView];
    }
    
    return _themeSettingView;
}

- (PagingSettingView*)pagingSettingView {
    if (_pagingSettingView == nil) {
        _pagingSettingView = [[NSBundle mainBundle] loadNibNamed:@"PagingSettingView" owner:nil options:nil].lastObject;
        _pagingSettingView.delegate = self;
        [self.view addSubview:_pagingSettingView];
    }
    
    return _pagingSettingView;
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self showPrePageVCWithCurPageVC:(EpubPageViewController*)viewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self showNextPageVCWithCurPageVC:(EpubPageViewController*)viewController];
}

#pragma mark - UIPageViewControllerDelegate

#pragma mark - EpubPageViewControllerDelegate
- (void)singleTapEpubPageViewControllerToShowPrePage:(EpubPageViewController*)epubPageViewController {
    EpubPageViewController* prePage = [self showPrePageVCWithCurPageVC:epubPageViewController];
    if (prePage) {
        [self.pageViewController setViewControllers:@[prePage] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            
        }];
    }
}

- (void)singleTapEpubPageViewControllerToShowNextPage:(EpubPageViewController*)epubPageViewController {
    EpubPageViewController* nextPage = [self showNextPageVCWithCurPageVC:epubPageViewController];
    if (nextPage) {
        [self.pageViewController setViewControllers:@[nextPage] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            
        }];
    }
}

- (void)singleTapEpubPageViewControllerToShowSetting:(EpubPageViewController*)epubPageViewController {
    switch (self.parserManager.settingManager.settingStatus) {
        case ReaderShowSettingStatusOfTopAndBottom: {
            self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfNone;
        }
            break;
        case ReaderShowSettingStatusOfFont: {
            self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfNone;
        }
            break;
        case ReaderShowSettingStatusOfTheme: {
            self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfNone;
        }
            break;
        case ReaderShowSettingStatusOfPaging: {
            self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfNone;
        }
            break;
        default:{
            self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfTopAndBottom;
        }
            break;
    }
}

- (void)doubleTapEpubPageViewController:(EpubPageViewController*)epubPageViewController {
}

- (void)epubPageViewController:(EpubPageViewController*)epubPageViewController curPageInChapter:(NSNumber*)curPage countPageInChapter:(NSNumber *)countPage; {
    self.bottomView.progressSlider.maximumValue = countPage.floatValue;
    self.bottomView.progressSlider.minimumValue = 0;
    self.bottomView.progressSlider.value = curPage.floatValue;
}

#pragma mark - ReaderTopSettingViewDelegate
- (void)readerTopSettingViewTapBackHandle:(ReaderTopSettingView*)readerTopSettingView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)readerTopSettingViewTapSearchHandle:(ReaderTopSettingView*)readerTopSettingView {
    [self performSegueWithIdentifier:@"presentEpubSearchViewController" sender:self];
}

#pragma mark - ReaderBottomSettingViewDelegate
- (void)readerBottomSettingViewTapPreChapter:(ReaderBottomSettingView*)readerBottomSettingView {
    NSInteger index = self.chapterIndex;
    if (index - 1 < 0) {
        return;
    }
    
    self.chapterIndex = index - 1;
    self.pageIndex = 0;
    [self showPageViewController];
}

- (void)readerBottomSettingViewTapNextChapter:(ReaderBottomSettingView*)readerBottomSettingView{
    NSInteger chapterCount = [self.parserManager.catelogInfoArr count];
    NSInteger index = self.chapterIndex;
    if (index + 1 > chapterCount - 1) {
        return;
    }
    self.chapterIndex = index + 1;
    self.pageIndex = 0;
    [self showPageViewController];
}

- (void)readerBottomSettingViewTapCatalogBtn:(ReaderBottomSettingView *)readerBottomSettingView {
    [self performSegueWithIdentifier:@"presentEpubCatalogViewController" sender:self];
}

- (void)readerBottomSettingViewTapFontBtn:(ReaderBottomSettingView*)readerBottomSettingView {
    self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfFont;
}

- (void)readerBottomSettingViewTapBrightnessBtn:(ReaderBottomSettingView*)readerBottomSettingView {
    self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfTheme;
}

- (void)readerBottomSettingViewTapPagingBtn:(ReaderBottomSettingView*)readerBottomSettingView {
    self.parserManager.settingManager.settingStatus = ReaderShowSettingStatusOfPaging;
}

- (void)readerBottomSettingView:(ReaderBottomSettingView*)readerBottomSettingView changedSliderValue:(CGFloat)sliderValue {
    self.pageIndex = floorf(sliderValue);
    [self showPageViewController];
}

#pragma mark - EpubCatalogViewControllerDelegate
- (void)epubCatalogViewController:(EpubCatalogViewController*)epubCatalogViewController jumpToChapterWithChapterIndex:(NSInteger)chapterIndex {
    if (chapterIndex >= 0 && chapterIndex < self.parserManager.catelogInfoArr.count) {
        self.chapterIndex = chapterIndex;
        self.pageIndex = 0;
        [self showPageViewController];
    }
}

#pragma mark - FontSettingViewDelegate
- (void)fontSettingViewReduceSize:(FontSettingView*)fontSettingView {
    NSInteger size = self.parserManager.settingManager.currentTextSize - TextSizeStep;
    size = MIN(TextSizeMax, size);
    size = MAX(TextSizeMin, size);
    if (size != self.parserManager.settingManager.currentFontIndex) {
        self.parserManager.settingManager.currentTextSize = size;
        [self showPageViewController];
    }
}

- (void)fontSettingViewIncreaseSize:(FontSettingView*)fontSettingView {
    NSInteger size = self.parserManager.settingManager.currentTextSize + TextSizeStep;
    size = MIN(TextSizeMax, size);
    size = MAX(TextSizeMin, size);
    if (size != self.parserManager.settingManager.currentFontIndex) {
        self.parserManager.settingManager.currentTextSize = size;
        [self showPageViewController];
    }
}

- (void)fontSettingView:(FontSettingView*)fontSettingView selectFontWithIndex:(NSInteger)index {
    if (self.parserManager.settingManager.currentFontIndex != index - 1) {
        self.parserManager.settingManager.currentFontIndex = index - 1;
        [self showPageViewController];
    }
}

- (void)fontSettingView:(FontSettingView *)fontSettingView selectSpacingWithIndex:(NSInteger)index {
    if (self.parserManager.settingManager.currentSpacingIndex != index) {
        self.parserManager.settingManager.currentSpacingIndex = index;
        [self showPageViewController];
    }
}

#pragma mark - ThemeSettingViewDelegate
- (void)themeSettingView:(ThemeSettingView*)themeSettingView themeBtnTag:(NSInteger)tag {
    if (self.parserManager.settingManager.currentThemeIndex != tag) {
        self.parserManager.settingManager.currentThemeIndex = tag;
        [self showPageViewController];
    }
}

#pragma mark - PagingSettingViewDelegate
- (void)pagingSettingView:(PagingSettingView*)pagingSettingView btnTag:(NSInteger)tag {
    if (self.parserManager.settingManager.pagingType != tag) {
        self.parserManager.settingManager.pagingType = tag;
        [self showPageViewController];
    }
}

#pragma mark - EpubSearchViewControllerDelegate
- (void)epubSearchViewController:(EpubSearchViewController*)epubSearchViewController chapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex {
    self.chapterIndex = chapterIndex;
    self.pageIndex = pageIndex;
    
    if (_pageViewController) {
        [_pageViewController.view removeFromSuperview];
        [_pageViewController removeFromParentViewController];
        self.pageViewController=nil;
    }
    
    [self showPageViewController];
}

@end
