//
//  EpubPageWebView.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubPageWebView.h"


@implementation EpubPageWebView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)loadHTMLWithPath:(NSString*)filePath jsContent:(NSString *)jsContent {
    NSString *htmlContent = [self.class HTMLContentFromFile:filePath AddJsContent:jsContent];
    NSURL *baseUrl = [NSURL fileURLWithPath:filePath];
    [self loadHTMLString:htmlContent baseURL:baseUrl];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (NSString*)HTMLContentFromFile:(NSString*)fileFullPath AddJsContent:(NSString*)jsContent {
    NSString *strHTML=nil;
    
    NSError *error=nil;
    NSStringEncoding encoding;
    NSString *strFileContent = [[NSString alloc] initWithContentsOfFile:fileFullPath usedEncoding:&encoding error:&error];
    
    if (strFileContent && [jsContent length]>1)
    {
        NSRange head1 = [strFileContent rangeOfString:@"<head>" options:NSCaseInsensitiveSearch];
        NSRange head2 = [strFileContent rangeOfString:@"</head>" options:NSCaseInsensitiveSearch];
        
        if (head1.location != NSNotFound && head2.location !=NSNotFound && head2.location > head1.location )
        {
            NSRange rangeHead = head1;
            rangeHead.length = head2.location - head1.location;
            NSString *strHead = [strFileContent substringWithRange:rangeHead];
            
            NSString *str1 = [strFileContent substringToIndex:head1.location];
            NSString *str3 = [strFileContent substringFromIndex:head2.location];
            
            NSString *strHeadEdit = [NSString stringWithFormat:@"%@\n%@", strHead, jsContent];
            
            strHTML = [NSString stringWithFormat:@"%@%@%@",str1,strHeadEdit,str3];
            
        }
    }
    else if (strFileContent)
    {
        strHTML=[NSString stringWithFormat:@"%@",strFileContent];
    }
    
    return strHTML;
}

//高亮
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@');",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    //    NSLog(@"%@", [self stringByEvaluatingJavaScriptFromString:@"console"]);
    return [[self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount;"] intValue];
}

- (void)removeAllHighlights {
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}

@end
