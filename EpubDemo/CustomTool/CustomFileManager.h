//
//  CustomFileManager.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/23.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomFileManager : NSObject

+ (BOOL)isFileExist:(NSString *)path;
+ (BOOL)createDirectory:(NSString *)folderPath;
+ (BOOL)deleteDirectory:(NSString *)folderPath isOnlyDelFolderSubItems:(BOOL)isDelSubItems;

@end

NS_ASSUME_NONNULL_END
