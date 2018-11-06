//
//  EpubPageViewController.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EpubParserManager.h"

@class EpubPageViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol EpubPageViewControllerDelegate <NSObject>

- (void)singleTapEpubPageViewController:(EpubPageViewController*)epubPageViewController;
- (void)doubleTapEpubPageViewController:(EpubPageViewController*)epubPageViewController;
- (void)epubPageViewController:(EpubPageViewController*)epubPageViewController curPageInChapter:(NSNumber*)curPage countPageInChapter:(NSNumber *)countPage;

@end

@interface EpubPageViewController : UIViewController

@property (weak, nonatomic) EpubParserManager *parserManager;

@property (assign, nonatomic) NSInteger chapterIndex;
@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) BOOL isPreChapter;
@property (copy, nonatomic) NSString *chapterFileNameStr;

@property (weak, nonatomic) id<EpubPageViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
