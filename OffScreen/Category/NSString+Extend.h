//
//  NSString+Extend.h
//
//  Created by 苏沫离 on 2018/2/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extend)

+ (NSString *)getEnglishFromChinese:(NSString *)chineseString;

+ (NSString *)getFirstLetterFromChinese:(NSString *)chineseString;

+ (BOOL)checkSpecialCharacter:(NSString *)firstLetter;

///字符串是否为纯数字
- (BOOL)isAllNumber;

@end



@interface NSString (Array)

/** 数组转换成字符串
 *  @param separator 分隔符
 *  @return 字符串
 */
+ (NSString *)stringFromeArray:(NSArray<NSString *> *)array separator:(NSString *)separator;

@end

NS_ASSUME_NONNULL_END
