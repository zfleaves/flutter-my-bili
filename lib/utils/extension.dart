import 'package:flutter/material.dart';

// 这段代码定义了一个名为 ImageExtension 的 Dart 扩展（extension），它扩展了 num 类型
//。在 Dart 中，扩展（extension）允许你为现有的类添加新的功能，而无需修改它们的源代码。
//这里，num 是 Dart 的一个基础类型，表示任何数字（整数或浮点数）。

// ImageExtension 扩展中添加了一个名为 cacheSize 的方法。这个方法接收一个 BuildContext 类型的参数，
//这是 Flutter 框架中用于访问构建时信息的上下文对象。

// cacheSize 方法的逻辑如下：

// MediaQuery.of(context).devicePixelRatio：这部分代码用于获取当前设备的像素比（device pixel ratio）。
// 像素比是指物理像素与设备独立像素（DIPs，Device Independent Pixels）之间的比例。在高清或视网膜屏幕上，这个比例通常大于1，以便更好地显示细节。
// this * ...：这里的 this 指的是扩展 num 类型时，调用 cacheSize 方法的原始数字。这个数字与设备像素比相乘，意味着根据设备的分辨率来调整某个值。
// .round()：最后，使用 round() 方法将结果四舍五入到最近的整数。这是因为在很多情况下，缓存大小、图像尺寸等需要是整数。
// 总的来说，ImageExtension 的 cacheSize 方法根据设备的像素比调整一个数值，并返回调整后的整数值。
// 这在处理图像或需要根据设备分辨率调整大小的UI元素时非常有用。例如，你可能需要根据设备的分辨率来动态设置图像的缓存大小，
// 以确保图像在不同设备上都能以适当的分辨率加载。

extension ImageExtension on num {
  int cacheSize(BuildContext context) {
    return (this * MediaQuery.of(context).devicePixelRatio).round();
  }
}
