//
//  business.h
//  KLGenerateSpamCode
//
//  Created by stephen on 2019/4/29.
//  Copyright © 2019 GAEA. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 公共方法

BOOL checkArguments(NSArray<NSString *> *arguments) {
    
    printf("歡迎使用 多洛斯 Dolos，請先看過文檔，https://github.com/ttww101/Dolos \n");
//    printf("✅✅✅ 總共有 %lu 個參數\n", (unsigned long)arguments.count);
    
    if (!arguments || arguments.count <= 1) {
        printf("✅✅✅ 沒有輸入專案檔案源碼路徑\n");
        return false;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = arguments[1];
    NSError *error;
    NSArray *contents = [fm contentsOfDirectoryAtPath:path error:&error];
    
    __block BOOL hasXcodeproj = false;

    [contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(NSString*)obj containsString:@"xcodeproj"]) {
            hasXcodeproj = true;
        }
    }];

    if (hasXcodeproj) {
        printf("✅✅✅ 請檢查  “源碼路徑”  位置是否正確\n");
        return false;
    }

    if (arguments.count <= 2) {
        printf("✅✅✅ 請至少輸入下面其中一個指令 -spamCode or -handleXcassets or -deleteComments or -replaceFileDescription or \n");
        return false;
    }
    
    __block int isConflict = 0;
    
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(NSString*)obj containsString:@"deleteComments"]) {
            isConflict += 1;
        }
        if ([(NSString*)obj containsString:@"replaceFileDescription"]) {
            isConflict += 1;
        }
    }];
    
    if (isConflict == 2) {
        printf("✅✅✅ -deleteComments 跟 -replaceFileDescription 不可同時存在，不可能同時要刪除 註釋 又要同時替換 檔案描述 \n");
        return false;
    }
    
    return true;
}

NSArray* appendDefaultIgnoreDirectory(NSArray *array) {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    [temp addObject:@"Pods"];
    [temp addObject:@"Carthage"];

    printf("✅✅✅ spamCode 默認不會對 Pods 跟 Carthage 目錄底下的 file 進行掃描\n");
    
    return (NSArray*)temp;
}
