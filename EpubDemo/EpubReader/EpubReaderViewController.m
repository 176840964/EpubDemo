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

@interface EpubReaderViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, EpubPageViewControllerDelegate, ReaderBottomSettingViewDelegate, EpubCatalogViewControllerDelegate>
@property (strong, nonatomic) EpubParserManager *parserMangeger;
@property (strong, nonatomic) UIPageViewController * pageViewController;
@property (strong, nonatomic) ReaderTopSettingView *topView;
@property (strong, nonatomic) ReaderBottomSettingView *bottomView;

@property (assign, nonatomic) NSInteger chapterIndex;
@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) BOOL isShowStatusBar;

@end

@implementation EpubReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *fileFullPath = [[NSBundle mainBundle] pathForResource:@"dmbj" ofType:@"epub"];
    self.parserMangeger = [[EpubParserManager alloc] init];
    [self.parserMangeger parserEpubSourceByFullPath:fileFullPath];
    
    [self showPageViewController];
    [self createSettingViews];
    
    if (CGAffineTransformIsIdentity(self.topView.transform)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showOrHiddenSettingViews];
        });
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.isShowStatusBar;
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
        catelogVc.parserManager = self.parserMangeger;
    }
}

#pragma mark -
- (void)createSettingViews {
    if (!self.topView) {
        self.topView = [[NSBundle mainBundle] loadNibNamed:@"ReaderTopSettingView" owner:nil options:nil].lastObject;
        self.topView.backgroundColor = [UIColor redColor];
        self.topView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 70);
        [self.view addSubview:self.topView];
    }
    
    if (!self.bottomView) {
        self.bottomView = [[NSBundle mainBundle] loadNibNamed:@"ReaderBottomSettingView" owner:nil options:nil].lastObject;
        self.bottomView.delegate = self;
        self.bottomView.backgroundColor = [UIColor redColor];
        self.bottomView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 70, CGRectGetWidth([UIScreen mainScreen].bounds), 70);
        [self.view addSubview:self.bottomView];
    }
}

- (void)showOrHiddenSettingViews {
    [UIView animateWithDuration:0.25 animations:^{
        if (self.isShowStatusBar) {
            self.topView.transform = CGAffineTransformIdentity;
            self.bottomView.transform = CGAffineTransformIdentity;
//            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
        } else {
            self.topView.transform = CGAffineTransformMakeTranslation(0, -self.topView.height);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, self.bottomView.height);
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
        }
        self.isShowStatusBar = !self.isShowStatusBar;
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
    
    NSMutableDictionary * options=[NSMutableDictionary dictionary];
    NSNumber *spineLocationValue= [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin];
    [options setObject:spineLocationValue forKey:UIPageViewControllerOptionSpineLocationKey];
    
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    self.pageViewController.view.frame = self.view.bounds;
    self.pageViewController.view.backgroundColor=[UIColor clearColor];
//    {
//        NSString *themeBodyColor=[self.arrTheme[self.themeIndex] objectForKey:@"bodycolor"];
//        UIColor *bgColor1=[self UIColorFromRGBString:themeBodyColor];
//        self.view.backgroundColor=bgColor1;
//        _pageViewController.view.backgroundColor=bgColor1;
//    }
    
    NSArray * viewControllers = nil;
    {
        EpubPageViewController *firstVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
        firstVC.delegate = self;
        firstVC.parserManager = self.parserMangeger;
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

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    EpubPageViewController *pageCurVC = (EpubPageViewController*)viewController;
    NSInteger pageRefIndex = pageCurVC.chapterIndex;
    NSInteger offYIndexInPage = pageCurVC.pageIndex;
    
    NSInteger countOfPage = [[self.parserMangeger.chapterPageInfoDic objectForKey:pageCurVC.chapterFileNameStr] integerValue];
    if (countOfPage<1) {
        return nil;
    }
    
    if (pageRefIndex == 0 ) {
        //第一页 或 没有找到
        return nil;
    }
    
    if (offYIndexInPage >0) {
        //同一页内 上滚动翻页
        EpubPageViewController *pageVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
        pageVC.delegate = self;
        pageVC.parserManager = self.parserMangeger;
        pageVC.chapterIndex = pageRefIndex;
        pageVC.pageIndex = offYIndexInPage - 1;
        
        self.pageIndex = offYIndexInPage-1;
        
        return pageVC;
    } else {
        //上一页
        EpubPageViewController *pageVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
        pageVC.delegate = self;
        pageVC.parserManager = self.parserMangeger;
        pageVC.chapterIndex = pageRefIndex-1;
        pageVC.isPreChapter = YES;
        
        self.chapterIndex = pageRefIndex-1;
        
        return pageVC;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    //对页显示要注意单数补空白
    EpubPageViewController *pageCurVC=(EpubPageViewController*)viewController;
    NSInteger pageRefIndex = pageCurVC.chapterIndex;
    NSInteger offYIndexInPage = pageCurVC.pageIndex;
    
    NSInteger countOfPage = [[self.parserMangeger.chapterPageInfoDic objectForKey:pageCurVC.chapterFileNameStr] integerValue];
    if (countOfPage < 1) {
        return nil;
    }
    
    if (pageRefIndex < 0) {
        //说明是 补充页
        return nil;
    }
    
    if (offYIndexInPage + 1 < countOfPage) {
        //同一页内 下滚动翻页
        EpubPageViewController *pageVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
        pageVC.delegate = self;
        pageVC.parserManager = self.parserMangeger;
        pageVC.chapterIndex = pageRefIndex;
        pageVC.pageIndex = offYIndexInPage + 1;
        
        self.pageIndex = offYIndexInPage + 1;
        
        return pageVC;
    } else {
        //下一页
        NSInteger pageCount = [self.parserMangeger.catelogInfoArr count];
        
        if (pageRefIndex < pageCount - 1) {
            EpubPageViewController *pageVC = [[EpubPageViewController alloc] initWithNibName:@"EpubPageViewController" bundle:nil];
            pageVC.delegate = self;
            pageVC.parserManager = self.parserMangeger;
            pageVC.chapterIndex = pageRefIndex+1;
            
            self.chapterIndex = pageRefIndex+1;
            
            return pageVC;
        }
    }
    return nil;
}

#pragma mark - UIPageViewControllerDelegate

#pragma mark - EpubPageViewControllerDelegate
- (void)singleTapEpubPageViewController:(EpubPageViewController*)epubPageViewController {
    [self showOrHiddenSettingViews];
}

- (void)doubleTapEpubPageViewController:(EpubPageViewController*)epubPageViewController {
}

- (void)epubPageViewController:(EpubPageViewController*)epubPageViewController curPageInChapter:(NSNumber*)curPage countPageInChapter:(NSNumber *)countPage; {
    self.bottomView.progressSlider.maximumValue = countPage.floatValue;
    self.bottomView.progressSlider.minimumValue = 0;
    self.bottomView.progressSlider.value = curPage.floatValue;
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
    NSInteger chapterCount = [self.parserMangeger.catelogInfoArr count];
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

#pragma mark - EpubCatalogViewControllerDelegate
- (void)epubCatalogViewController:(EpubCatalogViewController*)epubCatalogViewController jumpToChapterWithChapterIndex:(NSInteger)chapterIndex {
    if (chapterIndex >= 0 && chapterIndex < self.parserMangeger.catelogInfoArr.count) {
        self.chapterIndex = chapterIndex;
        self.pageIndex = 0;
        [self showPageViewController];
    }
}

@end
