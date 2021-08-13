//
//  ZLCache.m
//  ZLCache
//
//  Created by 李子龙 on 2021/8/13.
//

#import "ZLCache.h"
#import "ZLNode.h"
#import <pthread.h>

#define kDefaultMaxCacheSize 256 * 256

#define kDefaultMaxCacheDataSize 1024 * 1024 * 128

static ZLCache *instance = nil;

@interface ZLCache ()
{
    ZLNodeList *_nodeList;
    CFMutableDictionaryRef _dicRef;
    pthread_mutex_t _mutex;
    
    NSString *_diskCachePath;
    NSUInteger _totalSize; //实际cache文件大小
    NSUInteger _maxTotalSize; //cache限制的文件大小
}

@end

@implementation ZLCache

/*!
 *  获取Cache实例
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZLCache alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dicRef = CFDictionaryCreateMutable(0, kDefaultMaxCacheSize, NULL, NULL);
        pthread_mutex_init(&_mutex, NULL);
        _maxTotalSize = kDefaultMaxCacheDataSize;
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_dicRef);
    pthread_mutex_destroy(&_mutex);
}

- (void)storeCacheWithData:(NSData *)aData
                    forKey:(NSString*)aKey
{
    if (![aData isKindOfClass:[NSData class]] || ![aKey isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (aData.length == 0 || aKey.length == 0) {
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    if (CFDictionaryContainsKey(_dicRef, (__bridge const void *)aKey)) {
    } else {
        BOOL overflow = _totalSize > _maxTotalSize;
        do {
            CFIndex count = [_nodeList count];
            if (count >= kDefaultMaxCacheSize || overflow) {
                [_nodeList removeNodeWithKey:aKey];
                [self _removeDataWithKey:aKey];
            }
            overflow = _totalSize > _maxTotalSize;
        } while(overflow);
        
        _totalSize += aData.length;
        [self _insertNodeWithKey:aKey];
        CFDictionarySetValue(_dicRef, (__bridge const void *)aKey,CFDataCreate(0, aData.bytes, aData.length));
    }
    pthread_mutex_unlock(&_mutex);
}

- (NSData*)getCacheWithKey:(NSString*)aKey
{
    NSData *obj = nil;
    if (![aKey isKindOfClass:[NSString class]] || aKey.length == 0) {
        return obj;
    }
    pthread_mutex_lock(&_mutex);
    if (CFDictionaryContainsKey(_dicRef, (__bridge const void *)aKey)) {
        obj = (__bridge NSData*)CFDictionaryGetValue(_dicRef, (__bridge const void *)aKey);
    }
    pthread_mutex_unlock(&_mutex);
    return obj;
}

- (void)clearCacheWithKey:(NSString *)aKey
{
    pthread_mutex_lock(&_mutex);
    [self _removeDataWithKey:aKey];
    [_nodeList removeNodeWithKey:aKey];
    pthread_mutex_unlock(&_mutex);
}

- (void)clearAllCache
{
    pthread_mutex_lock(&_mutex);
    [_nodeList removeAllObjects];
    CFDictionaryRemoveAllValues(_dicRef);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_diskCachePath]) {
        [fileManager removeItemAtPath:_diskCachePath error:nil];
    }
    _totalSize = 0;
    pthread_mutex_unlock(&_mutex);
}

#pragma mark - private

- (void)_removeDataWithKey:(NSString*)aKey
{
    if (aKey == nil || aKey.length == 0) {
        return;
    }
    CFDataRef dataRef = CFDictionaryGetValue(_dicRef, (__bridge const void *)(aKey));
    if (dataRef) {
        _totalSize -= CFDataGetLength(dataRef);
        CFRelease(dataRef);
    }
    CFDictionaryRemoveValue(_dicRef, (__bridge const void *)(aKey));
}

- (void)_insertNodeWithKey:(NSString*)aKey
{
    if (_nodeList == nil) {
        ZLNode *node = [[ZLNode alloc] init];
        node.key = aKey;
        _nodeList = [[ZLNodeList alloc] initWithNode:node];
    } else {
        ZLNode *node = [[ZLNode alloc] init];
        node.key = aKey;
        [_nodeList insertNode:node];
    }
}

@end
