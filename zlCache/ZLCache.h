//
//  ZLCache.h
//  ZLCache
//
//  Created by 李子龙 on 2021/8/13.
//

#import <Foundation/Foundation.h>

@interface ZLCache : NSObject

/*!
 *  获取Cache实例
 */
+ (instancetype)sharedInstance;

/*!
 *  缓存数据
 *
 *  @param aData    缓存数据
 *  @param aKey     缓存key
 *
 */
- (void)storeCacheWithData:(NSData *)aData
                    forKey:(NSString*)aKey;

/*!
 *  获取缓存数据
 *
 *  @param aKey     缓存key
 *
 *  @result 缓存数据
 */
- (NSData *)getCacheWithKey:(NSString*)aKey;

/*!
 *  根据key清除缓存数据
 *
 *  @param aKey     缓存key
 */
- (void)clearCacheWithKey:(NSString*)aKey;

@end
