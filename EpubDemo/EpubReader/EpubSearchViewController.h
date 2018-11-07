//
//  EpubSearchViewController.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/7.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EpubSearchViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol EpubSearchViewControllerDelegate <NSObject>

- (void)epubSearchViewController:(EpubSearchViewController*)epubSearchViewController chapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex;

@end

@interface EpubSearchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) EpubParserManager *parserManager;

@property (weak, nonatomic) id<EpubSearchViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
