//
//  EpubCatalogViewController.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/5.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EpubCatalogViewController;

@protocol EpubCatalogViewControllerDelegate <NSObject>

- (void)epubCatalogViewController:(EpubCatalogViewController*)epubCatalogViewController jumpToChapterWithChapterIndex:(NSInteger)chapterIndex;

@end

@interface EpubCatalogViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) EpubParserManager *parserManager;
@property (weak, nonatomic) id<EpubCatalogViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
