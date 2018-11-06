//
//  CustomFileManager.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/23.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "CustomFileManager.h"

@implementation CustomFileManager

+ (BOOL)isFileExist:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)createDirectory:(NSString *)folderPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

+ (BOOL)deleteDirectory:(NSString *)folderPath isOnlyDelFolderSubItems:(BOOL)isDelSubItems {
    if (isDelSubItems) {
        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:folderPath];
        NSString *fileName = @"";
        while (fileName = [dirEnum nextObject]) {
            NSString *delPath = [folderPath stringByAppendingPathComponent:fileName];
            if (![[NSFileManager defaultManager] removeItemAtPath:delPath error:nil]) {
                return NO;
            }
        }
    } else {
        if (![[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil]) {
            return NO;
        }
    }
    
    return YES;
}

@end
