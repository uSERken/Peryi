//
//  Singelon.h
//  Where's My Delivery
//
//  Created by k on 16/1/28.
//  Copyright © 2016年 ZK. All rights reserved.
//

#define SingletonH(methodName) + (instancetype)shared##methodName;

#define SingletonM(methodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
if (_instace == nil) { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super allocWithZone:zone]; \
}); \
} \
return _instace; \
} \
\
- (id)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super init]; \
}); \
return _instace; \
} \
\
+ (instancetype)shared##methodName \
{\
NSString *dbpath = dbpaths;\
NSString *dbBackUppath =[[NSBundle mainBundle] pathForResource:@"DMLIST" ofType:@"db"];\
BOOL isDbFileExist =  [[NSFileManager defaultManager] fileExistsAtPath:dbpath];\
if (!isDbFileExist) {\
[[NSFileManager defaultManager] copyItemAtPath:dbBackUppath toPath:dbpath error:nil];\
}\
return [[self alloc] init]; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
}