//
//  EpubCatalogViewController.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/5.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubCatalogViewController.h"

@interface EpubCatalogViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation EpubCatalogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"EpubCatalogCell"];
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
- (IBAction)onTapCloseBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.parserManager.catelogInfoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EpubCatalogCell"];
    NSDictionary *dic = [self.parserManager.catelogInfoArr objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"chapterName"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(epubCatalogViewController:jumpToChapterWithChapterIndex:)]) {
        [self.delegate epubCatalogViewController:self jumpToChapterWithChapterIndex:indexPath.row];
    }
    
    [self onTapCloseBtn:nil];
}
    

@end
