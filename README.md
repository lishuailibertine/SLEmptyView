# SLEmptyView
平时在业务场景中因为网络问题、接口问题导致无法正常显示页面时需要显示一个空白页面来告知用户原因。这个repository就是解决这样的问题。
# 简介
这个功能基本上是参照`DZNEmptyDataSet`思路来写的(`https://github.com/dzenbot/DZNEmptyDataSet`)。

## 与`DZNEmptyDataSet`不同之处

1、hook方法的IMP指针存储方式不同(具体可见源码)；

2、布局是通过xib，这样修改起来比较容易,用纯代码的Autolayout布局也行就是太繁琐；

3、针对网络异常、接口异常会默认两种展示type(可以再新增),这样是为了对业务的定制性更高；
