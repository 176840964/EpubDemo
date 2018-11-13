//
//  EpubPageWebView.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/10/24.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "EpubPageWebView.h"
#import "CustomFileManager.h"

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

+ (NSString*)jsContentWithSetting:(ReaderSettingManager*)settingManager {
    
    NSString *js0 = @"";
    if (settingManager.currentFontIndex == 1) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DFPShaoNvW5.ttf" ofType:nil];
        js0 = [self jsFontStyle:path];
    }
    
    NSString *js1=@"<style>img {  max-width:100% ; }</style>\n";
    
    //    NSArray *arrJs2=@[@"<script>"
    //                      ,@"var mySheet = document.styleSheets[0];"
    //                      ,@"function addCSSRule(selector, newRule){"
    //                      ,@"if (mySheet.addRule){"
    //                      ,@"mySheet.addRule(selector, newRule);"
    //                      ,@"} else {"
    //                      ,@"ruleIndex = mySheet.cssRules.length;"
    //                      ,@"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"
    //                      ,@"}"
    //                      ,@"}"
    //                      ,@"addCSSRule('p', 'text-align: justify;');"
    //                      ,@"addCSSRule('p', 'line-height: 1;');"
    //                      ,@"addCSSRule('highlight', 'background-color: yellow;');"
    //                      //,@"addCSSRule('body', '-webkit-text-size-adjust: 100%; font-size:10px;');"
    //                      ,@"addCSSRule('body', ' font-size:18px;');"
    //                      ,@"addCSSRule('body', ' font-family:\"fontName\"');"
    //                      ,@"addCSSRule('body', ' background-color:#000000');"
    //                      ,@"addCSSRule('h1', ' color:#ffffff"');"
    //                      ,@"addCSSRule('h2', ' color:#ffffff"');"
    //                      ,@"addCSSRule('p', ' color:#ffffff"');"
    //                      ,@"addCSSRule('body', ' margin:2.2em 5%% 0 5%%;');"   //上，右，下，左 顺时针
    //                      ,@"addCSSRule('html', 'padding: 0px; height: 480px; -webkit-column-gap: 0px; -webkit-column-width: 320px;');"
    //                      ,@"</script>"];
    
    NSMutableArray *arrJs=[NSMutableArray array];
    [arrJs addObject:@"<script>"];
    [arrJs addObject:@"var mySheet = document.styleSheets[0];"];
    [arrJs addObject:@"function addCSSRule(selector, newRule){"];
    [arrJs addObject:@"if (mySheet.addRule){"];
    [arrJs addObject:@"mySheet.addRule(selector, newRule);"];
    [arrJs addObject:@"} else {"];
    [arrJs addObject:@"ruleIndex = mySheet.cssRules.length;"];
    [arrJs addObject:@"mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"];
    [arrJs addObject:@"}"];
    [arrJs addObject:@"}"];
    
    [arrJs addObject:@"addCSSRule('p', 'text-align: justify;');"];
    {//行间距
        // <p>
        NSString *addcss_spacing1 = [NSString stringWithFormat:@"addCSSRule('p', 'line-height: %@;');", @(settingManager.currentSpacingIndex)];
        [arrJs addObject:addcss_spacing1];//字的行间距 默认是1 或者 使用px方式 默认值是20px
        
        // <p class="content">
        NSString *addcss_spacing2 = [NSString stringWithFormat:@"addCSSRule('p.content', 'line-height: %@;');", @(settingManager.currentSpacingIndex)];
        [arrJs addObject:addcss_spacing2];//字的行间距 默认是1 或者 使用px方式 默认值是20px
    }
    {//搜索高亮
        NSString *themeHighlightColor = [settingManager.themeArr[settingManager.currentThemeIndex] objectForKey:@"highlight"];
        NSString *addcss_hightlight = [NSString stringWithFormat:@"addCSSRule('highlight', 'background-color: %@;');", themeHighlightColor];
        [arrJs addObject:addcss_hightlight];
    }
    {//字号
        NSString *addcss_fontSize = [NSString stringWithFormat:@"addCSSRule('body', ' font-size:%@px;');", @(settingManager.currentTextSize)];
        [arrJs addObject:addcss_fontSize];
    }
    {//字体
        NSString *fontName = [[settingManager.fontArr objectAtIndex:settingManager.currentFontIndex] objectForKey:@"fontName"];
        NSString *addcss_font = [NSString stringWithFormat:@"addCSSRule('body', ' font-family:\"%@\";');", fontName];
        [arrJs addObject:addcss_font];
    }
    {//背景主题
        NSString *themeBodyColor = [settingManager.themeArr[settingManager.currentThemeIndex] objectForKey:@"body"];
        NSString *addcss_bodyColor = [NSString stringWithFormat:@"addCSSRule('body', 'background-color: %@;')", themeBodyColor];
        [arrJs addObject:addcss_bodyColor];
        
        NSString *themeTextColor=[settingManager.themeArr[settingManager.currentThemeIndex] objectForKey:@"text"];
        NSString *addcss_h1TextColor = [NSString stringWithFormat:@"addCSSRule('h1', 'color: %@;')", themeTextColor];
        [arrJs addObject:addcss_h1TextColor];
        NSString *addcss_h2TextColor = [NSString stringWithFormat:@"addCSSRule('h2', 'color: %@;')", themeTextColor];
        [arrJs addObject:addcss_h2TextColor];
        NSString *addcss_h3TextColor = [NSString stringWithFormat:@"addCSSRule('h3', 'color: %@;')", themeTextColor];
        [arrJs addObject:addcss_h3TextColor];
        NSString *addcss_pTextColor = [NSString stringWithFormat:@"addCSSRule('p', 'color: %@;')", themeTextColor];
        [arrJs addObject:addcss_pTextColor];
    }
    [arrJs addObject:@"addCSSRule('body', ' margin:0 0 0 0;');"];//上，右，下，左 顺时针
    {
        NSString *css1=[NSString stringWithFormat:@"addCSSRule('html', 'padding: 0px; height: %@px; -webkit-column-gap: 0px; -webkit-column-width: %@px;');",@(settingManager.containerSize.height),@(settingManager.containerSize.width)];//padding 内边距属性 ； -webkit-column-gap 列间距 ； -webkit-column-width 列宽
        [arrJs addObject:css1];
    }
    
    [arrJs addObject:@"</script>"];
    
    NSString *jsJoin = [arrJs componentsJoinedByString:@"\n"];
    
    NSString *jsRet = [NSString stringWithFormat:@"%@\n%@\n%@",js0,js1,jsJoin];
    return jsRet;
}

+ (NSString*)jsFontStyle:(NSString*)fontFilePath {
    //注意 fontName, DFPShaoNvW5.ttf 如果改为 aa.ttf, 那么fontname也应该是“DFPShaoNvW5”，
    //fontName是系统认的名称,非文件名， 我这里把文件名改了，参考本文件的 customFontWithPath 方法得到真正的fontName
    NSString *fontFile = [fontFilePath lastPathComponent];
    NSString *fontName = [fontFile stringByDeletingPathExtension];
    //NSString *jsFont=@"<style type=\"text/css\"> @font-face{ font-family: 'DFPShaoNvW5'; src: url('DFPShaoNvW5-GB.ttf'); } </style> ";
    NSString *jsFontStyle = [NSString stringWithFormat:@"<style type=\"text/css\"> @font-face{ font-family: '%@'; src: url('%@'); } </style>", fontName, fontFile];
    
    return jsFontStyle;
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

- (NSString *)getImageContentFromPoint:(CGPoint)point {
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", point.x, point.y];
    NSString *tagName = [self stringByEvaluatingJavaScriptFromString:js];
    if ([[tagName uppercaseString] isEqualToString:@"IMG"]) {
        NSString *imgUrl = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", point.x, point.y];
        NSString *fileUrl = [self stringByEvaluatingJavaScriptFromString:imgUrl];
        NSString *filePath = [fileUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""].stringByRemovingPercentEncoding;
        
        if ([CustomFileManager isFileExist:filePath]) {
            return filePath;
        }
    }
    return nil;
}

@end
