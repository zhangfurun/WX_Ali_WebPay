//
//  WebPayTool.h
//  WebPay
//
//  Created by ifenghui on 2020/6/12.
//  Copyright © 2020 ifenghuI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebPayTool : NSObject
+ (BOOL)isNilOrEmpty:(NSString *)str;

/**
 *  URLEncode 编码
 */
+ (NSString *)URLEncodedString:(NSString *)urlStr;

/**
 *  URLDecode 解码
 */
+ (NSString *)URLDecodedString:(NSString *)urlStr;

+ (NSDictionary<NSString *, NSString *> *)paramsOfUrl:(NSURL * __nullable)url;

+ (void)handleWebUrl:(NSString *)url;

@end

@interface NSString (WebPayString)
/**
 URL参数拼接
 注意,这里为NSString的实例方法,需要用URL的前缀进行拼接
 @param value 值
 @param key key
 @return 拼接后的url
 */
- (NSString *)urlAddCompnentForValue:(NSString *)value key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
