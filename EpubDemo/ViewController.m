//
//  ViewController.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/23.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "ViewController.h"
#import "EpubReaderViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *booksArr;
@property (assign, nonatomic) NSInteger bookIndex;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"bookCell"];
    
    self.booksArr = @[@"盗墓笔记", @"饮食业成本核算", @"“八个必须坚持”学习读本", @"《实践论》《矛盾论》导读", @"保持共产党员先进性教育学习文件导读", @"为人处世曾国藩", @"云林堂饮食制度集"];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEpubReaderViewController"]) {
        EpubReaderViewController *vc = segue.destinationViewController;
        vc.bookNameStr = [self.booksArr objectAtIndex:self.bookIndex];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booksArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bookCell"];
    NSString *bookName = [self.booksArr objectAtIndex:indexPath.row];
    cell.textLabel.text = bookName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.bookIndex = indexPath.row;
    [self performSegueWithIdentifier:@"showEpubReaderViewController" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
