# Xcode-AutoLazyLoad

![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)
![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)

![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg?style=flat-square)

## Xcode-AutoLazyLoad使用

在Xcode toolbar中选中edit，选中指定行的代码，执行指定的插件指令。

[![npm](https://github.com/Dtheme/AutoLazyLoad/blob/master/gif116.gif?raw=true)]()

Xcode 8的插件是以扩展的形式使用的，类似于sifari插件的形式。
，在mac中以.app的形式安装，在系统偏好设置-扩展中-选中已经安装的
### 安装和移除
开启扩展:
我个人习惯将.app文件放到`应用程序(Applications)`文件夹中
或者
打开`系统偏好设置`->`扩展`->`勾选当前插件`->`重启Xcode`
就好了 

点击运行，如果运行不了而且扩展中找不到
首先`关掉Xcode`

OSX 10.11需要运行sudo spctl --master-disable
如果想还原，则sudo spctl --master-enable
需要开启允许安装任何来源的app，
OSX 10.12可能本来就看不到这个选项，需要运行sudo spctl --master-disable，如果想还原，则sudo spctl --master-enable

如果不想使用它删除`lazyLoad.app`文件，就可以了.

## Autolazyload开发
这是一个非常简单的Xcode extension，关于如何创建xcode extension工程网上有很多教程，不赘述，我这里抛砖引玉，简单说一下这个实现的思路和流程：

**源码编辑器扩展有很多功能，并且能通过命令组织起来。每一个扩展能够在它的 plist 文件或者通过重写`XCSourceEditorExtension` 提供一个命令清单。每一个命令都具体描述了`XCSourceEditorCommand`子类所实现的命令、菜单栏的名字以及唯一标识。同一个类能够通过切换不同的标识符被多个命令继承。一旦用户激活一个命令，Xcode 将会调用下面方法，这样就允许你的命令可以异步地完成工作。当你完成时，请确保调用 completionHandler ，使得 Xcode 知道命令已结束
可以理解为插件指令的核心逻辑都要在这个方法中实现，要注意的是，目前Xcode插件只能进行文本编辑，没有UI操作。**

```objc
- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler{
    
    completionHandler(nil);
}
```

实现逻辑很简单：
 
 *  找到当前Xcode选中的行。
 *  识别当前编译器所使用的语言（ObjC还是swift），这里我是通过关键字来识别，property和Var来区分语言，如果都不包含，视作是未知语言，即：不给它生成懒加载
 *  当明确了编程语言以后，我们自己要清楚在当前语言下给光标所在行的属性生存懒加载的模式是怎样，获取到属性名称生成指定语言的懒加载文本
 *  注意到上面方法中第一个参数是一个 `XCSourceEditorCommandInvocation` 。 这个 `invocation` 携有编辑器文本缓存的内容（一个字符串或一个包含多行文本的数组）。它还可以选中文本，并且选中部分都有一个 start 和 end 可以告诉你行和列（这可以被用于索引文本缓存区的 lines 数组）。如果没有文本被选中，那么数组中只包含一个 XCSourceTextRange，这个 range 会用相同的 start 和 end 来表现插入的点。
 *  在拿到的代码中找到`@implementation`的`@end`值，在`@end`的前一行，插入生成的懒加载文本
 *  另外：在开发中要注意`info.plist`，每个插件的名字（一个工程中可以存在多个插件，在子菜单中呈现）、标识符和自定义类名分别对应如下：

> 插件的名字 :`XCSourceEditorCommandName`
> 标识符:`XCSourceEditorCommandIdentifier`
> 自定义类名:`XCSourceEditorCommandClassName` 
>
>`XCSourceEditorExtensionPrincipalClass`对应插件的默认实现类:`SourceEditorExtension`。

如果你的插件很简单，不需要添加新的类就可以完成，那你完全可以使用info.plist默认中的默认值。
到此，这个懒加载插件开发思路就完了。

##调试
当你运行这段源码之后，会出现一个灰色Xcode，这个是为了让你知道有一个另外的进程在运行着你的扩展。你可以在新进程中测试你的扩展。可以在代码中添加log代码，这时候可以在原工程中看到打印的结果。       

**拿去玩吧，觉得有意思给个star吧～**
