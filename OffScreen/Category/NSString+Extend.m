//
//  NSString+Extend.m
//
//  Created by 苏沫离 on 2018/2/16.
//

#import "NSString+Extend.h"

@implementation NSString (Extend)

+ (NSString *)getEnglishFromChinese:(NSString *)chineseString{
    if (chineseString && chineseString.length)
    {
        NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:chineseString];
        CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO);
//        CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO);
        NSString *capitalPinyin = [pinyinText capitalizedString];
        return capitalPinyin;
    }
    return @"";
}

+ (NSString *)getFirstLetterFromChinese:(NSString *)chineseString
{
    if (chineseString && chineseString.length)
    {
        NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:chineseString];
        CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO);
        NSString *capitalPinyin = [pinyinText capitalizedString];
        return [capitalPinyin substringToIndex:1];
    }
    return @"";
}

+ (BOOL)checkSpecialCharacter:(NSString *)firstLetter
{
    NSString *regex = @"[A-Za-z]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isSpecial =[predicate evaluateWithObject:firstLetter];
    return !isSpecial;
}

///字符串是否为纯数字
- (BOOL)isAllNumber{
    if (self.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

@end





@implementation NSString (Array)

/** 数组转换成字符串
 *  @return 字符串
 */
+ (NSString *)stringFromeArray:(NSArray<NSString *> *)array separator:(NSString *)separator{
    NSMutableString *mutableString = [NSMutableString string];
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableString appendFormat:@"%@", obj];
        if (idx < array.count - 1 && separator) {
            [mutableString appendString:separator];
        }
    }];
    return mutableString;
}

@end
