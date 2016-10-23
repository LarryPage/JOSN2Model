//
//  HeaderFileRepresenter.swift
//  JSON2Model
//
//	Create by LiXiangCheng on 7/10/2016
//	Copyright (c) 2016 Wanda. All rights reserved.


import Foundation
import AddressBook

/**
 创建.h
 */
class HeaderFileRepresenter : FileRepresenter{
    /**
    Generates the header file content and stores it in the fileContent property
    */
    override func toString() -> String{
        fileContent = ""
        appendCopyrights()
        appendStaticImports()
        appendImportParentHeader()
        appendCustomImports()
        
        //根据需要是否添加@protocol
        if allEachCustomType.index(of: className) != nil {
            fileContent += "\n@protocol \(className) <NSObject>\n@end\n"
        }
        
        //start the model defination
        var definition = ""
        if lang.headerFileData.modelDefinitionWithParent != nil && parentClassName.characters.count > 0{
            definition = lang.headerFileData.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: parentClassName)
        }else if includeUtilities && lang.defaultParentWithUtilityMethods != nil{
            definition = lang.headerFileData.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: lang.headerFileData.defaultParentWithUtilityMethods)
        }else{
            definition = lang.headerFileData.modelDefinition.replacingOccurrences(of: modelName, with: className)
        }
        
        fileContent += definition
        //start the model content body
        fileContent += "\(lang.modelStart!)"
        
        appendProperties()
        //appendInitializers()
        //appendUtilityMethods()
        fileContent += "\n"
        fileContent += lang.modelEnd
        return fileContent
    }
    
  
    
    /**
    Appends the lang.headerFileData.staticImports if any
    */
    override func appendStaticImports()
    {
        if lang.headerFileData.staticImports != nil{
            fileContent += lang.headerFileData.staticImports
            fileContent += "\n"
        }
    }
    
    func appendImportParentHeader()
    {
        if lang.headerFileData.importParentHeaderFile != nil && parentClassName.characters.count > 0{
            fileContent += lang.headerFileData.importParentHeaderFile.replacingOccurrences(of: modelWithParentClassName, with: parentClassName)
        }
    }
    
    /**
    Tries to access the address book in order to fetch basic information about the author so it can include a nice copyright statment
    */
    override func appendCopyrights()
    {
        if let me = ABAddressBook.shared()?.me(){
            fileContent += "//\n//\t\(self.className).\(lang.headerFileData.headerFileExtension!)\n"
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
            
            fileContent += ". All rights reserved.\n//\n\n"
        }
        
    }
    
    
    /**
    Loops on all properties which has a custom type and appends the custom import from the lang.headerFileData's importForEachCustomType property
    
    */
    override func appendCustomImports()
    {
        if lang.importForEachCustomType != nil{
            for property in properties{
                if property.isCustomClass{
                    fileContent += lang.headerFileData.importForEachCustomType.replacingOccurrences(of: modelName, with: property.type)
                }else if property.isArray{
                    //if it is an array of custom types
                    if(property.elementsType != lang.genericType){
                        let basicTypes = lang.dataTypes.toDictionary().allValues as! [String]
                        if basicTypes.index(of: property.elementsType) == nil{
                            fileContent += lang.headerFileData.importForEachCustomType.replacingOccurrences(of: modelName, with: property.elementsType)
                        }
                    }
                    
                }
            }
        }
        
        //for allEachCustomType
        for property in properties{
            if property.isArray{
                //if it is an array of custom types
                if(property.elementsType != lang.genericType){
                    let basicTypes = lang.dataTypes.toDictionary().allValues as! [String]
                    if basicTypes.index(of: property.elementsType) == nil{
                        if allEachCustomType.index(of: property.elementsType) == nil {
                            allEachCustomType.append(property.elementsType)
                        }
                    }
                }
            }
        }
    }
    
    /**
    Appends all the properties using the Property.stringPresentation method
    */
    override func appendProperties()
    {
        fileContent += "\n"
        for property in properties{
            fileContent += property.toString(true)
        }
    }
    
    /**
    Appends all the defined constructors (aka initializers) in lang.constructors to the fileContent
     initWithDictionary
    */
    override func appendInitializers()
    {
        if !includeConstructors{
            return
        }
        fileContent += "\n"
        for constructorSignature in lang.headerFileData.constructorSignatures{
           
            fileContent += constructorSignature
            
            fileContent = fileContent.replacingOccurrences(of: modelName, with: className)
        }
    }
    
    
    /**
    Appends all the defined utility methods in lang.utilityMethods to the fileContent
     toDictionary
    */
    override func appendUtilityMethods()
    {
        if !includeUtilities{
            return
        }
        fileContent += "\n"
        for methodSignature in lang.headerFileData.utilityMethodSignatures{
            fileContent += methodSignature
        }
    }
}
