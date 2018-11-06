//
//  EpubPageWebView.h
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpubPageWebView : UIWebView

- (void)loadHTMLWithPath:(NSString*)filePath jsContent:(NSString *)jsContent;

+ (NSString*)HTMLContentFromFile:(NSString*)fileFullPath AddJsContent:(NSString*)jsContent;
@end

NS_ASSUME_NONNULL_END
