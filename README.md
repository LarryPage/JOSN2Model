JOSN2Model
==========
JOSN2Model is a desktop application for Mac OS X written in Swift. 
Using JOSN2Model you will be able to:
* Convert any valid JSON object to a class of object-c.
* Preview the generated content before saving it.
* Include (id)initWithDic:(NSDictionary *)dic  and initWithDic -(NSDictionary *)dic at nativePropertyName and JosnKeyName are different.
* Change the root class name.
* Set a class name prefix for the generated classes.

* 使用[AutoParser](https://github.com/LarryPage/AutoParser)自动解析。AutoParser解析的任务是model的定义，model定义可以根据josn数据自动产生,JOSN2MODE就是为此而生，是用swift写的，可自接保存.h,.m文件。支持数值、字符串、自定义model，及model嵌套数组
* 如josnk中key不符合propertyName,自动产生解析转换。如id，value，goto等关键词。转换的propertyName为camel
* 数据嵌套关系model自动产生。

Screenshot shows JOSN2Model used for a snippet from weibo timeline JSON and converting it to object-c Model
![alt tag](https://github.com/LarryPage/JOSN2Model/blob/master/screen001.png)

app download
[JOSN2Model.app](https://github.com/LarryPage/JOSN2Model/blob/master/JOSN2Model.app.zip)


AutoParser + JOSN2MODEL实现自动化解析流程
[AutoParser](https://github.com/LarryPage/AutoParser)
[JOSN2MODEL](https://github.com/LarryPage/JOSN2Model)
1.项目引入AutoParser目录下的NSObjectHelper.h，NSObjectHelper.m 主要用到其中的 initWithDic() & dic() 两个方法
2.JOSN2Model.app 桌面app，将api返回的josn数据转成model，保存.h.m，并引入到项目中
3.使用:
ModelClass *record=[[ModelClass alloc] initWithDic:response[@"data"]];//dic转model
NSDictionary *dic=[record dic];//model转dic

