//
//  AppDelegate.m
//  peryi
//
//  Created by k on 16/4/25.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "AppDelegate.h"
#import "ZKSettingModel.h"
#import "ZKSettingModelTool.h"
#import "ZKDataTools.h"
#import "ZKMainController.h"
#import "ZKPlayANDStarTableVC.h"
#import "ZKNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //配置数据库文件
    [ZKDataTools sharedZKDataTools];
//    [self addDatabaseToDocument];
    
    [self detectionNetWorking];
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    if (IOS_VERSION > 9.0) {
        [self APP3DTouch];
    }
    ZKMainController *main = [[ZKMainController alloc] init];
    main.tabBar.translucent = YES;
    [self.window setRootViewController:main];
    [self.window makeKeyAndVisible];
    //友盟应用分析
    [self steupBugCrash];
    
    
    //如果已经获得发送通知的授权则创建本地通知，否则请求授权(注意：如果不请求授权在设置中是没有对应的通知设置项的，也就是说如果从来没有发送过请求，即使通过设置也打不开消息允许设置)
    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
        [self addLocalNotification];
    }else{
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    }
    
    return YES;
}

/*
 *友盟应用分析
*/
-(void)steupBugCrash{
    UMConfigInstance.appKey = @"579178df67e58e24c8004d09";
    UMConfigInstance.channelId = @"APP Store";
    NSString *UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [MobClick profileSignInWithPUID:UUID];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick setEncryptEnabled:YES];
    [MobClick setLogEnabled:NO];
    [MobClick startWithConfigure:UMConfigInstance];
}

#pragma mark 添加本地通知
-(void)addLocalNotification{

        //定义本地通知对象
        UILocalNotification *notification=[[UILocalNotification alloc]init];
        //设置调用时间
    
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger weekDay=[comp weekday];
        if (weekDay != 7 || weekDay != 1) {
            
        }
    
        notification.repeatCalendar = calendar;
        notification.timeZone = [NSTimeZone defaultTimeZone];//本地时区
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSDate *now = [formatter dateFromString:@"17:13:00"];//触发通知的时间
        notification.fireDate = now;
        notification.repeatInterval=1;//通知重复次数
        //notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
        //设置通知属性
        notification.alertBody=@"又到周末啦~快来看一看(●'◡'●)ﾉ♥？"; //通知主体
        notification.alertAction = NSLocalizedString(@"查看", nil);
        notification.alertAction=@"打开应用"; //待机界面的滑动动作提示
        notification.alertLaunchImage=@"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
        notification.soundName=UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
        notification.applicationIconBadgeNumber=1;//应用程序图标右上角显示的消息数
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];


}

-(void)detectionNetWorking{
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDbFileExist =  [fm fileExistsAtPath:ZKSettingModelPath];
    if (!isDbFileExist) {
        //默认保存的设置配置
        ZKSettingModel *model = [[ZKSettingModel alloc] init];
        model.isOpenNetwork = @"No";
        [ZKSettingModelTool saveSettingWithModel:model];
    }
    
}
/**
 *  add database to ios document
 增加数据库文件至iOS document目录
 */
- (void)addDatabaseToDocument{
    NSString *dbpath = dbpaths;
    NSString *dbBackUppath =[[NSBundle mainBundle] pathForResource:@"DMLIST" ofType:@"db"];
    BOOL isDbFileExist =  [[NSFileManager defaultManager] fileExistsAtPath:dbpath];
    if (!isDbFileExist) {
        [[NSFileManager defaultManager] copyItemAtPath:dbBackUppath toPath:dbpath error:nil];
    }
}

/**
 *  3D touch
 */
- (void)APP3DTouch{
    UIApplicationShortcutItem *shortItem1 = [[UIApplicationShortcutItem alloc] initWithType:@"搜索" localizedTitle:@"搜索" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
//    [shortItem1 ] initWithType:@"搜索" localizedTitle:@"搜索"
    UIApplicationShortcutItem *shortItem2 = [[UIApplicationShortcutItem alloc] initWithType:@"收藏列表" localizedTitle:@"收藏列表" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeFavorite] userInfo:nil];
    
    NSArray *itemArr = [NSArray arrayWithObjects:shortItem1,shortItem2, nil];
    [[UIApplication sharedApplication] setShortcutItems:itemArr];
}


+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// 接收本地通知时触发
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotificationName:getNoti object:nil];
}

//注册通知
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    if (notificationSettings.types!=UIUserNotificationTypeNone) {
        [self addLocalNotification];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
      [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];//进入前台取消应用消息图标
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ZK.peryi" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"peryi" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"peryi.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - 3DTouch 点击
- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler{
      ZKMainController *mainVC = (ZKMainController *)self.window.rootViewController;
    if ([shortcutItem.localizedTitle isEqual:@"搜索"]) {
        mainVC.selectedIndex = 1;
    }else if([shortcutItem.localizedTitle isEqual:@"收藏列表"]){
        mainVC.selectedIndex = 2;
        ZKPlayANDStarTableVC *tablVC = [[ZKPlayANDStarTableVC alloc] initControllerWithType:ZKPlayANDStartCollectionType];
        [(ZKNavigationController *)mainVC.selectedViewController pushViewController:tablVC animated:YES];
    }
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
