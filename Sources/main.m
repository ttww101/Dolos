//
//  main.m
// 
//
//  Created by Stephen on 2017/7/5.
//  Copyright © 2017年 GAEA. All rights reserved.
//

#include <stdlib.h>
#import <Foundation/Foundation.h>
#import "main.h"
#import "helper.h"
#import "configuration.h"
#import "business.h"
#import "deleteCommons.h"
#import "handleAssest.h"
#import "replaceFileDescription.h"

// 命令行修改工程目录下所有 png 资源 hash 值
// 使用 ImageMagick 进行图片压缩，所以需要安装 ImageMagick，安装方法 brew install imagemagick
// find . -iname "*.png" -exec echo {} \; -exec convert {} {} \;
// or
// find . -iname "*.png" -exec echo {} \; -exec convert {} -quality 95 {} \;

#pragma mark - 主入口

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSArray<NSString *> *arguments = [[NSProcessInfo processInfo] arguments];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if (!checkArguments(arguments)) return 1;
        
        BOOL isDirectory = NO;
        NSString *outDirString = nil;
        NSArray<NSString *> *ignoreDirNames = nil;
        BOOL needHandleXcassets = NO;
        BOOL needDeleteComments = NO;
        BOOL needReplaceFileDescription = NO;
        NSString *oldProjectName = nil;
        NSString *newProjectName = nil;
        NSString *projectFilePath = nil;
        NSString *oldClassNamePrefix = nil;
        NSString *newClassNamePrefix = nil;
        
        for (NSInteger i = 1; i < arguments.count; i++) {
            
            NSString *argument = arguments[i];
            
            if (i == 1) {
                gSourceCodeDir = argument;
                if (![fm fileExistsAtPath:gSourceCodeDir isDirectory:&isDirectory]) {
                    printf("%s ✅✅✅ 不存在\n", [gSourceCodeDir UTF8String]);
                    return 1;
                }
                if (!isDirectory) {
                    printf("%s ✅✅✅ 不是目录\n", [gSourceCodeDir UTF8String]);
                    return 1;
                }
                continue;
            }
            
            if ([argument isEqualToString:@"-handleXcassets"]) {
                needHandleXcassets = YES;
                continue;
            }
            
            if ([argument isEqualToString:@"-deleteComments"]) {
                needDeleteComments = YES;
                continue;
            }
            
            if ([argument isEqualToString:@"-replaceFileDescription"]) {
                needReplaceFileDescription = YES;
                continue;
            }
            
            if ([argument isEqualToString:@"-modifyProjectName"]) {
                
                NSString *string = arguments[++i];
                NSArray<NSString *> *names = [string componentsSeparatedByString:@">"];
                if (names.count < 2) {
                    printf("修改工程名参数错误。参数示例：CCApp>DDApp，传入参数：%s\n", string.UTF8String);
                    return 1;
                }
                oldProjectName = names[0];
                newProjectName = names[1];
                if (oldProjectName.length <= 0 || newProjectName.length <= 0) {
                    printf("修改工程名参数错误。参数示例：CCApp>DDApp，传入参数：%s\n", string.UTF8String);
                    return 1;
                }
                continue;
            }
            
            if ([argument isEqualToString:@"-modifyClassNamePrefix"]) {
                
                printf("modifyClassNamePrefix");
                
                NSString *string = arguments[++i];
                projectFilePath = [string stringByAppendingPathComponent:@"project.pbxproj"];
                if (!
                    [fm fileExistsAtPath:string isDirectory:&isDirectory]
                    || !isDirectory
                    || ![fm fileExistsAtPath:projectFilePath isDirectory:&isDirectory]
                    || isDirectory) {
                    printf("修改类名前缀的工程文件参数错误。%s", string.UTF8String);
                    return 1;
                }
                
                string = arguments[++i];
                NSArray<NSString *> *names = [string componentsSeparatedByString:@">"];
                if (names.count < 2) {
                    printf("修改类名前缀参数错误。参数示例：CC>DD，传入参数是：%s\n", string.UTF8String);
                    return 1;
                }
                
                oldClassNamePrefix = names[0];
                newClassNamePrefix = names[1];
                if (oldClassNamePrefix.length <= 0 || newClassNamePrefix.length <= 0) {
                    printf("修改类名前缀参数错误。参数示例：CC>DD，传入参数是：%s\n", string.UTF8String);
                    return 1;
                }
            
                continue;
            }
            
            if ([argument isEqualToString:@"-spamCode"]) {
                outDirString = [gSourceCodeDir stringByAppendingString:@"/DragMeToTheProject"];
                
                printf("混肴代碼即將在 %s 路徑下產生 \n", [outDirString UTF8String]);
                
                if ([fm fileExistsAtPath:outDirString isDirectory:&isDirectory]) {
                    if (isDirectory) {
                        NSError *error;
                        printf("%s 目錄已經存在，先移除，再重新創建 \n", [outDirString UTF8String]);
                        [fm removeItemAtPath:outDirString error:&error];
                    }
                } else {
                    NSError *error = nil;
                    if (![fm createDirectoryAtPath:outDirString withIntermediateDirectories:YES attributes:nil error:&error]) {
                        printf("创建输出目录失败，请确认 -spamCodeOut 之后接的是一个“输出文件夹目录”参数，错误信息如下：\n传入的输出文件夹目录：%s\n%s\n", [outDirString UTF8String], [error.localizedDescription UTF8String]);
                        return 1;
                    }
                }
                
                NSString *newClassOutDirString = [outDirString stringByAppendingPathComponent:kNewClassDirName];
                
                if ([fm fileExistsAtPath:newClassOutDirString isDirectory:&isDirectory]) {
                    if (!isDirectory) {
                        printf("%s 已存在但不是文件夹\n", [newClassOutDirString UTF8String]);
                        return 1;
                    }
                } else {
                    NSError *error = nil;
                    if (![fm createDirectoryAtPath:newClassOutDirString withIntermediateDirectories:YES attributes:nil error:&error]) {
                        printf("创建输出目录 %s 失败", [newClassOutDirString UTF8String]);
                        return 1;
                    }
                }
                /*
                 i++;
                 if (i < arguments.count) {
                 gSpamCodeFuncationCallName = arguments[i];
                 printf("✅✅✅ gSpamCodeFuncationCallName => %s \n", [gSpamCodeFuncationCallName UTF8String]);
                 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+" options:0 error:nil];
                 if ([regex numberOfMatchesInString:gSpamCodeFuncationCallName options:0 range:NSMakeRange(0, gSpamCodeFuncationCallName.length)] <= 0) {
                 printf("缺少垃圾代码函数调用名，或参数名\"%s\"不合法(需要字母开头)\n", [gSpamCodeFuncationCallName UTF8String]);
                 return 1;
                 }
                 }
                 
                 i++;
                 if (i < arguments.count) {
                 gNewClassFuncationCallName = arguments[i];
                 printf("✅✅✅ gNewClassFuncationCallName => %s \n", [gNewClassFuncationCallName UTF8String]);
                 NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+" options:0 error:nil];
                 if ([regex numberOfMatchesInString:gNewClassFuncationCallName options:0 range:NSMakeRange(0, gNewClassFuncationCallName.length)] <= 0) {
                 printf("缺少 NewClass 代码函数调用名，或参数名\"%s\"不合法(需要字母开头)\n", [gNewClassFuncationCallName UTF8String]);
                 return 1;
                 }
                 }
                 */
                continue;
            }
            
            if ([argument isEqualToString:@"-ignoreDirNames"]) {
                ignoreDirNames = [arguments[++i] componentsSeparatedByString:@","];
                continue;
            }
        }
        
        ignoreDirNames = appendDefaultIgnoreDirectory(ignoreDirNames);
        
        if (needHandleXcassets) {
            @autoreleasepool {
                handleXcassetsFiles(gSourceCodeDir);
            }
            printf("✅✅✅ 修改 Xcassets 中的圖片名稱完成 \n");
        }
        
        if (needReplaceFileDescription) {
            @autoreleasepool {
                replaceFileDescription(gSourceCodeDir, ignoreDirNames);
            }
            printf("✅✅✅ 修改 檔案的 作者，日期 完成 \n");
        }
        
        if (needDeleteComments) {
            @autoreleasepool {
                deleteComments(gSourceCodeDir, ignoreDirNames);
            }
            printf("✅✅✅ 刪除註釋 和 空格 完成 \n");
        }
        
        if (oldProjectName && newProjectName) {
            @autoreleasepool {
                NSString *dir = gSourceCodeDir.stringByDeletingLastPathComponent;
                modifyProjectName(dir, oldProjectName, newProjectName);
            }
            printf("修改工程名完成\n");
        }
        
        // Warning
        if (oldClassNamePrefix && newClassNamePrefix) {
            printf("开始修改类名前缀...\n");
            @autoreleasepool {
                // 打开工程文件
                NSError *error = nil;
                NSMutableString *projectContent = [NSMutableString stringWithContentsOfFile:projectFilePath encoding:NSUTF8StringEncoding error:&error];
                if (error) {
                    printf("打开工程文件 %s 失败：%s\n", projectFilePath.UTF8String, error.localizedDescription.UTF8String);
                    return 1;
                }
                
                modifyClassNamePrefix(projectContent, gSourceCodeDir, ignoreDirNames, oldClassNamePrefix, newClassNamePrefix);
                
                [projectContent writeToFile:projectFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            
            printf("修改类名前缀完成\n");
        }
        
        if (outDirString) {
            printf("✅✅✅ 檔案即將在 => %s 輸出 \n", [outDirString UTF8String]);
            
            NSMutableString *categoryCallImportString = [NSMutableString string];
            NSMutableString *categoryCallFuncString = [NSMutableString string];
            NSMutableString *newClassCallImportString = [NSMutableString string];
            NSMutableString *newClassCallFuncString = [NSMutableString string];
            
            recursiveDirectory(gSourceCodeDir, ignoreDirNames, ^(NSString *mFilePath) {
                @autoreleasepool {
                    generateOCSpamCodeFile(outDirString,
                                           mFilePath,
                                           GSCSourceTypeClass,
                                           categoryCallImportString,
                                           categoryCallFuncString,
                                           newClassCallImportString,
                                           newClassCallFuncString);
                    generateOCSpamCodeFile(outDirString,
                                           mFilePath,
                                           GSCSourceTypeCategory,
                                           categoryCallImportString,
                                           categoryCallFuncString,
                                           newClassCallImportString,
                                           newClassCallFuncString);
                }
            }, ^(NSString *swiftFilePath) {
                @autoreleasepool {
                    generateSwiftSpamCodeFile(outDirString, swiftFilePath);
                }
            });
            
            NSString *fileName = [getRandomValue(spamCodeNoun()) stringByAppendingString:@"CallHeader.h"];
            NSString *fileContent = [NSString stringWithFormat:@"%@\n%@return ret;\n}", categoryCallImportString, categoryCallFuncString];
            [fileContent writeToFile:[outDirString stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            fileName = [kNewClassDirName stringByAppendingString:@"CallHeader.h"];
            fileContent = [NSString stringWithFormat:@"%@\n%@return ret;\n}", newClassCallImportString, newClassCallFuncString];
            [fileContent writeToFile:[[outDirString stringByAppendingPathComponent:kNewClassDirName] stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            printf("✅✅✅ 生成垃圾代碼完成，請將 DragMeToTheProject 底下的檔案拖到專案裡面 \n");
        }
    }
    return 0;
}

#pragma mark - 生成垃圾代码

NSString * getImportString(NSString *hFileContent, NSString *mFileContent) {
    
    NSMutableString *ret = [NSMutableString string];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *[@#]import *.+" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:hFileContent options:0 range:NSMakeRange(0, hFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [hFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [mFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    return ret;
}

static NSString *const kHClassFileTemplate = @"\
%@\n\
@interface %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kMClassFileTemplate = @"\
#import \"%@+%@.h\"\n\
@implementation %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kHNewClassFileTemplate = @"\
#import <Foundation/Foundation.h>\n\
@interface %@: NSObject\n\
%@\n\
@end\n";
static NSString *const kMNewClassFileTemplate = @"\
#import \"%@.h\"\n\
@implementation %@\n\
%@\n\
@end\n";

void generateOCSpamCodeFile(NSString *outDirectory,
                            NSString *mFilePath,
                            GSCSourceType type,
                            NSMutableString *categoryCallImportString,
                            NSMutableString *categoryCallFuncString,
                            NSMutableString *newClassCallImportString,
                            NSMutableString *newClassCallFuncString) {
    
    NSString *mFileContent = [NSString stringWithContentsOfFile:mFilePath encoding:NSUTF8StringEncoding error:nil];

    NSString *regexStr;
    switch (type) {
        case GSCSourceTypeClass:
        regexStr = @" *@implementation +(\\w+)[^(]*\\n(?:.|\\n)+?@end";
        break;
        case GSCSourceTypeCategory:
        regexStr = @" *@implementation *(\\w+) *\\((\\w+)\\)(?:.|\\n)+?@end";
        break;
    }
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    
    if (matches.count <= 0) return;
    
    NSString *hFilePath = [mFilePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"h"];
    
    NSString *hFileContent = [NSString stringWithContentsOfFile:hFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 准备要引入的文件
    NSString *fileImportStrings = getImportString(hFileContent, mFileContent);
    
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull impResult, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *noun = getRandomValue(spamCodeNoun());
        
        NSString *className = [mFileContent substringWithRange:[impResult rangeAtIndex:1]];
        NSString *categoryName = nil;
        NSString *newClassName = [NSString stringWithFormat:@"%@%@%@", noun, className, randomLetter()];
        
        if (impResult.numberOfRanges >= 3) {
            categoryName = [mFileContent substringWithRange:[impResult rangeAtIndex:2]];
        }
        
        if (type == GSCSourceTypeClass) {
            // 如果该类型没有公开，只在 .m 文件中使用，则不处理
            NSString *regexStr = [NSString stringWithFormat:@"\\b%@\\b", className];
            NSRange range = [hFileContent rangeOfString:regexStr options:NSRegularExpressionSearch];
            if (range.location == NSNotFound) {
                return;
            }
        }
        
        // 查找方法
        NSString *implementation = [mFileContent substringWithRange:impResult.range];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *([-+])[^)]+\\)([^;{]+)" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:implementation options:0 range:NSMakeRange(0, implementation.length)];
        if (matches.count <= 0) return;
        
        // 新类 h m 垃圾文件内容
        NSMutableString *hNewClassFileMethodsString = [NSMutableString string];
        NSMutableString *mNewClassFileMethodsString = [NSMutableString string];
        
        // 生成 h m 垃圾文件内容
        NSMutableString *hFileMethodsString = [NSMutableString string];
        NSMutableString *mFileMethodsString = [NSMutableString string];
        
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull matche, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *noun = getRandomValue(spamCodeNoun());
            NSString *appendPara = getRandomValue(spamCodeOCAppendPara());
            NSString *verb = getRandomValue(spamCodeVerb());
            
            NSString *methodName = [[implementation substringWithRange:[matche rangeAtIndex:2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *newClassMethodName = nil;
            NSString *methodCallName = nil;
            NSString *newClassMethodCallName = nil;
            
            if ([methodName containsString:@":"]) {
                // 去掉参数，生成无参数的新名称
           
                NSArray<NSTextCheckingResult *> *matches = getMatchs(@"\\b([\\w]+) *:", methodName, 0);
                
                if (matches.count > 0) {
                    
                    NSMutableString *newMethodName = [NSMutableString string];
                    NSMutableString *newClassNewMethodName = [NSMutableString string];
                    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull matche, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *str = [methodName substringWithRange:[matche rangeAtIndex:1]];
                        [newMethodName appendString:(newMethodName.length > 0 ? str.capitalizedString : str)];
                        [newClassNewMethodName appendFormat:@"%@%@", randomLetter(), str.capitalizedString];
                    }];
                    methodCallName = [NSString stringWithFormat:@"%@%@", newMethodName, noun.capitalizedString];
                    [newMethodName appendFormat:@"%@:(NSInteger)%@", noun.capitalizedString, noun];
                    methodName = newMethodName;
                    
                    newClassMethodCallName = [NSString stringWithFormat:@"%@", newClassNewMethodName];
                    newClassMethodName = [NSString stringWithFormat:@"%@:(NSInteger)%@", newClassMethodCallName, noun];
                    
                } else {
                    methodName = [methodName stringByAppendingFormat:@" %@:(NSInteger)%@", noun, noun];
                }
            }
            else {
                newClassMethodCallName = [NSString stringWithFormat:@"%@%@", randomLetter(), methodName];
                newClassMethodName = [NSString stringWithFormat:@"%@:(NSInteger)%@", newClassMethodCallName, noun];
                
                methodCallName = [NSString stringWithFormat:@"%@%@", methodName, noun.capitalizedString];
                methodName = [methodName stringByAppendingFormat:@"%@:(NSInteger)%@", noun.capitalizedString, noun];
            }
            
            if (newClassMethodCallName.length == 0 ||
                newClassMethodName.length == 0 ||
                methodCallName.length == 0 ||
                methodName.length == 0) {
                return;
            }
       
            [hFileMethodsString appendFormat:@"+(BOOL)%@%@;\n", methodName, appendPara];
            
            [mFileMethodsString appendFormat:@"+(BOOL)%@%@ {\n", methodName, appendPara];
            [mFileMethodsString appendFormat:@"    return %@ %% %u == 0;\n", noun, arc4random_uniform(50) + 1];
            [mFileMethodsString appendString:@"}\n"];
        }];
        
        NSString *newCategoryName;
        switch (type) {
            case GSCSourceTypeClass:
            newCategoryName = noun;
            break;
            case GSCSourceTypeCategory:
            newCategoryName = [NSString stringWithFormat:@"%@%@", categoryName, noun];
            break;
        }
        
        // category m
        NSString *fileName = [NSString stringWithFormat:@"%@+%@.m", className, newCategoryName];
        NSString *fileContent = [NSString stringWithFormat:kMClassFileTemplate, className, newCategoryName, className, newCategoryName, mFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        // category h
        fileName = [NSString stringWithFormat:@"%@+%@.h", className, newCategoryName];
        fileContent = [NSString stringWithFormat:kHClassFileTemplate, fileImportStrings, className, newCategoryName, hFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [categoryCallImportString appendFormat:@"#import \"%@\"\n", fileName];
        
        // new class m
        NSString *newOutDirectory = [outDirectory stringByAppendingPathComponent:kNewClassDirName];
        fileName = [NSString stringWithFormat:@"%@.m", newClassName];
        fileContent = [NSString stringWithFormat:kMNewClassFileTemplate, newClassName, newClassName, mNewClassFileMethodsString];
        [fileContent writeToFile:[newOutDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        // new class h
        fileName = [NSString stringWithFormat:@"%@.h", newClassName];
        fileContent = [NSString stringWithFormat:kHNewClassFileTemplate, newClassName, hNewClassFileMethodsString];
        [fileContent writeToFile:[newOutDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];

        [newClassCallImportString appendFormat:@"#import \"%@\"\n", fileName];
    }];
}

void generateSwiftSpamCodeFile(NSString *outDirectory,
                               NSString *swiftFilePath) {
    
    NSString *swiftFileContent = [NSString stringWithContentsOfFile:swiftFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 查找 class 声明
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@" *(class|struct) +(\\w+)[^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:swiftFileContent options:0 range:NSMakeRange(0, swiftFileContent.length)];
    
    if (matches.count <= 0) return;
    
    NSString *fileImportStrings = getSwiftImportString(swiftFileContent);
    
    __block NSInteger braceEndIndex = 0;
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull classResult, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 已经处理到该 range 后面去了，过掉
        NSInteger matchEndIndex = classResult.range.location + classResult.range.length;
        if (matchEndIndex < braceEndIndex) return;
        
        // 是 class 方法，过掉 （假如是方法的話過濾掉）
        NSString *fullMatchString = [swiftFileContent substringWithRange:classResult.range];
        
        
        if ([fullMatchString containsString:@"("]) return;
        
        NSRange braceRange = getOutermostCurlyBraceRange(swiftFileContent, '{', '}', matchEndIndex);
        braceEndIndex = braceRange.location + braceRange.length;
        
        // 查找方法
        NSString *classContent = [swiftFileContent substringWithRange:braceRange];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"func +([^(]+)\\([^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:classContent options:0 range:NSMakeRange(0, classContent.length)];
        if (matches.count <= 0) return;
        
        NSMutableString *methodsString = [NSMutableString string];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull funcResult, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange funcNameRange = [funcResult rangeAtIndex:1];
            NSString *funcName = [classContent substringWithRange:funcNameRange];
            
            if (![funcName containsString:@"<"] && ![funcName containsString:@">"]) {
                
                NSString *verb = getRandomValue(spamCodeVerb());
                NSString *noun = getRandomValue(spamCodeNoun());
                NSString *para = getRandomValue(spamCodePara());
                NSString *type = getRandomValue(spamCodeType());
                NSString *appendPara = getRandomValue(spamCodeAppendPara());
                
                [methodsString appendFormat:kSwiftMethodTemplate,
                 funcName,
                 verb,
                 noun,
                 para,
                 type,
                 appendPara,
                 para,
                 para];
                //                 printf("✅✅✅✅✅✅ methodsString => %s \n", [methodsString UTF8String]);
            }
        }];
        
        if (methodsString.length <= 0) return;
        
        NSString *className = [swiftFileContent substringWithRange:[classResult rangeAtIndex:2]];
        
        NSString *fileName = [NSString stringWithFormat:@"%@+Extension.swift", className];
        NSString *filePath = [outDirectory stringByAppendingPathComponent:fileName];
        NSString *fileContent = @"";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        fileContent = [fileContent stringByAppendingFormat:kSwiftFileTemplate, fileImportStrings, className, methodsString];
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
}

#pragma mark - 修改工程名

void resetEntitlementsFileName(NSString *projectPbxprojFilePath, NSString *oldName, NSString *newName) {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"CODE_SIGN_ENTITLEMENTS = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"entitlements"]];
        renameFile(entitlementsPath, newPath);
    }];
}

void resetBridgingHeaderFileName(NSString *projectPbxprojFilePath, NSString *oldName, NSString *newName) {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"SWIFT_OBJC_BRIDGING_HEADER = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"h"]];
        renameFile(entitlementsPath, newPath);
    }];
}

void replacePodfileContent(NSString *filePath, NSString *oldString, NSString *newString) {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"target +'%@", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"target '%@", newString]];
    }];
    
    regularExpression = [NSString stringWithFormat:@"project +'%@.", oldString];
    expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"project '%@.", newString]];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void replaceProjectFileContent(NSString *filePath, NSString *oldString, NSString *newString) {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:newString];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void modifyFilesClassName(NSString *sourceCodeDir, NSString *oldClassName, NSString *newClassName);

void modifyProjectName(NSString *projectDir, NSString *oldName, NSString *newName) {
    NSString *sourceCodeDirPath = [projectDir stringByAppendingPathComponent:oldName];
    NSString *xcodeprojFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcodeproj"];
    NSString *xcworkspaceFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcworkspace"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // old-Swift.h > new-Swift.h
    modifyFilesClassName(projectDir, [oldName stringByAppendingString:@"-Swift.h"], [newName stringByAppendingString:@"-Swift.h"]);
    
    // 改 Podfile 中的工程名
    NSString *podfilePath = [projectDir stringByAppendingPathComponent:@"Podfile"];
    if ([fm fileExistsAtPath:podfilePath isDirectory:&isDirectory] && !isDirectory) {
        replacePodfileContent(podfilePath, oldName, newName);
    }
    
    // 改工程文件内容
    if ([fm fileExistsAtPath:xcodeprojFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 project.pbxproj 文件内容
        NSString *projectPbxprojFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.pbxproj"];
        if ([fm fileExistsAtPath:projectPbxprojFilePath]) {
            resetBridgingHeaderFileName(projectPbxprojFilePath, [oldName stringByAppendingString:@"-Bridging-Header"], [newName stringByAppendingString:@"-Bridging-Header"]);
            resetEntitlementsFileName(projectPbxprojFilePath, oldName, newName);
            replaceProjectFileContent(projectPbxprojFilePath, oldName, newName);
        }
        // 替换 project.xcworkspace/contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.xcworkspace/contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            replaceProjectFileContent(contentsXcworkspacedataFilePath, oldName, newName);
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        renameFile(xcodeprojFilePath, [[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcodeproj"]);
    }
    
    // 改工程组文件内容
    if ([fm fileExistsAtPath:xcworkspaceFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            replaceProjectFileContent(contentsXcworkspacedataFilePath, oldName, newName);
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        renameFile(xcworkspaceFilePath, [[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcworkspace"]);
    }
    
    // 改源代码文件夹名称
    if ([fm fileExistsAtPath:sourceCodeDirPath isDirectory:&isDirectory] && isDirectory) {
        renameFile(sourceCodeDirPath, [projectDir stringByAppendingPathComponent:newName]);
    }
}

#pragma mark - 修改类名前缀

void modifyFilesClassName(NSString *sourceCodeDir, NSString *oldClassName, NSString *newClassName) {
    // 文件内容 Const > DDConst (h,m,swift,xib,storyboard)

    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            modifyFilesClassName(path, oldClassName, newClassName);
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"] || [fileName hasSuffix:@".m"] || [fileName hasSuffix:@".pch"] || [fileName hasSuffix:@".swift"] || [fileName hasSuffix:@".xib"] || [fileName hasSuffix:@".storyboard"]) {
            
            NSError *error = nil;
            NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("打开文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
            
            NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldClassName];
            BOOL isChanged = regularReplacement(fileContent, regularExpression, newClassName);
            if (!isChanged) continue;
            error = nil;
            [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("保存文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
        }
    }
}

void modifyClassNamePrefix(NSMutableString *projectContent, NSString *sourceCodeDir, NSArray<NSString *> *ignoreDirNames, NSString *oldName, NSString *newName) {
    printf("modifyClassNamePrefix");
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 遍历源代码文件 h 与 m 配对，swift
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            if (![ignoreDirNames containsObject:filePath]) {
                modifyClassNamePrefix(projectContent, path, ignoreDirNames, oldName, newName);
            }
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent.stringByDeletingPathExtension;
        NSString *fileExtension = filePath.pathExtension;
        NSString *newClassName;
        if ([fileName hasPrefix:oldName]) {
            newClassName = [newName stringByAppendingString:[fileName substringFromIndex:oldName.length]];
        } else {
            //处理是category的情况。当是category时，修改+号后面的类名前缀
            NSString *oldNamePlus = [NSString stringWithFormat:@"+%@",oldName];
            if ([fileName containsString:oldNamePlus]) {
                NSMutableString *fileNameStr = [[NSMutableString alloc] initWithString:fileName];
                [fileNameStr replaceCharactersInRange:[fileName rangeOfString:oldNamePlus] withString:[NSString stringWithFormat:@"+%@",newName]];
                newClassName = fileNameStr;
            }else{
                newClassName = [newName stringByAppendingString:fileName];
            }
        }
        
        // 文件名 Const.ext > DDConst.ext
        if ([fileExtension isEqualToString:@"h"]) {
            NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
            if ([files containsObject:mFileName]) {
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                renameFile(oldFilePath, newFilePath);
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"m"];
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"m"];
                renameFile(oldFilePath, newFilePath);
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
                if ([fm fileExistsAtPath:oldFilePath]) {
                    newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                    renameFile(oldFilePath, newFilePath);
                }
                
                @autoreleasepool {
                    modifyFilesClassName(gSourceCodeDir, fileName, newClassName);
                }
            } else {
                continue;
            }
        } else if ([fileExtension isEqualToString:@"swift"]) {
            
            NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"swift"];
            NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"swift"];
            renameFile(oldFilePath, newFilePath);
            oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
            if ([fm fileExistsAtPath:oldFilePath]) {
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                renameFile(oldFilePath, newFilePath);
            }
            
            @autoreleasepool {
                modifyFilesClassName(gSourceCodeDir, fileName.stringByDeletingPathExtension, newClassName);
            }
        } else {
            continue;
        }
        
        // 修改工程文件中的文件名
        NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", fileName];
        regularReplacement(projectContent, regularExpression, newClassName);
    }
}

