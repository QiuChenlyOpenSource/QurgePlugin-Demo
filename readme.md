# Qurge Pro Plugin Base CMake Using CLion

本项目将为Surge带来无与伦比的极致增强体验.
目前主要计划增强软路由系统功能。

### 系统计划-软路由 (计划中)
1. Web控制器前端接口开发完善。
2. 对于前端的需求进行后端接口支持。
3. 支持原生Docker部署，一键部署Docker项目。( 后端提供Docker socket通信支持，宿主机必须安装Docker Engine or OrbStack。 )
4. 轻量级nodejs插件系统，支持部署简单的端口监听、微服务（需要宿主机存在node环境/brew安装nvm也可以）。
5. 支持端口转发系统。（暂未考虑性能问题）
6. 流量过滤、审计统计系统。
7. 计划开放更多Surge原生API。

### 状态
😭一个都没做 插件功能都有问题。

## 基础

CLion打开项目后会自动生成cmake-build文件夹, 这里存放两个二级文件夹:

1. Build 编译后这里会根据你选择的配置出来三个三级文件夹:
    1. Debug 纯编译出来的Debug版本二进制 测试用 //你们只需要用Debug就行了
    2. Release 纯编译出来的Release版本 测试用
2. BuildOut 编译时中间文件夹 里面是编译的缓存 无需理会

其中, build.sh 支持同样的编译配置: Debug Release.

### [可选操作] 配置快捷键

基于XCode按键配置后修改如下位置即可实现Command+B一键编译。
你需要手动配置快捷键:
![img.png](readme/commandb.png)

### 配置环境可能会因为装过commandline-tool导致无法编译

```bash
//切换工具目录即可
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### 如果遇到 `'/usr/local/opt/zstd/lib/libzstd.1.dylib' (no such file)`

```bash
brew install zstd
```