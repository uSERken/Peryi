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
- (NSArray *)getDMLIST{
    [MBProgressHUD showMessage:@"请稍候..."];
     NSArray *arr = [NSArray array];
//    __weak __typeof(self) weakSelf = self;
//    [self getHtmlDataWithUrl:baseURL getDatasuccess:^(NSData *listData){
//
//      arr = [weakSelf DMListArrayWithHtmlData:listData];
//    }];
//    
//    NSLog(@"list:%@",arr);
    
    NSData *data = [self getHtmlDataWithUrl:baseURL];
    arr = [self DMListArrayWithHtmlData:data];
    [MBProgressHUD hideHUD];
    
    return arr;
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
            if (i == 5) {
                TFHppleElement *jianjie = downElement.children[i];
                infoText = jianjie.text;
            }
        }//内循环结束
    }//download 循环结束
    dmDetial[@"dmDownload"] = downloadList;
    dmDetial[@"dmSynopsis"] = infoText;
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

- (NSMutableArray *)commondCellWithelement:(TFHppleElement *)element{
    //otherList
    NSMutableArray *otherArr = [NSMutableArray array];
    for (NSInteger j = 0; j<element.children.count; j++) {
        NSMutableDictionary *otherAboutDict = [NSMutableDictionary dictionary];
        TFHppleElement *otherList = element.children[j];
        if (j > 1 && otherList.raw != nil) {
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

//=========================================分类查询页面处理分割线================================//
-(NSDictionary *)searchHomeList{
    NSString *url = @"http://m.peryi.com/sou.html";
    [MBProgressHUD showMessage:@"请稍候..."];
    __block NSDictionary *dict = [NSDictionary  dictionary];
    WeakSelf;
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
      dict = [weakSelf getSearchListWhitData:listData];
        [MBProgressHUD hideHUD];
    }];
    return dict;
}
/**
 *  获取搜索标签页面列表
 *
 */
-(NSDictionary *)getSearchListWhitData:(NSData *)htmlData{
    TFHpple *rootDoucument = [TFHpple hppleWithHTMLData:htmlData];
    NSArray *divElements = [rootDoucument searchWithXPathQuery:@"//div[@class=\"fenlei-list clearfix\"]"];
    NSMutableDictionary *allType = [NSMutableDictionary dictionary];
    for (TFHppleElement *allList in divElements) {
        for (NSInteger i  = 0 ; i < allList.children.count ; i++) {
            TFHppleElement *typesList = allList.children[i];
            TFHppleElement *typeList = [typesList firstChildWithTagName:@"dd"];
            if (i == 1) {
                allType[@"type"] = [self forTypeWithElement:typeList];
            }else if (i == 3){
                allType[@"yearType"] = [self forTypeWithElement:typeList];
            }else if (i == 5){
                allType[@"languageType"] = [self forTypeWithElement:typeList];
            }else if (i == 7){
                allType[@"versionType"] = [self forTypeWithElement:typeList];
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
        [typeArr addObject:typeDict];
    }
    return typeArr;
}

//=========================================搜索页面处理分割线================================//
- (NSDictionary *)searchWithUrl:(NSString *)url{
    [MBProgressHUD showMessage:@"请稍候..."];
    __block NSDictionary *dict = [NSDictionary dictionary];
    WeakSelf;
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
      dict = [weakSelf getTypePageListWithData:listData];
        [MBProgressHUD hideHUD];
    }];
    return dict;
}

/**
 *  分类标签页面列表
 */
- (NSDictionary *)getTypePageListWithData:(NSData *)htmlData{
    NSMutableDictionary *allType = [NSMutableDictionary dictionary];
    
    TFHpple *rootDoucument = [TFHpple hppleWithHTMLData:htmlData];
    NSArray *divElements = [rootDoucument searchWithXPathQuery:@"//div[@id=\"quarter1\"]"];
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
//    [allType writeToFile:@"/Users/k/Desktop/search.plist" atomically:YES];
}

- (NSDictionary *)serarchWithString:(NSString *)keyword{
    NSString *url = [NSString stringWithFormat:@"%@/search.php?searchword=%@",baseURL,keyword];
    __block NSDictionary *dict = [NSDictionary dictionary];
    [self getHtmlDataWithUrl:url getDatasuccess:^(NSData *listData) {
       dict = [self getTypePageListWithData:listData];
    }];
    return dict;
}

//=========================================公共方法================================//

/**
 *  根据URL获取网页源码
 *
 *  @param urlStr   ur地址
 *  @param listData 返回网页数据
 */


- (void)getHtmlDataWithUrl:(NSString *)urlStr getDatasuccess:(void (^)(NSData *listData))listData{
    
    NSString *utf8String = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:utf8String];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionConfiguration *urlConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:urlConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"错误:%@",error);
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


