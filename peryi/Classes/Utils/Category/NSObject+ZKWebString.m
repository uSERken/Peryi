//
//  NSObject+ZKWebString.m
//  WorkSystem
//
//  Created by k on 15/10/16.
//  Copyright © 2015年 ZK. All rights reserved.
//

#import "NSObject+ZKWebString.h"

@implementation NSObject (ZKWebString)


/**
 *  详情也页面返回的about信息
 *
 */
- (NSMutableDictionary *)returnHtmlArr:(NSString *)html{
    //@"<[^>]*>|\n"
    
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>"
                                                                                    options:0
                                                                                      error:nil];
   NSString *dealHtml=[regularExpretion stringByReplacingMatchesInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length) withTemplate:@""];
    NSArray *arr=[NSArray array];
    //分割
    arr =  [dealHtml componentsSeparatedByString:@"&#13;"];
    NSMutableArray *marr=[NSMutableArray arrayWithArray:arr];
    [marr removeObject:@""];
    

    //祛除特殊字符
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSInteger i = 0; i < marr.count; i++) {
        if (i == 0) {
            dict[@"classification"] = [self removeListOtherText:marr[i]];
        }else if(i == 1){
            dict[@"update"] = [self removeListOtherText:marr[i]];
        }else if (i == 2){
            dict[@"updateTime"] = [self removeListOtherText:marr[i]];
        }
    }
    
    return dict;
}

- (NSString *)removeListOtherText:(NSString*)string{
    NSString *text = nil;
    if (string != nil) {
        if (string.length < 4) {
            text = [string substringFromIndex:3];
        }else{
            text = [string substringFromIndex:5];
        }
    }
    return text;
}

/**
 *  top3 about 信息
 <div class="c">
 <h2>一拳超人</h2>
 <p><em></em>第12集</p>
 <p><em></em>90475</p>
 <p><em></em>日本动漫</p>
 </div>
 解析出来的信息里分段处理后格式为固定。若网页更改顺序此处也需更改
 */
- (NSMutableDictionary *)returnTop3Arr:(NSMutableArray *)arr{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i<arr.count; i++) {
        if (i == 0) {
                dict[@"title"] =  [self removeOtherWithString:arr[i]];
        }else if(i == 1){
                dict[@"update"] =  [self removeOtherWithString:arr[i]];
        }else if(i == 2){
                dict[@"attention"] = [self removeOtherWithString:arr[i]];
        }
    }
    return dict;
}

- (NSString *)removeOtherWithString:(NSString *)string{
    
    if (string.length > 3) {
        string  = [string substringFromIndex:3];
    }
    return string;
}

/**
 *  新番页面返回的about信息
 * <p class="iconfont"><em></em>第4集 <em></em>8746<br>
 《我的英雄学院》讲述改编自日本漫画家堀越耕平同名漫画作品。..
 </p>
 理由同上
 */
- (NSMutableDictionary *)returnNewPageHtmlArr:(NSString *)html{
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>"
                                                                                    options:0
                                                                                      error:nil];
    NSString *dealHtml=[regularExpretion stringByReplacingMatchesInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length) withTemplate:@","];
    NSArray *arr=[NSArray array];
    //分割
    arr =  [dealHtml componentsSeparatedByString:@","];
    NSMutableArray *marr=[NSMutableArray arrayWithArray:arr];
    [marr removeObject:@" "];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < marr.count; i++) {
        if (i == 3) {
            dict[@"update"] = [self removeNewpageAboutText:marr[i]];
        }else if (i == 5){
            dict[@"attention"] = [self removeNewpageAboutText:marr[i]];
        }else if (i == 6){
             dict[@"synopsis"] = [self removeNewpageAboutText:marr[i]];
        }
    }
    
    return dict;
}

- (NSString *)removeNewpageAboutText:(NSString *)string{
    NSString *retrunString = nil;
    if (![string isEqualToString:@""]) {
        if (string.length > 1) {
            retrunString = string;
        }
    }
    return retrunString;
}


@end
