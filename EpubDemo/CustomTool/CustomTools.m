//
//  CustomTools.m
//  EpubDemo
//
//  Created by 张晓龙 on 2018/11/6.
//  Copyright © 2018 张晓龙. All rights reserved.
//

#import "CustomTools.h"

@implementation CustomTools
+ (UIColor*)UIColorFromRGBString:(NSString*)strRGB {
    UIColor *ret=nil;
    
    NSString *rgb=[strRGB stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *rgba=nil;
    if ([rgb length] == 6) {
        rgba=[NSString stringWithFormat:@"ff%@",rgb];
    }
    else if ([rgb length] == 8)
    {
        rgba=rgb;
    }
    
    if (rgba) {
        ret=[self NSStringToUIColor:rgba];
    }
    
    return ret;
}

+ (UIColor*)NSStringToUIColor:(NSString*)strColor
{
    // string 转 uicolor rgba
    if ([strColor length] != 8)
    {
        return [UIColor clearColor];
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //a
    NSString *aString = [strColor substringWithRange:range];
    if ([aString isEqualToString:@"00"]) {
        aString=@"ff";
    }
    //r
    range.location = 2;
    NSString *rString = [strColor substringWithRange:range];
    
    //g
    range.location = 4;
    NSString *gString = [strColor substringWithRange:range];
    
    //b
    range.location = 6;
    NSString *bString = [strColor substringWithRange:range];
    
    unsigned int r, g, b,a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:((float) a / 255.0f)];
}

@end
