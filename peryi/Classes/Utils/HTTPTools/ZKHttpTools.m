//
//  ZKHttpTools.m
//  peryi
//
//  Created by k on 16/4/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKHttpTools.h"
#import <hpple/TFHpple.h>
#import "NSObject+ZKWebString.h"
#import "MBProgressHUD+Extend.h"


@interface ZKHttpTools()<NSURLSessionDelegate>

@end

@implementation ZKHttpTools

SingletonM(ZKHttpTools)


//=========================================主页处理分割线================================//
/**
 *  获取 m.preyi.com 主页数据
 */
- (void)getDMListDatasuccess:(void (^)(NSArray *listArr))arr{
    
    NSData *data = [self getHtmlDataWithUrl:baseURL];
    if (data != nil) {
        arr([self DMListArrayWithHtmlData:data]);
    }else{
        arr([NSArray arrayWithObjects:@"0", nil]);
    }
}

/**
 *  获取主页表单的的方法
 */
- (NSArray *)DMListArrayWithHtmlData:(NSData *)htmlData{
    
    NSMutableArray *dmlist = [NSMutableArray array];
    if (htmlData != nil) {
        TFHpple *rootDoucument = [TFHpple hppleWithHTMLData:htmlData];
        NSArray *divElements = [rootDoucument searchWithXPathQuery:@"//div[@class=\"waterfall-content-wr\"]"];
        for (TFHppleElement *liElement in divElements) {
            //用于合并解析数据
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            TFHppleElement *title = [liElement firstChildWithTagName:@"a"];
            TFHppleElement *current = [[title firstChildWithTagName:@"p"] firstChildWithTagName:@"em"];
            TFHppleElement *img = [title firstChildWithTagName:@"img"];
            if (current != nil) {
                [info addEntriesFromDictionary:title.attributes];
                [info addEntriesFromDictionary:img.attributes];
                info[@"current"] = current.text;
            }
            if (info.count != 0) {
                [dmlist addObject:info];
            }
            }//for 结束
      
    }else{
        NSLog(@"没有网页数据");

    }
      return dmlist;
}


//=========================================单个动漫页面处理分割线================================//


/**
 *  根据url获取数据的方法
 *
 *  @param url <#url description#>
 */
- (void)getDetailDMWithURL:(NSString *)url getDatasuccess:(void (^)(NSDictionary *))dict{
    url = [NSString stringWithFormat:@"%@%@",baseURL,url];
    WeakSelf;
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
        dict([weakSelf DMDetailInfoArrayWithHtmlData:listData]);
    }];
    
}


/**
 * 处理页面数据并得到当前一个页面的 动漫基本信息，播放列表 下载列表的数组
 */
- (NSDictionary *)DMDetailInfoArrayWithHtmlData:(NSData *)htmlData {
    NSMutableDictionary *dmDetial = [NSMutableDictionary dictionary];
    TFHpple *rootDoucument = [TFHpple hppleWithHTMLData:htmlData];
    NSArray *divElements = [rootDoucument searchWithXPathQuery:@"//div[@class=\"conent\"]"];
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    //动漫信息
    for (TFHppleElement *liElement in divElements) {
        TFHppleElement *img = [[liElement firstChildWithClassName:@"infos clearfix"] firstChildWithTagName:@"img"];
        [infoDict addEntriesFromDictionary:img.attributes];
        TFHppleElement *info = [[liElement firstChildWithClassName:@"infos clearfix"] firstChildWithTagName:@"p"];
        infoDict[@"about"] = [self returnHtmlArr:info.raw];
        TFHppleElement *source = [[liElement firstChildWithClassName:@"infos clearfix"] firstChildWithClassName:@"score"];
        infoDict[@"souce"] = source.text;
    }
    dmDetial[@"dmAbout"] = infoDict;
    //播放列表 list 开始
    //    NSMutableArray *plistArr = [NSMutableArray array];
    NSMutableArray *playListdic = [NSMutableArray array];
    NSArray *playDivElements = [rootDoucument searchWithXPathQuery:@"//div[@class=\"conent\"]/div[@class=\"jieshu\"]/div[@class=\"menudiv clearfix\"]"];
    for (TFHppleElement *playListElement in playDivElements) {
        TFHppleElement *tempList = [[playListElement firstChildWithTagName:@"div"] firstChildWithTagName:@"div"];
        //得到集数
        for (NSInteger i = 0; i< tempList.children.count; i++) {
            NSMutableArray *listarr = [NSMutableArray array];
            TFHppleElement *getList = tempList.children[i];
            for (NSInteger j = 0; j < getList.children.count; j++) {
                TFHppleElement *list = [getList.children[j] firstChildWithTagName:@"a"];
                if (list.attributes != nil) {
                    [listarr addObject:list.attributes];
                }
            }// 第一个for 结束
            if (listarr.count != 0 && listarr != nil) {
                [playListdic addObject:listarr];
                if (playListdic.count > 1) {
                    //优先使用网页列表中的第二播放源 - -资源更好
                    [playListdic exchangeObjectAtIndex:0 withObjectAtIndex:1];
                }
            }
        }// 第二个for 结束
    }//播放列表 list结束
    dmDetial[@"dmPlay"] = playListdic;
    //下载列表]
    NSString *infoText = nil;
    NSMutableArray *downloadList = [NSMutableArray array];
    for (TFHppleElement *downElement in playDivElements) {
        for (NSInteger i = 0;i<downElement.children.count;i++) {
            //第四个才是下载列表div
            if (i == 3) {
                TFHppleElement *downListElement = [[downElement.children[i] firstChildWithTagName:@"div"] firstChildWithTagName:@"ul"];
                for (NSInteger i = 0; i< downListElement.children.count; i++) {
                    TFHppleElement *list = [downListElement.children[i] firstChildWithTagName:@"a"];
                    if (list.children.count != 0 && list != nil) {
                        [downloadList addObject:list.attributes];
                    }
                }
            }//if结束
            if (i < 4) {
                if (i == 3) {
                    TFHppleElement *jianjie = downElement.children[i];
                    infoText = jianjie.text;
                }
            }else{
                if (i == 5) {
                    TFHppleElement *jianjie = downElement.children[i];
                    infoText = jianjie.text;
                }
            }
        }//内循环结束
    }//download 循环结束
    dmDetial[@"dmDownload"] = downloadList;
    infoText = [infoText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    infoText = [infoText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    dmDetial[@"dmSynopsis"] = [NSString stringWithFormat:@"     %@",infoText];
    /**
     *  猜你喜欢
     */
    NSMutableArray *likelist = [NSMutableArray array];
    NSArray *likeDivElements = [rootDoucument searchWithXPathQuery:@"//div[@class=\"conent\"]/div[@class=\"section\"]/ul[@class=\"plist02\"]/li"];
    for (TFHppleElement *likeElement in likeDivElements) {
        NSMutableDictionary *likeDict = [NSMutableDictionary dictionary];
        TFHppleElement *url = [likeElement firstChildWithTagName:@"a"];
        [likeDict addEntriesFromDictionary:url.attributes];
        TFHppleElement *img = [[likeElement firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
        [likeDict addEntriesFromDictionary:img.attributes];
        TFHppleElement *title = [[likeElement firstChildWithTagName:@"a"] firstChildWithTagName:@"p"];
        likeDict[@"title"] = title.text;
        [likelist addObject:likeDict];
    }
    dmDetial[@"dmYourLike"] = likelist;
    
//    [dmDetial writeToFile:@"/Users/k/Desktop/dmList.plist" atomically:YES];
    return dmDetial;
}





//=========================================新番页面处理分割线================================//
-(NSDictionary *)getNewPageList{
    NSString *url = @"http://m.peryi.com/new.html";
    [MBProgressHUD showMessage:@"请稍候..."];
    __block NSDictionary *dict = [NSDictionary  dictionary];
    WeakSelf;
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
      dict =  [weakSelf getNewPageListDataWithData:listData];
        [MBProgressHUD hideHUD];
    }];
    return dict;
}

-(NSDictionary *)getNewPageListDataWithData:(NSData *)htmlData{
    TFHpple *rootDoucument = [TFHpple hppleWithHTMLData:htmlData];
    NSArray *divElements = [rootDoucument searchWithXPathQuery:@"//div[@id=\"quarter1\"]"];
    NSMutableArray *topArr = [NSMutableArray array];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    
    for (TFHppleElement *allList in divElements) {
        TFHppleElement *top3List = [allList firstChildWithClassName:@"top3 clearfix"];
        //top 3
        for (NSInteger i = 0; i < top3List.children.count; i++) {
            TFHppleElement *topElement = top3List.children[i];
            for (NSInteger j = 0; j < topElement.children.count; j++) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                TFHppleElement *listLi = topElement.children[j];
                if (listLi.raw != nil) {
                    TFHppleElement *listLiUrl = [listLi firstChildWithTagName:@"a"];
                    if (listLiUrl.attributes != nil) {
                        [dict addEntriesFromDictionary:listLiUrl.attributes];
                        TFHppleElement *listLiImg = [listLiUrl firstChildWithTagName:@"img"];
                        [dict addEntriesFromDictionary:listLiImg.attributes];
                        TFHppleElement *listLiAbout = [listLiUrl firstChildWithTagName:@"div"];
                        dict[@"about"] =[self returnTop3Arr:[self returnHtmlArr:listLiAbout.raw]];
                        [topArr addObject:dict];
                    }
                } //去除多余
            }//内循环
        }//外循环 top3结束
        newDict[@"top3"] = topArr;
        
        newDict[@"other"] = [self commondCellWithelement:allList];
        
    }//遍历 conent结束
    return newDict;
//    [newDict writeToFile:@"/Users/k/Desktop/new.plist" atomically:YES];
}



//=========================================分类查询页面处理分割线================================//
-(void)searchHomeListgetDatasuccess:(void (^)(NSArray *listArr))arr{
    NSString *url = @"http://m.peryi.com/sou.html";
    WeakSelf;
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
        arr([weakSelf getSearchListWhitData:listData]);
    }];
}
/**
 *  获取搜索标签页面列表
 *
 */
-(NSArray *)getSearchListWhitData:(NSData *)htmlData{
    TFHpple *rootDoucument = [TFHpple hppleWithHTMLData:htmlData];
    NSArray *divElements = [rootDoucument searchWithXPathQuery:@"//div[@class=\"fenlei-list clearfix\"]"];
    NSMutableArray *allType = [NSMutableArray array];
    for (TFHppleElement *allList in divElements) {
        for (NSInteger i  = 0 ; i < allList.children.count ; i++) {
            TFHppleElement *typesList = allList.children[i];
            TFHppleElement *typeList = [typesList firstChildWithTagName:@"dd"];
            if (i == 1) {
                [allType addObject:[self forTypeWithElement:typeList]];
            }else if (i == 3){
                [allType addObject:[self forTypeWithElement:typeList]];
            }else if (i == 5){
                [allType addObject:[self forTypeWithElement:typeList]];
            }else if (i == 7){
                [allType addObject:[self forTypeWithElement:typeList]];
            }
        }//循环 结束
    }//forin结束
    return allType;
}

/**
 *  分类遍历列表
 */
-(NSMutableArray *)forTypeWithElement:(TFHppleElement *)element{
    NSMutableArray *typeArr = [NSMutableArray array];
    for (NSInteger j = 0; j < element.children.count; j++) {
        NSMutableDictionary *typeDict = [NSMutableDictionary dictionary];
        TFHppleElement *title = element.children[j] ;
        if (title.text != nil && title.attributes != nil) {
            typeDict[@"title"] = title.text;
            [typeDict addEntriesFromDictionary:title.attributes];
        }
        if (typeDict.count != 0) {
           [typeArr addObject:typeDict];
        }
        
    }
    return typeArr;
}

//=========================================按类型搜索页面处理分割线================================//
- (void)searchWithUrlStr:(NSString *)str withPage:(NSString *)pageStr getDatasuccess:(void (^)(NSDictionary *listDict))dict{
    NSString *url = nil;
    if (pageStr == nil) {
        url = [NSString stringWithFormat:@"%@%@",baseURL,str];
    }else{
        url = [NSString stringWithFormat:@"%@%@&page=%@",baseURL,str,pageStr];
    }
    WeakSelf;
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
      dict([weakSelf getTypePageListWithData:listData]);
    }];
   }

//关键词搜索
- (void)serarchWithString:(NSString *)keyword withPage:(NSString *)pageStr getDatasuccess:(void (^)(NSDictionary *listDict))dict{
    NSString *url =  nil;
    if (pageStr == nil) {
        url = [NSString stringWithFormat:@"%@/search.php?searchword=%@",baseURL,keyword];
    }else{
        url = [NSString stringWithFormat:@"%@/search.php?searchword=%@&page=%@",baseURL,keyword,pageStr];
    }
 
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
        dict([self getTypePageListWithData:listData]);
    }];
}

/**
 *  分类标签页面列表
 */
- (NSDictionary *)getTypePageListWithData:(NSData *)htmlData{
    NSMutableDictionary *allType = [NSMutableDictionary dictionary];
    
    TFHpple *rootDoucument = [TFHpple hppleWithHTMLData:htmlData];
    NSArray *divElements = [rootDoucument searchWithXPathQuery:@"//div[@id=\"quarter1\"]"];
//    NSLog(@"%@",divElements);
    for (TFHppleElement *allList in divElements) {
        allType[@"list"] = [self commondCellWithelement:allList];
    }
    
    NSString *lastPage = nil;
    NSArray *pageElements = [rootDoucument searchWithXPathQuery:@"//div[@class=\"page\"]"];
    for (TFHppleElement *pages in pageElements) {
        for (NSInteger i = 0; i < pages.children.count;i++) {
            TFHppleElement *allPage = pages.children[i];
            if ([allPage.text isEqualToString:@">"]) {
                TFHppleElement *page = pages.children[i+2];
                lastPage = [page.text substringFromIndex:2];
            }
        }
    }
    allType[@"lastPage"] = lastPage;
    return  allType;
}



//=========================================公共方法================================//
- (NSMutableArray *)commondCellWithelement:(TFHppleElement *)element{
    //otherList
    NSMutableArray *otherArr = [NSMutableArray array];
    for (NSInteger j = 0; j<element.children.count; j++) {
        NSMutableDictionary *otherAboutDict = [NSMutableDictionary dictionary];
        TFHppleElement *otherList = element.children[j];
        if (j > 0 && [otherList.tagName isEqualToString:@"div"]) {
            TFHppleElement *otherUrl = [otherList firstChildWithTagName:@"a"];
            [otherAboutDict addEntriesFromDictionary:otherUrl.attributes];
            TFHppleElement *otherImg = [otherUrl firstChildWithTagName:@"img"];
            [otherAboutDict addEntriesFromDictionary:otherImg.attributes];
            TFHppleElement *otherInfo = [otherUrl firstChildWithTagName:@"p"];
            otherAboutDict[@"about"] = [self returnNewPageHtmlArr:otherInfo.raw];
            [otherArr addObject:otherAboutDict];
        }
    }//otherList 结束
    
    return otherArr;
}


/**
 *  根据URL获取网页源码
 *
 *  @param urlStr   ur地址
 *  @param listData 返回网页数据
 */


- (void)getHtmlDataWithUrl:(NSString *)urlStr getDatasuccess:(void (^)(NSData *listData))listData{
    
    if ([urlStr rangeOfString:@"%"].location == NSNotFound) {
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }

    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSessionConfiguration *urlConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:urlConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            listData(data);
//            [MBProgressHUD showError:@"网络错误"];
        }else{
            listData(data);
        }
    }];
    
    [task resume];
}


- (NSData *)getHtmlDataWithUrl:(NSString *)urlStr{
//    __block NSData *htmlData = nil;
//    NSString *utf8String = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSURL *url = [NSURL URLWithString:utf8String];
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"GET";
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionConfiguration *urlConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    session = [NSURLSession sessionWithConfiguration:urlConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        htmlData = data;
//    }];
//    
//    [task resume];
//    
    
    NSString *utf8Strings = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *urls = [NSURL URLWithString:utf8Strings];
    NSData *data = [NSData dataWithContentsOfURL:urls];
    
    return data;
}


@end


