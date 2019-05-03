//
//  replaceFileDescription.h
//  KLGenerateSpamCode
//
//  Created by stephen on 2019/4/29.
//  Copyright © 2019 GAEA. All rights reserved.
//


#import <Foundation/Foundation.h>

#pragma mark - 刪除註釋跟空格

void replaceFileDescription(NSString *directory, NSArray<NSString *> *ignoreDirNames) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    
    NSString *newName = getRandomValue(spamCodeName());
    NSString *randomDate = getRandomDate();
    
    NSString *newFileDescription = [NSString stringWithFormat:@"//  Created by %@ on %@.", newName, randomDate];
    
//    printf("✅✅✅ 即將產生新的描敘黨 %s\n", [[NSString stringWithFormat:@"Created by %@ %@", newName, randomDate] UTF8String]);
    
    newName = [NSString stringWithFormat:@" by %@ on", newName];
    
    for (NSString *fileName in files) {
        if ([ignoreDirNames containsObject:fileName]) continue;
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            replaceFileDescription(filePath, ignoreDirNames);
            continue;
        }
        if (![fileName hasSuffix:@".h"] && ![fileName hasSuffix:@".m"] && ![fileName hasSuffix:@".mm"] && ![fileName hasSuffix:@".swift"]) continue;
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        regularReplacement(fileContent, @"^//.*Created.*by.*on.*", newFileDescription);
        
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}
