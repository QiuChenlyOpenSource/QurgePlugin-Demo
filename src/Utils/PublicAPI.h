#ifndef PublicAPIHeader
#define PublicAPIHeader

#include <Foundation/Foundation.h>
#include "AppKit/AppKit.h"

using namespace std;

#include "iostream"

#ifdef OPENAPI
#define OpenAPI __attribute__((visibility("default")))
#else
#define OpenAPI
#endif

typedef struct Storage {
    NSString *(*getStringByKey)(struct API *api, NSString *key);

    bool (*setStringByKey)(struct API *api, NSString *key, NSString *value);

    NSString *storagePath;
} Storage;

typedef NSString *(*UrlCallbackType)(NSString *url, NSString *method, NSDictionary *header, NSDictionary *queryParams, NSString *body);
typedef bool (*RegisterURL)(NSString *url, NSString *method, UrlCallbackType callback);
typedef NSString *(*ResponseJSON)(int code, NSDictionary *header, NSDictionary *responseJSON);
typedef NSString *(*ResponseBody)(int code, NSDictionary *header, NSString *responseJSON);

typedef struct Backend {
    RegisterURL registerURL;
    ResponseBody buildResponse;
    ResponseJSON buildResponseJSON;
} Backend;

typedef struct API {
    /**
     * 后端接口注册
     */
    Backend *backend;
    /**
     * 本地存储相关
     */
    Storage *storage;
    /**
     * 默认public数据库
     */
    NSString *namespaceId = @"public";

    API() {
        backend = new Backend;
        storage = new Storage;
    }

    ~API() {
        delete backend;
        delete storage;
    }
} API;

typedef struct PluginInfo {
    /**
     * 插件版本号
     */
    int version;
    /**
     * 插件唯一ID标识符
     */
    NSString *pluginId;
    /**
     * 插件名称
     */
    NSString *name;
    /**
     * 插件作者
     */
    NSString *author;
    /**
     * 插件类型
     */
    NSString *type;

    /**
     * 打开窗口函数
     * 如果你这个插件不需要原生UI窗口，直接这个结构体的值赋值为nullptr，这样在插件中心就会显示灰色的打开窗口按钮(不可点击)
     * 如果需要窗口，那么就需要指定一个函数接收事件
     * @param window 初始化好的一个window对象 直接获取contentView向内部增加控件即可 [目前是nullptr 还没做好这个]
     */
    void (*OpenWindow)(NSWindow *window);
    /**
     * 插件加载事件
     */
    void (*onLoad) (API *api);
    /**
     * 插件卸载事件
     * @return 插件退出返回值
     */
    int (*onUnload)();
} PluginInfo;

extern "C" {
    /**
     * 加载插件信息
     * @return
     */
    OpenAPI PluginInfo* getPluginInfo();
}

#endif /* PublicAPIHeader */
