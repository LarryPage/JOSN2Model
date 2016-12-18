//
//  FileRepresenter.swift
//  JSON2Model
//
//	Create by LiXiangCheng on 7/10/2016
//	Copyright (c) 2016 Wanda. All rights reserved.

import Foundation
import AddressBook

/**
FileRepresenter is used to generate a valid syntax for the target language that represents JSON object
 创建.m
*/
class FileRepresenter{
    /**
    Holds the class (or type) name
    */
    var className : String
    
    /**
    Array of properties which will be included in the file content
    */
    var properties : [Property]
    
    /**
    The target language meta instance
    */
    var lang : LangModel
    
    /**
    Whether to include constructors (aka initializers in Swift) in the file content
    */
    var includeConstructors = true
    
    /**
    Whether to include utility methods in the file content. Utility methods such as toDictionary method
    */
    var includeUtilities = true
    
    /**
    If the target language supports first line statement (i.e package names in Java), then you can set the value of this property to whatever the first line statement is.
    */
    var firstLine = ""
    
    /**
    If the target language supports inheritance, all the generated classes will be subclasses of this class
    */
    var parentClassName = ""
    
    /**
    After the first time you use the toString() method, this property will contain the file content.
    */
    var fileContent = ""
    
  
    /**
    Designated initializer
    */
    init(className: String, properties: [Property], lang: LangModel)
    {
        self.className = className
        self.properties = properties
        self.lang = lang
    }
    
    /**
    Generates the file content and stores it in the fileContent property
    */
    func toString() -> String{
        fileContent = ""
        appendFirstLineStatement()
        appendCopyrights()
        appendStaticImports()
        appendHeaderFileImport()
        appendConstVarDefinition()
        appendCustomImports()
        //start the model defination
        var definition = ""
        if lang.modelDefinitionWithParent != nil && parentClassName.characters.count > 0{
            definition = lang.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: parentClassName)
        }else if includeUtilities && lang.defaultParentWithUtilityMethods != nil{
            definition = lang.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: lang.defaultParentWithUtilityMethods)
        }else{
            definition = lang.modelDefinition.replacingOccurrences(of: modelName, with: className)
        }
        fileContent += definition
        //start the model content body
        fileContent += "\(lang.modelStart!)"
        
        //appendProperties()
        //appendSettersAndGetters()
        appendArrayInit()
        appendReplacedKeyMap()
        //appendInitializers()
        //appendUtilityMethods()
        fileContent = fileContent.replacingOccurrences(of: lowerCaseModelName, with:className.lowercaseFirstChar())
        fileContent = fileContent.replacingOccurrences(of: modelName, with:className)
        fileContent += lang.modelEnd
        return fileContent
    }
    
    func toHeadStr() -> String{
        fileContent = ""
        
        appendFirstLineStatement()
        appendCopyrights()
        appendStaticImports()
        appendHeaderFileImport()
        appendConstVarDefinition()
//        appendCustomImports()
        
        return fileContent
    }
    
    /**
     Generates the file content and stores it in the fileContent property
     */
    func toStr() -> String{
        fileContent = "\n"
//        appendFirstLineStatement()
//        appendCopyrights()
//        appendStaticImports()
//        appendHeaderFileImport()
//        appendConstVarDefinition()
//        appendCustomImports()
        //start the model defination
        var definition = ""
        if lang.modelDefinitionWithParent != nil && parentClassName.characters.count > 0{
            definition = lang.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: parentClassName)
        }else if includeUtilities && lang.defaultParentWithUtilityMethods != nil{
            definition = lang.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: lang.defaultParentWithUtilityMethods)
        }else{
            definition = lang.modelDefinition.replacingOccurrences(of: modelName, with: className)
        }
        fileContent += definition
        //start the model content body
        fileContent += "\(lang.modelStart!)"
        
        //appendProperties()
        //appendSettersAndGetters()
        appendArrayInit()
        appendReplacedKeyMap()
        //appendInitializers()
        //appendUtilityMethods()
        fileContent = fileContent.replacingOccurrences(of: lowerCaseModelName, with:className.lowercaseFirstChar())
        fileContent = fileContent.replacingOccurrences(of: modelName, with:className)
        fileContent += lang.modelEnd
        fileContent += "\n"
        return fileContent
    }
    
    /**
    Appneds the firstLine value (if any) to the fileContent if the lang.supportsFirstLineStatement is true
    */
    func appendFirstLineStatement()
    {
        if lang.supportsFirstLineStatement != nil && lang.supportsFirstLineStatement! && firstLine.characters.count > 0{
            fileContent += "\(firstLine)\n\n"
        }
    }
    
    /** 
    Appends the lang.staticImports if any
    */
    func appendStaticImports()
    {
        if lang.staticImports != nil{
            fileContent += lang.staticImports!
            fileContent += "\n"
        }
    }

    func appendHeaderFileImport()
    {
        if lang.importHeaderFile != nil{
            fileContent += "\n"
            fileContent += lang.importHeaderFile!
            fileContent = fileContent.replacingOccurrences(of: modelName, with: className)
        }
    }
    
    func appendConstVarDefinition()
    {
        if includeConstructors || includeUtilities {
//            if lang.constVarDefinition != nil {
//                fileContent += "\n"
//            }
//            for property in properties{
//                fileContent += property.toConstVar(className)
//            }
            for property in properties{
                property.constName = property.jsonName
            }
        }
    }
    
    /**
    Tries to access the address book in order to fetch basic information about the author so it can include a nice copyright statment
    */
    func appendCopyrights()
    {
        fileContent += "//\n//\t\(className).\(lang.fileExtension)\n"
        if let me = ABAddressBook.shared()?.me(){
            
            if let lastName = me.value(forProperty: kABLastNameProperty as String) as? String{
                fileContent += "//\n//\tCreate by \(lastName)"
                if let firstName = me.value(forProperty: kABFirstNameProperty as String) as? String{
                   fileContent += "\(firstName)"
                }
            }
            
            
            fileContent += " on \(getTodayFormattedDay())\n//\tCopyright © \(getYear())"
            
            if let organization = me.value(forProperty: kABOrganizationProperty as String) as? String{
                fileContent += " \(organization)"
            }
            
            fileContent += ". All rights reserved."
        }
        
        if let langAuthor = lang.author{
            fileContent += "\n\n//\tThe \"\(lang.displayLangName!)\" support has been made available by \(langAuthor.name!)"
            if let email = langAuthor.email{
                fileContent += "(\(email))"
            }
            
            if let website = langAuthor.website{
                fileContent += "\n//\tMore about him/her can be found at his/her website: \(website)"
            }
            
        }
        
        
        //fileContent += "\n\n"
    }
    
    /**
    Returns the current year as String
    */
    func getYear() -> String
    {
        return "\((Calendar.current as NSCalendar).component(.year, from: Date()))"
    }
    
    /**
    Returns today date in the format dd/mm/yyyy
    */
    func getTodayFormattedDay() -> String
    {
        let components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: Date())
        return "\(components.year!)/\(components.month!)/\(components.day!)"
    }

    /**
     Loops on all properties which has a custom type and appends the custom import from the lang's importForEachCustomType property

    */
    func appendCustomImports()
    {
        if lang.importForEachCustomType != nil{
            for property in properties{
                if property.isCustomClass{
                    fileContent += lang.importForEachCustomType.replacingOccurrences(of: modelName, with: property.type)
                }else if property.isArray && property.elementsAreOfCustomType{
                    fileContent += lang.importForEachCustomType.replacingOccurrences(of: modelName, with: property.elementsType)
                }
            }
        }
        
        //for allEachCustomType
        for property in properties{
            if property.isArray && property.elementsAreOfCustomType{
                if allEachCustomType.index(of: property.elementsType) == nil {
                    allEachCustomType.append(property.elementsType)
                }
            }
        }
    }
    
    /**
    Appends all the properties using the Property.toString(forHeaderFile: false) method
    */
    func appendProperties()
    {
        fileContent += "\n"
        for property in properties{
            
            fileContent += property.toString(false)
        }
    }
    
    /**
    Appends the setter and getter for each property if the current target language supports them (i.e the convension in Java is to use private instance variables with public setters and getters). The method will use special getter for boolean properties if required by the target language
    */
    func appendSettersAndGetters()
    {
        fileContent += "\n"
        for property in properties{
            //append the setter
            let capVarName = property.nativeName.uppercaseFirstChar()
            if lang.setter != nil{
                var set = lang.setter
                
                set = set?.replacingOccurrences(of: capitalizedVarName, with: capVarName)
                set = set?.replacingOccurrences(of: varName, with: property.nativeName)
                set = set?.replacingOccurrences(of: varType, with: property.type)
                fileContent += set!
            }
            
            // append the getters
            var get : String!
            //if the property is a boolean property determine if there is a special getter for boolean properties
            if property.type == lang.dataTypes.boolType{
                if lang.booleanGetter != nil{
                    get = lang.booleanGetter
                    
                }else{
                    //use normal getter
                    get = lang.getter
                }
            }else{
                get = lang.getter
            }
            
            if get != nil{
                get = get.replacingOccurrences(of: capitalizedVarName, with: capVarName)
                get = get.replacingOccurrences(of: varName, with: property.nativeName)
                get = get.replacingOccurrences(of: varType, with: property.type)
                fileContent += get
            }
            
        }
    }
    
    /**
     添加 属性为数据类型的init
     */
    func appendArrayInit() {
        var tempStr = ""
        for property in properties{
            if property.isArray {
                if property.elementsAreOfCustomType {
                    tempStr += "\n\t\tself.\(property.nativeName)=(JSONMutableArray(\(property.elementsType)) *)[NSMutableArray array];"
                }
                else{
                    tempStr += "\n\t\tself.\(property.nativeName)=[NSMutableArray array];"
                }
            }
        }
        if !tempStr.isEmpty {
            fileContent += "\n"
            fileContent += "-(id) init{"
            fileContent += "\n\tself = [super init];"
            fileContent += "\n\tif (self) {"
            fileContent += "\n\t\t// Initialization code"
            fileContent += tempStr
            fileContent += "\n\t}"
            fileContent += "\n\treturn self;"
            fileContent += "\n}"
            fileContent += "\n"
        }
    }
    
    /**
     在propertyName与josnKeyName不一致时,添加类方法:replacedKeyMap,返回{propertyName:jsonKeyName}
     */
    func appendReplacedKeyMap(){
        var tempStr = ""
        for property in properties{
            if property.nativeName != property.jsonName {
                tempStr += "\n\t[map safeSetObject:@\"\(property.jsonName)\" forKey:@\"\(property.nativeName)\"];"
            }
        }
        if !tempStr.isEmpty {
            fileContent += "\n"
            fileContent += "+ (NSDictionary *)replacedKeyMap{"
//            fileContent += "\n\tNSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:[self.superclass replacedKeyMap]];"
            fileContent += "\n\tNSMutableDictionary *map = [NSMutableDictionary dictionary];"
            fileContent += "\n\t//[map safeSetObject:@\"jsonKeyName\" forKey:@\"propertyName\"];"
            fileContent += tempStr
            fileContent += "\n\treturn map;"
            fileContent += "\n}"
            fileContent += "\n"
        }
    }
    
    /**
    Appends all the defined constructors (aka initializers) in lang.constructors to the fileContent
     initWithDic
    */
    func appendInitializers()
    {
        if !includeConstructors{
            return
        }
        for constructor in lang.constructors{
            var tempStr = ""
            for property in properties{
                if property.nativeName != property.jsonName {
                    tempStr += propertyFetchFromJsonSyntaxForProperty(property, constructor: constructor)
                }
            }
            if !tempStr.isEmpty {
                fileContent += "\n"
//                if constructor.comment != nil{
//                    fileContent += constructor.comment
//                }
                
                fileContent += constructor.signature
                fileContent += constructor.bodyStart
                fileContent += tempStr
                fileContent += constructor.bodyEnd
                fileContent = fileContent.replacingOccurrences(of: modelName, with: className)
            }
        }
    }
    
    
    /**
    Appends all the defined utility methods in lang.utilityMethods to the fileContent
     Dic
     encodeWithCoder
     initWithCoder
     copyWithZone
    */
    func appendUtilityMethods()
    {
        if !includeUtilities{
            return
        }
        for method in lang.utilityMethods{
            var tempStr = ""
            for property in properties{
                if property.nativeName != property.jsonName {
                    var propertyHandlingStr = ""
                    if property.isArray{
                        if propertyTypeIsBasicType(property){
                            propertyHandlingStr = method.forEachProperty
                            
                        }else{
                            propertyHandlingStr = method.forEachArrayOfCustomTypeProperty
                        }
                        propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: elementType, with: property.elementsType)
                    }else{
                        if lang.basicTypesWithSpecialStoringNeeds != nil && method.forEachPropertyWithSpecialStoringNeeds != nil && lang.basicTypesWithSpecialStoringNeeds.index(of: property.type) != nil{
                            propertyHandlingStr = method.forEachPropertyWithSpecialStoringNeeds
                        }else{
                            propertyHandlingStr = method.forEachProperty
                            if property.isCustomClass{
                                propertyHandlingStr = method.forEachCustomTypeProperty
                            }
                        }
                        
                    }
                    propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: varName, with:property.nativeName)
                    propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: constKeyName, with:property.constName!)
                    propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: varType, with:property.type)
                    
                    propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: jsonKeyName, with:property.jsonName)
                    
                    propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: additionalCustomTypeProperty, with:"")
                    if lang.basicTypesWithSpecialFetchingNeeds != nil{
                        if let index = lang.basicTypesWithSpecialFetchingNeeds.index(of: property.type), let replacement = lang.basicTypesWithSpecialFetchingNeedsReplacements?[index]{
                            propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: varTypeReplacement, with: replacement)
                            
                            
                            let lowerCaseType = property.type.lowercased()
                            propertyHandlingStr = propertyHandlingStr.replacingOccurrences(of: lowerCaseVarType, with: lowerCaseType)
                            
                        }
                    }
                    tempStr += propertyHandlingStr
                }
            }
            if !tempStr.isEmpty {
                fileContent += "\n"
//                if method.comment != nil{
//                    fileContent += method.comment
//                }
                
                fileContent += method.signature
                fileContent += method.bodyStart
                fileContent += method.body
                fileContent += tempStr
                fileContent += method.returnStatement
                fileContent += method.bodyEnd
            }
        }
    }
    
    /**
    Returns true if the passed property.type is one of the basic types or an array of any of the basic types, otherwise returns false
    */
    func propertyTypeIsBasicType(_ property: Property) -> Bool{
        var isBasicType = false
        let type = propertyTypeWithoutArrayWords(property)
        if lang.genericType == type{
            isBasicType = true
        }else{
            let basicTypes = lang.dataTypes.toDictionary().allValues as! [String]
            
            if basicTypes.index(of: type) != nil{
                isBasicType = true
            }
        }
        
        
        return isBasicType
    }
    
    /**
    Removes any "array-specific character or words" from the passed type to return the type of the array elements. The "array-specific character or words" are fetched from the lang.wordsToRemoveToGetArrayElementsType property
    */
    func propertyTypeWithoutArrayWords(_ property: Property) -> String
    {
        
        var type = property.type
        
        for arrayWord in lang.wordsToRemoveToGetArrayElementsType{
            type = type.replacingOccurrences(of: arrayWord, with: "")
        }
        
        if type.characters.count == 0{
            type = typeNameForArrayElements(property.sampleValue as! NSArray, lang: lang)
        }
        return type
    }
    
    //MARK: - Fetching property from a JSON object
    /**
    Returns the suitable syntax to fetch the value of the property from a JSON object for the passed constructor
    */
    func propertyFetchFromJsonSyntaxForProperty(_ property: Property, constructor: Constructor) -> String
    {
        var propertyStr = ""
        if property.isCustomClass{
            
            propertyStr = constructor.fetchCustomTypePropertyFromMap
            
        }else if property.isArray{
            propertyStr = fetchArrayFromJsonSyntaxForProperty(property, constructor: constructor)
            
        }else {
            propertyStr = fetchBasicTypePropertyFromJsonSyntaxForProperty(property, constructor: constructor)
            
        }
        //Apply all the basic replacements
        propertyStr = propertyStr.replacingOccurrences(of: varName, with: property.nativeName)
        propertyStr = propertyStr.replacingOccurrences(of: jsonKeyName, with: property.jsonName)
        propertyStr = propertyStr.replacingOccurrences(of: constKeyName, with: property.constName!)
        propertyStr = propertyStr.replacingOccurrences(of: varType, with: property.type)
        let capVarName = property.nativeName.capitalized
        let capVarType = property.type.capitalized;
        propertyStr = propertyStr.replacingOccurrences(of: capitalizedVarName, with: capVarName)
        propertyStr = propertyStr.replacingOccurrences(of: capitalizedVarType, with: capVarType)
        return propertyStr
    }
    
    /**
    Returns valid syntax to fetch an array from a JSON object
    */
    func fetchArrayFromJsonSyntaxForProperty(_ property: Property, constructor: Constructor) -> String
    {
        var propertyStr = ""
        if(propertyTypeIsBasicType(property)){
            
            if constructor.fetchArrayOfBasicTypePropertyFromMap != nil{
                if let index = lang.basicTypesWithSpecialFetchingNeeds.index(of: property.elementsType){
                    propertyStr = constructor.fetchArrayOfBasicTypePropertyFromMap
                    let replacement = lang.basicTypesWithSpecialFetchingNeedsReplacements[index]
                    propertyStr = propertyStr.replacingOccurrences(of: varTypeReplacement, with: replacement)
                }else{
                    propertyStr = constructor.fetchBasicTypePropertyFromMap
                }
            }else{
                propertyStr = constructor.fetchBasicTypePropertyFromMap
            }
            
        }else{
            //array of custom type
            propertyStr = constructor.fetchArrayOfCustomTypePropertyFromMap
            
           
            
        }
         propertyStr = propertyStr.replacingOccurrences(of: elementType, with: property.elementsType)
        return propertyStr
    }
    
    /**
    Returns valid syntax to fetch any property with basic type from a JSON object
    */
    func fetchBasicTypePropertyFromJsonSyntaxForProperty(_ property: Property, constructor: Constructor) -> String
    {
        var propertyStr = ""
        if lang.basicTypesWithSpecialFetchingNeeds != nil{
            let index = lang.basicTypesWithSpecialFetchingNeeds.index(of: property.type)
            if index != nil{
                propertyStr = constructor.fetchBasicTypeWithSpecialNeedsPropertyFromMap
                if let replacement = lang.basicTypesWithSpecialFetchingNeedsReplacements?[index!]{
                    propertyStr = propertyStr.replacingOccurrences(of: varTypeReplacement, with: replacement)
                }
                
                let lowerCaseType = property.type.lowercased()
                propertyStr = propertyStr.replacingOccurrences(of: lowerCaseVarType, with: lowerCaseType)
                
            }else{
                propertyStr = constructor.fetchBasicTypePropertyFromMap
            }
            
        }else{
            propertyStr = constructor.fetchBasicTypePropertyFromMap
        }
        
        return propertyStr
    }
}
