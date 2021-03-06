JOSN2Model
==========
一个Mac OS X 桌面appp。在使用[AutoParser](https://github.com/LarryPage/AutoParser)自动解析，AutoParser解析的任务是model的定义，model定义可以根据josn数据自动产生,JOSN2MODE就是为此而生，是用swift写的，可自接保存.h,.m文件。支持数值、字符串、自定义model，及model嵌套数组
* 支持json文件，api接口，或输入的josn数据自动产生相关联的model.h,model.m.
* 支持数值、字符串、自定义model，及model嵌套数组
* 如json中key不符合propertyName,自动产生解析转换。如id，value，goto等关键词。转换的propertyName为camel写法
* 数据嵌套关系model自动产生。
* Preview the generated content before saving it.
* Change the root class name，class prefix,parent class name.
* 若nativePropertyName和JosnKeyName不相同，自动产生(NSDictionary *)replacedKeyMap 方法
* 一个api可以生成一个类.h.m，也可生成多个类.h.m

Screenshot shows JOSN2Model used for a snippet from weibo timeline JSON and converting it to object-c Model
![alt tag](https://github.com/LarryPage/JOSN2Model/blob/master/screen001.png)
![alt tag](https://github.com/LarryPage/JOSN2Model/blob/master/screen004.png)

app 下载<a href="http://adhoc.qiniudn.com/JOSN2Model.app.zip">JOSN2Model.app</a>


AutoParser + JOSN2MODEL实现自动化解析流程
==========
* [AutoParser](https://github.com/LarryPage/AutoParser)
* [JOSN2MODEL](https://github.com/LarryPage/JOSN2Model)   下载<a href="http://adhoc.qiniudn.com/JOSN2Model.app.zip">JOSN2Model.app</a>
* 1.项目引入AutoParser目录下的NSObjectHelper.h，NSObjectHelper.m 主要用到其中的 initWithDic() & dic(）两个方法 <br>若propertyName与josnKeyName不一致时，用到replacedKeyMap（）方法 <br>
可指定model属性名被忽略,不进行dic、json和model的转换或者不进行归档，用到ignoredParserPropertyNames（）或者ignoredCodingPropertyNames（）方法 
* 2.JOSN2Model.app 桌面app，将api返回的josn数据转成model.h,model.m，保存.h.m，并引入到项目中
* 3.使用:
```
ModelClass *record=[[ModelClass alloc] initWithDic:response[@"data"]];//dic转model
NSDictionary *dic=[record dic];//model转dic

ModelClass *record=[[ModelClass alloc] initWithJson:jsonString];//json字符串转model
NSString *jsonString=[record json];//model转json字符串

NSMutableArray *models=[ModelClass modelsFromDics:dics];//dic数组转model数组
NSMutableArray *dics=[ModelClass dicsFromModels:models];//dic数组转model数组

/**
 在propertyName与josnKeyName不一致时，要在model.m实现的类方法
 返回replacedKeyMap：{propertyName:jsonKeyName}
 建议使用 JOSN2Model.app 自动生成
 */
+ (NSDictionary *)replacedKeyMap{ 
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    //[map safeSetObject:@"jsonKeyName" forKey:@"propertyName"];
    [map safeSetObject:@"avatar" forKey:@"icon"];
    return map;
}
//or
+ (NSDictionary *)replacedKeyMap{ 
    return @{@"propertyName" : @"jsonKeyName",
             @"icon" : @"avatar"
             };
}

/**
 可指定model属性名被忽略：不进行dic、json和model的转换，如model的fat属性
 */
+ (NSArray *)ignoredParserPropertyNames{
    return [NSArray arrayWithObjects:@"fat", nil];
}

/**
 可指定model属性名被忽略：不进行归档，如model的fat属性
 */
+ (NSArray *)ignoredCodingPropertyNames{
    return [NSArray arrayWithObjects:@"fat", nil];
}

NSDictionary *userPpropertiesDic = [NSObject propertiesOfClass:[ModelClass class]];//model定义->属性字典
ModelClass *copy=[record copy];//支持model NSCoding
[NSKeyedArchiver archiveRootObject:copy toFile:path];//model存储序列化文件
ModelClass *read=[NSKeyedUnarchiver unarchiveObjectWithFile:path];//序列化文件读取model
```

## License

JOSN2Model is released under the MIT license. See LICENSE for details.
