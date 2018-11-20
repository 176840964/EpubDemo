//
//  EpubSearchViewController.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/7.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubSearchViewController.h"
#import "EpubPageWebView.h"

@interface EpubSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIWebViewDelegate>
@property (strong, atomic) NSCondition *condition;
@property (strong, nonatomic) EpubPageWebView *pageView;
@property (copy, nonatomic) NSString *chapterNameStr;
@end

@implementation EpubSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.condition = [[NSCondition alloc] init];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SearchCell"];
    
    self.pageView = [[EpubPageWebView alloc] init];
    self.pageView.parserManager = self.parserManager;
    CGSize size = self.parserManager.settingManager.containerSize;
    self.pageView.webView.frame = CGRectMake(0, 0, size.width, size.height);
    self.pageView.webView.delegate = self;
    
    if (self.parserManager.settingManager.currentSearchText.length > 0) {
        self.searchBar.text = self.parserManager.settingManager.currentSearchText;
        [self.tableView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction
- (IBAction)onTapBackBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.parserManager.settingManager.searchResultArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    NSDictionary *searchItem = [self.parserManager.settingManager.searchResultArr objectAtIndex:indexPath.row];
    NSInteger pageIndex = [searchItem[@"pageIndex"] integerValue] + 1;
    NSString *chapterName = [searchItem objectForKey:@"chapterName"];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%@）...%@...", chapterName, @(pageIndex), searchItem[@"neighboringText"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(epubSearchViewController:chapterIndex:pageIndex:)]) {
        NSDictionary *searchItem = [self.parserManager.settingManager.searchResultArr objectAtIndex:indexPath.row];
        NSInteger chapterIndex = [[searchItem objectForKey:@"chapterIndex"] integerValue];
        NSInteger pageIndex = [[searchItem objectForKey:@"pageIndex"] integerValue];
        [self.delegate epubSearchViewController:self chapterIndex:chapterIndex pageIndex:pageIndex];
        [self onTapBackBtn:nil];
    }
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *text = searchBar.text;
    if (text.length <= 0) {
        self.parserManager.settingManager.currentSearchText = @"";
        [self.parserManager.settingManager.searchResultArr removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    [self.parserManager.settingManager.searchResultArr removeAllObjects];
    
    self.parserManager.settingManager.currentSearchText = text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger index = 0; index < self.parserManager.catelogInfoArr.count; index ++) {
            NSDictionary *chapterDic = [self.parserManager.catelogInfoArr objectAtIndex:index];
            self.chapterNameStr = [chapterDic objectForKey:@"chapterName"];
            NSString *fileNameStr = [chapterDic objectForKey:@"chapterFile"];
            NSString *filePath = [NSString stringWithFormat:@"%@%@", self.parserManager.contentFilesFolder, fileNameStr];
            
            NSString *htmlContent = [EpubPageWebView HTMLContentFromFile:filePath AddJsContent:self.parserManager.jsContent];
            NSRange range = NSMakeRange(0, htmlContent.length);
            range = [htmlContent rangeOfString:text options:NSCaseInsensitiveSearch range:range locale:nil];
            NSInteger findCount = 0;
            while (range.location != NSNotFound) {
                range = NSMakeRange(range.location+range.length, [htmlContent length]-(range.location+range.length));
                range = [htmlContent rangeOfString:text options:NSCaseInsensitiveSearch range:range locale:nil];
                ++ findCount;
            }
            
            if (findCount > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.pageView.webView.tag = index;
                    [self.pageView loadHTMLWithChapterFileName:fileNameStr jsContent:self.parserManager.jsContent];
                });
                
                [self.condition lock];
                [self.condition wait];
                [self.condition unlock];
            }
        }
    });
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar endEditing:YES];
    searchBar.text=@"";
    self.parserManager.settingManager.currentSearchText = @"";
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView*)webView {
    NSInteger isFind=[self.pageView highlightAllOccurencesOfString:self.searchBar.text];
    if (isFind) {
        NSString *foundHits = [webView stringByEvaluatingJavaScriptFromString:@"results"];
        
        NSMutableArray* objects = [[NSMutableArray alloc] init];
        
        NSArray* stringObjects = [foundHits componentsSeparatedByString:@";"];
        for(int i=0; i<[stringObjects count]; i++){
            NSArray* strObj = [[stringObjects objectAtIndex:i] componentsSeparatedByString:@","];
            if([strObj count]==3){
                [objects addObject:strObj];
            }
        }
        
        NSArray* orderedRes = [objects sortedArrayUsingComparator:^(id obj1, id obj2){
            int x1 = [[obj1 objectAtIndex:0] intValue];
            int x2 = [[obj2 objectAtIndex:0] intValue];
            int y1 = [[obj1 objectAtIndex:1] intValue];
            int y2 = [[obj2 objectAtIndex:1] intValue];
            if(y1<y2){
                return NSOrderedAscending;
            } else if(y1>y2){
                return NSOrderedDescending;
            } else {
                if(x1<x2){
                    return NSOrderedAscending;
                } else if (x1>x2){
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        
        //NSLog(@"find chapterIndex=%d,orderedResCount=%d",chapterIndex,[orderedRes count]);
        
        @synchronized(self.parserManager.settingManager.searchResultArr) {
            for(NSInteger index = 0; index < orderedRes.count; index++) {
                NSArray* currObj = [orderedRes objectAtIndex:index];
                NSInteger pageIndex = [[currObj objectAtIndex:1] integerValue] / webView.bounds.size.height;
                
                NSMutableDictionary *searchItem=[NSMutableDictionary dictionary];
                [searchItem setObject:[NSString stringWithFormat:@"%@",@(webView.tag)] forKey:@"chapterIndex"];
                [searchItem setObject:[NSString stringWithFormat:@"%@",@(pageIndex)] forKey:@"pageIndex"];
                
                NSString *neighboringText = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"unescape('%@')", [currObj objectAtIndex:2]]] ;
                [searchItem setObject:neighboringText forKey:@"neighboringText"];
                [searchItem setObject:self.chapterNameStr forKey:@"chapterName"];
                
                [self.parserManager.settingManager.searchResultArr addObject:searchItem];
                
            }
        }
    }
    
    [self.condition lock];
    [self.condition signal];
    [self.condition unlock];
    
    [self.tableView reloadData];
}
    
@end
