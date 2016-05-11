//
//  NSObject+ZKWebString.h
//  WorkSystem
//
//  Created by k on 15/10/16.
//  Copyright © 2015年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZKWebString)

/**
 *  去除字符串钟含有的网页标签 <> </>等
 *
 *  @param html 含有<> </>等的字符串
 *
 *  @return 返回内容
 */

/**
*  详情也页面返回的about信息
*
*/
- (NSMutableArray *)returnHtmlArr:(NSString *)html;

/**
 *  top3 about 信息
 */
- (NSMutableArray *)returnTop3Arr:(NSMutableArray *)arr;

/**
 *  新番页面返回的about信息
 *
 */
- (NSMutableArray *)returnNewPageHtmlArr:(NSString *)html;



@end
