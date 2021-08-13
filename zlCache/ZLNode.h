//
//  ZLNode.h
//  ZLNode
//
//  Created by 李子龙 on 2021/8/13.
//

#import <Foundation/Foundation.h>

@interface ZLNode : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) ZLNode *pre;
@property (nonatomic, strong) ZLNode *next;

@end


@interface ZLNodeList : NSObject

@property (nonatomic, strong) ZLNode *head;
@property (nonatomic, strong) ZLNode *tail;

- (instancetype)initWithNode:(ZLNode*)aNode;

- (void)insertNode:(ZLNode*)aNode;

- (void)removeNodeWithKey:(NSString *)aKey;

- (NSInteger)count;

- (void)removeAllObjects;

@end
