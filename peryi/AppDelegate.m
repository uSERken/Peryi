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
#import "ZKMainController.h"
#import "ZKPlayANDStarTableVC.h"
#import "ZKNavigationController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //配置数据库文件
    [self addDatabaseToDocument];
    
    [self detectionNetWorking];
    //延迟调用网络检测以免检测出错
//    [self performSelector:@selector(detectionNetWorking) withObject:nil afterDelay:0.25f];
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
    
 
    return YES;
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


@end
