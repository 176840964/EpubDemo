//
//  EpubParserManager.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/23.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpubParserManager : NSObject

@property (strong, nonatomic) NSArray *catelogInfoArr;

@property (strong, nonatomic) NSMutableDictionary *chapterPageInfoDic;
@property (copy, nonatomic) NSString *contentFilesFolder;
@property (copy, nonatomic) NSString *curChapterNameStr;

- (void)parserEpubSourceByFullPath:(NSString *)fileFullPath;
- (NSString*)chapterFileNameByIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
