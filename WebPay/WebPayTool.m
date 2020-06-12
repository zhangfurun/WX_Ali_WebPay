//
//  WebPayTool.m
//  WebPay
//
//  Created by ifenghui on 2020/6/12.
//  Copyright © 2020 ifenghuI. All rights reserved.
//

#import "WebPayTool.h"
#import <UIKit/UIKit.h>

@implementation WebPayTool
+ (BOOL)isNilOrEmpty:(NSString *)str {
    if (!str) {
        return YES;
    }
    NSString *temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!temp || temp.length == 0) {
        return YES;
    }
    return NO;
}

/**
 *  URLEncode
 */
+ (NSString *)URLEncodedString:(NSString *)urlStr {
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *unencodedString = urlStr;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

/**
 *  URLDecode
 */
+ (NSString *)URLDecodedString:(NSString *)urlStr {
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *encodedString = urlStr;
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

+ (NSDictionary<NSString *, NSString *> *)paramsOfUrl:(NSURL * __nullable)url {
    if (url == nil || [self isNilOrEmpty:url.absoluteString]) { return nil; }
    NSString *query = url.query;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray<NSString *> *params = [query componentsSeparatedByString:@"&"];
    for (NSString *item in params) {
        NSArray<NSString *> *kv = [item componentsSeparatedByString:@"="];
        if (!kv.firstObject || !kv.lastObject) {
            continue;
        }
        [dict setValue:kv.lastObject forKey:kv.firstObject];
    }
    return dict;
}

+ (void)handleWebUrl:(NSString *)url {
    if ([url containsString:@"fromAppUrlScheme"]) {
        NSString *encodeUrl = [url stringByRemovingPercentEncoding];
        NSArray *urlParArry = [encodeUrl componentsSeparatedByString:@"?"];
        NSMutableDictionary *beSetParDic = [self dictionaryWithJsonString:urlParArry.lastObject];
        [beSetParDic setObject:@"你的App的自定义的URL Scheme" forKey:@"fromAppUrlScheme"];
        NSString *overJsonStr = [self dictionaryToJson:beSetParDic];
        NSString *overUrlStr = [NSString stringWithFormat:@"%@?%@",urlParArry.firstObject,overJsonStr];
        NSString *canUseEncodeUrl = [overUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:canUseEncodeUrl]];
    }
}

// json格式字符串转字典
+ (NSMutableDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
    
}

// 字典转json格式字符串：
+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end


@implementation NSString (WebPayString)
- (NSString *)urlAddCompnentForValue:(NSString *)value key:(NSString *)key{
    
    NSMutableString *string = [[NSMutableString alloc]initWithString:self];
    @try {
        NSRange range = [string rangeOfString:@"?"];
        if (range.location != NSNotFound) {//找到了
            //如果?是最后一个直接拼接参数
            if (string.length == (range.location + range.length)) {
                NSLog(@"最后一个是?");
                string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
            }else{//如果不是最后一个需要加&
                if([string hasSuffix:@"&"]){//如果最后一个是&,直接拼接
                    string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,value]];
                }else{//如果最后不是&,需要加&后拼接
                    string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",key,value]];
                }
            }
        }else{//没找到
            if([string hasSuffix:@"&"]){//如果最后一个是&,去掉&后拼接
                string = (NSMutableString *)[string substringToIndex:string.length-1];
            }
            string = (NSMutableString *)[string stringByAppendingString:[NSString stringWithFormat:@"?%@=%@",key,value]];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    return string.copy;
}
@end
