//
//  EpubParserManager.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/23.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubParserManager.h"
#import "ZipArchive.h"
#import "CustomFileManager.h"
#import "GDataXMLNode.h"

#define Epub_opf_xmlns @"http://www.idpf.org/2007/opf"
#define Epub_ncx_xmlns @"http://www.daisy.org/z3986/2005/ncx/"

@interface EpubParserManager ()
@property (copy, nonatomic) NSString *unzipEpubFolder;
@property (copy, nonatomic) NSString *opfFilePath;
@property (copy, nonatomic) NSString *ncxFilePath;

@property (strong, nonatomic) NSMutableDictionary *metadataDic;
@property (strong, nonatomic) NSMutableArray *spineItemrefArr;
@property (strong, nonatomic) NSMutableDictionary *manifestItemDic;
@property (strong, nonatomic) NSMutableDictionary *navMapDic;
@end

@implementation EpubParserManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.chapterPageInfoDic = [NSMutableDictionary dictionary];
        self.metadataDic = [NSMutableDictionary dictionary];
        self.spineItemrefArr = [NSMutableArray array];
        self.manifestItemDic = [NSMutableDictionary dictionary];
        self.navMapDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)parserEpubSourceByFullPath:(NSString *)fileFullPath {
    if (fileFullPath.length > 0) {
        NSString *fileName = [[fileFullPath lastPathComponent] stringByDeletingPathExtension];
        
        NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        NSString *cachesPath = [libraryPath stringByAppendingPathComponent:@"Caches"];
        NSString *epbuCachePath = [cachesPath stringByAppendingPathComponent:@"epubcache"];
        self.unzipEpubFolder = [NSString stringWithFormat:@"%@/%@", epbuCachePath, fileName];
        NSLog(@"unzipEpubFolder:%@", self.unzipEpubFolder);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.unzipEpubFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.unzipEpubFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *containerFilePath = [NSString stringWithFormat:@"%@/META-INF/container.xml", self.unzipEpubFolder];
        if (![[NSFileManager defaultManager] fileExistsAtPath:containerFilePath]) {
            if (![self openFilePath:fileFullPath]) {
                NSLog(@"epub 解压失败");
                return;
            }
        }
        
        [self parserContainerFile:containerFilePath];
        [self parserOpfFile];
        [self parserNcxFile];
        self.catelogInfoArr = [NSArray arrayWithArray:[self getCatelogArr]];
    }
}

- (NSString*)chapterFileNameByIndex:(NSInteger)index {
    if (index >= 0 && index < self.catelogInfoArr.count) {
        NSDictionary *dic = [self.catelogInfoArr objectAtIndex:index];
        self.curChapterNameStr = [dic objectForKey:@"chapterName"];
        return [dic objectForKey:@"chapterFile"];
    }
    
    return nil;
}

#pragma mark -
- (BOOL)openFilePath:(NSString *)fileFullPath {
    if (![CustomFileManager isFileExist:fileFullPath] || ![CustomFileManager isFileExist:self.unzipEpubFolder]) {
        return NO;
    }
    
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile:fileFullPath]) {
        [CustomFileManager deleteDirectory:self.unzipEpubFolder isOnlyDelFolderSubItems:YES];
        BOOL unzip = [za UnzipFileTo:[NSString stringWithFormat:@"%@/", self.unzipEpubFolder] overWrite:YES];
        [za UnzipCloseFile];
        
        if (!unzip) {
            return NO;
        }
    }
    
    return YES;
}

- (void)parserContainerFile:(NSString *)containerFileFullPath {
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:containerFileFullPath];
    if (xmlData) {
        NSError *err = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if (0 == [err code]) {
            GDataXMLElement *root = [doc rootElement];
            NSArray *nodes = [root nodesForXPath:@"//@full-path[1]" error:nil];
            if (0 < nodes.count) {
                GDataXMLElement *opfNode = nodes.firstObject;
                self.opfFilePath = [NSString stringWithFormat:@"%@/%@", self.unzipEpubFolder, opfNode.stringValue];
                NSLog(@"opfFilePath:%@", self.opfFilePath);
                
                NSInteger index = [self.opfFilePath rangeOfString:@"/" options:NSBackwardsSearch].location;
                NSString *parentPath = [self.opfFilePath substringToIndex:(index +1)];
                self.contentFilesFolder = parentPath;
                NSLog(@"contentFilesFolder:%@", self.contentFilesFolder);
                
            } else {
                NSLog(@"解析 manifest 未找到opf路径节点");
            }
        } else {
            NSLog(@"解析 manifest 错误 ,err=%@", err);
        }
    } else {
        NSLog(@"manifest 内容为空,file=%@", containerFileFullPath);
    }
}

- (void)parserOpfFile {
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:self.opfFilePath];
    if (xmlData) {
        NSError *err = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if (0 == err.code) {
            
            NSDictionary *namespaceDic=[NSDictionary dictionaryWithObject:Epub_opf_xmlns forKey:@"opf"];
            
            GDataXMLElement *root = [doc rootElement];
            {//ncx
                NSArray *nodes = [root nodesForXPath:@"//opf:item[@id='ncx']" namespaces:namespaceDic error:nil];
                if (1 > nodes.count){
                    nodes = [root nodesForXPath:@"//item[@id='ncx']" namespaces:namespaceDic error:nil];
                }
                if (0 < nodes.count) {
                    GDataXMLElement *element = nodes.firstObject;
                    NSString *itemhref = [[element attributeForName:@"href"] stringValue];
                    NSString *ncxFileName = itemhref;
                    if (0 < ncxFileName.length) {
                        self.ncxFilePath = [NSString stringWithFormat:@"%@/%@", self.contentFilesFolder, ncxFileName];
                        NSLog(@"ncxFilePath:%@", self.ncxFilePath);
                    }
                }
            }
            {//metadata
                NSArray *metadataArr = [root nodesForXPath:@"//opf:metadata" namespaces:namespaceDic error:nil];
                if (0 < metadataArr.count) {
                    GDataXMLElement *node = [metadataArr firstObject];
                    for (GDataXMLElement *child in [node children]) {
                        NSString *name = child.name;
                        NSString *value = child.stringValue;
                        [self.metadataDic setObject:value forKey:name];
                    }
                    NSLog(@"metadataDic:%@", self.metadataDic);
                }
            }
            {//spine
                NSArray *spineArr = [root nodesForXPath:@"//opf:itemref" namespaces:namespaceDic error:nil];
                if (1 > spineArr.count) {
                    spineArr = [root nodesForXPath:@"//spine[@toc='ncx']/itemref" namespaces:namespaceDic error:nil];
                }
                if (0 < spineArr.count) {
                    for (GDataXMLElement *element in spineArr) {
                        NSString *idref = [element attributeForName:@"idref"].stringValue;
                        if (idref && idref.length > 0) {
                            [self.spineItemrefArr addObject:idref];
                        }
                    }
                    NSLog(@"spineItemrefArr:%@", self.spineItemrefArr);
                }
            }
            {//manifest
                NSArray *spineArr = [root nodesForXPath:@"//opf:manifest/opf:item" namespaces:namespaceDic error:nil];
                if (0 < spineArr.count) {
                    for (GDataXMLElement *item in spineArr) {
                        NSString *itemId = [item attributeForName:@"id"].stringValue;
                        NSString *itemHref = [item attributeForName:@"href"].stringValue;
                        NSString *itemType = [item attributeForName:@"media-type"].stringValue;
                        NSLog(@"itemId:%@, itemHref:%@", itemId, itemHref);
                        
                        if (itemId.length > 0 && itemHref.length > 0) {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic setObject:itemHref.length > 0 ? itemHref : @"" forKey:@"href"];
                            [dic setObject:itemType.length > 0 ? itemId : @"" forKey:@"type"];
                            
                            [self.manifestItemDic setObject:dic forKey:itemId];
                        }
                    }
                    NSLog(@"manifestItemDic:%@", self.manifestItemDic);
                }
            }
            
        } else {
            NSLog(@"解析 opf 错误 ,err=%@", err);
        }
    }
}

- (void)parserNcxFile {
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:self.ncxFilePath];
    if (xmlData) {
        NSError *err = nil;
        GDataXMLDocument *ncxXmlDoc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&err];
        if (0 == err.code) {
            GDataXMLElement *root = [ncxXmlDoc rootElement];
            NSDictionary *namespaceDic=[NSDictionary dictionaryWithObject:Epub_ncx_xmlns forKey:@"ncx"];
            NSArray *navPoints= [root nodesForXPath:@"ncx:navMap/ncx:navPoint" namespaces:namespaceDic error:nil];
            if (1 > navPoints.count) {
                navPoints = [root nodesForXPath:@"ncx:navPoint" namespaces:namespaceDic error:nil];
            }
            for (GDataXMLElement *navPoint in navPoints) {
                NSString *nId = [[navPoint attributeForName:@"id"] stringValue];
                NSString *playOrder = [[navPoint attributeForName:@"playOrder"] stringValue];
                
                
                NSArray *textNodes = [navPoint nodesForXPath:@"ncx:navLabel/ncx:text" namespaces:namespaceDic error:nil];
                NSString *navLabelText = @"";
                if (0 < textNodes.count) {
                    GDataXMLElement *nodeLabel = textNodes.firstObject;
                    navLabelText = [nodeLabel stringValue];
                }
                
                NSArray *contentNodes = [navPoint nodesForXPath:@"ncx:content" namespaces:namespaceDic error:nil];
                NSString *contentSrc = @"";
                if ([contentNodes count] > 0) {
                    GDataXMLElement *nodeContent = contentNodes.firstObject;
                    contentSrc = [[nodeContent attributeForName:@"ncx:src"] stringValue];
                }
                
                if (contentSrc.length > 0) {
                    NSMutableDictionary *chapterDic = [NSMutableDictionary dictionary];
                    [chapterDic setObject:[nId length] > 0 ? nId : @"" forKey:@"id"];
                    [chapterDic setObject:[playOrder length] > 0 ? playOrder : @"" forKey:@"playOrder"];
                    [chapterDic setObject:[navLabelText length] > 0 ? navLabelText : @"" forKey:@"text"];
                    NSLog(@"chapterDic:%@", chapterDic);
                    
                    [self.navMapDic setObject:chapterDic forKey:contentSrc];
                }
            }
        }
    }
}

- (NSArray *)getCatelogArr {
    NSMutableArray *catelogArr = [NSMutableArray array];
    for (NSString *chapterId in self.spineItemrefArr) {
        NSString *chapterFile = @"";
        NSString *chapterName = chapterId;
        NSDictionary *dic = [self.manifestItemDic objectForKey:chapterId];
        if (dic) {
            chapterFile = [dic objectForKey:@"href"];
            NSDictionary *itemDic = [self.navMapDic objectForKey:chapterFile];
            if (itemDic) {
                chapterName = [itemDic objectForKey:@"text"];
            }
        }
        
        [catelogArr addObject:@{@"chapterId":chapterId, @"chapterFile":chapterFile, @"chapterName": chapterName}];
    }
    
    return catelogArr;
}

@end
