//
//  InjectLib.mm
//  InjectLib
//
//  Created by 秋城落叶 on 2024.8.23.
//
/**
 ***********************************************************************************************
 *              C O N F I D E N T I A L  ---  Q I U C H E N L U O Y E  T E A M S               *
 *                                本项目仅供参考学习之目的                                         *
 ***********************************************************************************************
 */

#import "MyPlugin.h"
#include "Foundation/NSURLSession.h"

API *mainAPI;

NSMutableArray<NSString *> *keywordsList;

// 将 JSON 字符串转换为 NSDictionary
NSDictionary *jsonStringToDictionary(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (!dictionary) {
        NSLog(@"从 JSON 字符串转换为 NSDictionary 失败: %@", error.localizedDescription);
        return nil;
    }

    return dictionary;
}

// NSArray 转换为 JSON 字符串
NSString *arrayToJSONString(NSArray *array) {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];

    if (!jsonData) {
        NSLog(@"转换为 JSON 失败: %@", error.localizedDescription);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

// JSON 字符串转换回 NSArray
NSArray *jsonStringToArray(NSString *jsonString) {
    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (!array) {
        NSLog(@"从 JSON 字符串转换为 NSArray 失败: %@", error.localizedDescription);
        return nil;
    } else {
        return array;
    }
}


NSString *cvtBase64(NSString *base64) {
    // Base64 解码
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];

    // 将解码后的数据转换为字符串
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

BOOL checkBlackListNodeKeyName(NSString *testName) {
    // 定义关键词列表
    NSArray *kList = @[@"剩余", @"到期"];

    // 遍历列表中的关键词
    for (NSString *keyword in kList) {
        // 如果 testName 中包含任意关键词
        if ([testName containsString:keyword]) {
            return NO;// 返回 false
        }
    }

    return YES;// 如果没有关键词匹配，返回 true
}

NSString *parseSSServerInfo(NSString *ss) {
    auto server = [ss componentsSeparatedByString:@"#"];
    auto name = [server[1] stringByRemovingPercentEncoding];
    server = [server[0] componentsSeparatedByString:@"@"];

    auto server_ports = [server[1] componentsSeparatedByString:@":"];
    auto serverDomain = server_ports[0];
    auto serverPort = server_ports[1];

    server = [server[0] componentsSeparatedByString:@"//"];
    auto decodePassword = cvtBase64(server[1]);
    server = [decodePassword componentsSeparatedByString:@":"];
    auto respond = [NSString stringWithFormat:@"%@ = %@, %@, %@, encrypt-method=%@, password=%@, tfo=false, udp-relay=true", name, @"ss", serverDomain, serverPort, server[0], server[1]];
    return respond;
}


NSString *getDemoList(NSString *url, NSString *method, NSDictionary *header, NSDictionary *queryParams, NSString *body) {
    return mainAPI->backend->buildResponseJSON(
            200,
            @{
                @"Content-Type": @"application/json; charset=utf-8"
            },
            @{
                @"code": @"这是插件接口 list API."
            });
}

NSString *getDemoHome(NSString *url, NSString *method, NSDictionary *header, NSDictionary *queryParams, NSString *body) {
    return mainAPI->backend->buildResponseJSON(
            200,
            @{
                @"Content-Type": @"application/json; charset=utf-8"
            },
            @{
                @"code": @"这是插件主页,可以返回index.html来提供WebUI访问."
            });
}

NSString *parseCvt(NSString *url, NSString *method, NSDictionary *header, NSDictionary *queryParams, NSString *body) {
    // 目标 URL
    NSString *urlString = (NSString *) queryParams[@"url"];
    NSURL *sUrl = [NSURL URLWithString:urlString];

    // 创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    // 初始化数据和错误对象
    __block NSString *responseData = nil;
    __block NSError *responseError = nil;

    // 创建 NSURLSession
    NSURLSession *session = [NSURLSession sharedSession];

    // 创建同步任务
    // 创建 NSMutableURLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:sUrl];

    // 添加自定义的 HTTP 头字段
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Thunder Client (https://www.thunderclient.com)" forHTTPHeaderField:@"User-Agent"];

    // 创建同步任务
    NSURLSessionDataTask *dataTask = [session
            dataTaskWithRequest:request
              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                auto str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                str = cvtBase64(str);
                // 分割换行
                auto lst = [str componentsSeparatedByString:@"\r\n"];

                auto line = @"# Create By QiuChenly for Qurge 2024.08.26\n[Proxy]\n";
                for (NSString *i in lst) {
                    // 判断如果是ss://
                    if ([i hasPrefix:@"ss://"]) {
                        auto mLine = parseSSServerInfo(i);
                        if (checkBlackListNodeKeyName(mLine)) {
                            line = [line stringByAppendingString:mLine];
                            line = [line stringByAppendingString:@"\n"];
                        }
                    }
                }

                if (error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                    responseError = error;
                } else {
                    responseData = [line copy];
                }

                // 发送信号量，解除阻塞
                dispatch_semaphore_signal(semaphore);
              }];
    // 启动任务
    [dataTask resume];

    // 等待信号量，阻塞线程直到任务完成
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return mainAPI->backend->buildResponse(
            200,
            @{
                @"Content-Type": @"text/plain; charset=utf-8"
            },
            responseData);
}

NSString *allKeywords(NSString *url, NSString *method, NSDictionary *header, NSDictionary *queryParams, NSString *body) {
    auto allwords = mainAPI->storage->getStringByKey(mainAPI, @"kwds");

    if (!allwords) allwords = arrayToJSONString(keywordsList);

    return mainAPI->backend->buildResponseJSON(
            200,
            @{
                @"Content-Type": @"application/json; charset=utf-8"
            },
            @{
                @"list": jsonStringToDictionary(allwords)
            });
}

NSString *addKeywords(NSString *url, NSString *method, NSDictionary *header, NSDictionary *queryParams, NSString *body) {
    auto b = jsonStringToDictionary(body);
    NSString *ky = b[@"keyword"];
    [keywordsList addObject:ky];
    mainAPI->storage->setStringByKey(mainAPI, @"kwds", arrayToJSONString(keywordsList));
    return mainAPI->backend->buildResponseJSON(200, @{@"Content-Type": @"application/json; charset=utf-8"}, @{@"code": @0});
}

NSString *deleteKeywords(NSString *url, NSString *method, NSDictionary *header, NSDictionary *queryParams, NSString *body) {}

void handleSubStore() {
    mainAPI->backend->registerURL(@"/sub-store/cvt", @"GET", parseCvt);
}


PluginInfo *onLoad(API *api) {
    NSLog(@"===== loadPlugins ====");
    auto *info = new PluginInfo();
    info->version = 1;
    info->pluginId = @"com.qiuchenly.demo.plugin";
    info->name = @"Demo Plugin";
    info->author = @"QiuChenly";
    info->type = @"系统增强";

    // 设置插件数据隔离 避免其他插件访问到本插件的数据 必须要设置 否则我会让你强制崩溃
    api->namespaceId = info->pluginId;
    // END
    mainAPI = api;

    api->backend->registerURL(@"/demo/", @"GET", getDemoHome);

    api->backend->registerURL(@"/demo/list", @"GET", getDemoList);

    api->backend->registerURL(@"/sub-store/allKeywords", @"GET", allKeywords);

    // 提交数据 {"keyword":"订阅"}
    api->backend->registerURL(@"/sub-store/addKeywords", @"POST", addKeywords);

    // 提交数据 {"keyword":"订阅"}
    api->backend->registerURL(@"/sub-store/deleteKeywords", @"POST", deleteKeywords);

    handleSubStore();

    keywordsList = [[NSMutableArray alloc] initWithCapacity:0];

    auto allwords = mainAPI->storage->getStringByKey(mainAPI, @"kwds");

    if (allwords)
        [keywordsList addObjectsFromArray:jsonStringToArray(allwords)];

    auto isFirstOpen = api->storage->getStringByKey(mainAPI, @"isFirstOpen");
    NSLog(@"is First = %@", isFirstOpen);
    api->storage->setStringByKey(mainAPI, @"isFirstOpen", @"false");
    return info;
}

int onUnload() {
    NSLog(@"====== unloadPlugins ====");
    return 0;
}
