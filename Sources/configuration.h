//
//  marco.m
//
//
//  Created by stephen on 2019/4/26.
//  Copyright © 2019 GAEA. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kSwiftFileTemplate = @"\
%@\n\
extension %@ {\n%@\
}\n";

static NSString *const kSwiftMethodTemplate = @"\
func %@%@%@(_ %@: %@%@) {\n\
    UserDefaults.standard.setValue(%@, forKey: \"%@\")\n\
}\n";

NSArray *spamCodeVerb() {
    return [NSArray arrayWithObjects: @"Can", @"Cannot", @"Do", @"Dont", @"Should", @"Shouldnot", @"Want", @"DontWant", nil];
}

NSArray *spamCodeNoun() {
    return [NSArray arrayWithObjects: @"Sleep", @"Eat", @"Drink", @"Look", @"Listen", @"Run", @"Walk", @"Speak", @"Dance", @"Sing", @"Raise", @"Dream",
            @"Pattern", @"Scream", @"Loud", @"Climb", @"Jump", nil];
}

NSArray *spamCodePara() {
    return [NSArray arrayWithObjects: @"sender", @"para", @"message", @"listener", @"view", @"target", @"element", @"delegate", nil];
}

NSArray *spamCodeType() {
    return [NSArray arrayWithObjects: @"String", @"Bool", @"Int", @"Double", @"Float", nil];
}

NSArray *spamCodeAppendPara() {
    return [NSArray arrayWithObjects:@", title: String", @", isOk: Bool", @", contents: Float, subtitle: String", @", models: Double, title: String, isGood: Float", @", isPass: Bool", nil];
}

NSArray *spamCodeName() {
    return [NSArray arrayWithObjects: @"stephen", @"dina", @"joe", @"luke", @"wang", @"mary", @"browen", @"bryan", @"mike", @"candy", @"curry", @"smith", nil];
}

/// method 後面所增加的參數
NSArray *spamCodeOCAppendPara() {
    return [NSArray arrayWithObjects:
            @" parser:(NSXMLParser *)parser",
            @" contents:(NSArray *)array",
            @" object:(NSObject *)object",
            @" sender:(NSValue *)value",
            @" data:(NSData *)data",
            @" array:(NSArray *)array object:(NSObject *)object",
            @" source:(NSData *)data set:(NSSet *)set",
            @" aszx:(NSObject *)asd a:(NSValue *)value",
            @" asd:(NSSet *)data asd:(NSArray *)datada",
            @" dataeraa:(NSValue *)data datdfa:(NSData *)datzxaa",
            @" dsata:(NSArray *)data dasfgta:(NSObject *)daadgta daasdta:(NSValue *)dawerta",
            @" dasdgta:(NSSet *)datsdga datscva:(NSData *)dfsfata daerta:(NSValue *)dsdfata",
            @" wervxb:(NSObject *)dsgata datsfasd:(NSArray *)dataewrf daeraerta:(NSData *)sdfdeqrata",
            @" datvdsfwra:(NSSet *)datasdwer dawerweta:(NSData *)dawvdfta dasfewta:(NSValue *)dawrhdfta",
            @" datmra:(NSSet *)datfsga dawezvata:(NSObject *)daafqrgta dasfsdta:(NSArray *)datgfbgwa",
            nil];
}





