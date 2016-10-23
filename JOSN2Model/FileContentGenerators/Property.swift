//
//  PropertyPresenter.swift
//  JSON2Model
//
//	Create by LiXiangCheng on 7/10/2016
//	Copyright (c) 2016 Wanda. All rights reserved.

import Foundation

/**
Represents all the meta data needed to export a JSON property in a valid syntax for the target language
*/
class Property : Equatable{
    
    /**
    The native name that is suitable to export the JSON property in the target language
    */
    var nativeName : String
    
    /**
    The JSON property name to fetch the value of this property from a JSON object
    */
    var jsonName : String
    
    var constName : String?
    
    /**
    The string representation for the property type
    */
    var type : String
    
    /**
    Whether the property represents a custom type
    */
    var isCustomClass : Bool
    
    /**
    Whether the property represents an array
    */
    var isArray : Bool
    
    /**
    The target language model
    */
    var lang : LangModel
    
    /**
    A sample value which this property represents
    */
    var sampleValue : AnyObject!
    
    
    /**
    If this property is an array, this property should contain the type for its elements
    */
    var elementsType  = ""
    
    /**
    For array properties, depetermines if the elements type is a custom type
    */
    var elementsAreOfCustomType = false
    
    /**
    Returns a valid property declaration using the LangModel.instanceVarDefinition value
    */
    func toString(_ forHeaderFile: Bool = false) -> String
    {
        var string : String!
        if forHeaderFile{
            if lang.headerFileData.instanceVarWithSpeicalDefinition != nil && lang.headerFileData.typesNeedSpecialDefinition.index(of: type) != nil{
                string = lang.headerFileData.instanceVarWithSpeicalDefinition
            }else{
                string = lang.headerFileData.instanceVarDefinition
            }
            //for ios AutoParser
            if isArray {
                if elementsAreOfCustomType {
                    string = string.replacingOccurrences(of: varType, with: "NSMutableArray<\(elementsType)>")
                }
                else{
                    string = string.replacingOccurrences(of: varType, with: "NSMutableArray")
                }
            }
            else{
                string = string.replacingOccurrences(of: varType, with: type)
            }
        }else{
            if lang.instanceVarWithSpeicalDefinition != nil && lang.typesNeedSpecialDefinition.index(of: type) != nil{
                string = lang.instanceVarWithSpeicalDefinition
            }else{
                string = lang.instanceVarDefinition
            }
            string = string.replacingOccurrences(of: varType, with: type)
        }
        
        string = string.replacingOccurrences(of: varName, with: nativeName)
        string = string.replacingOccurrences(of: jsonKeyName, with: jsonName)
        return string
    }
    
    func toConstVar(_ className: String) -> String
    {
        var string : String!
        if lang.constVarDefinition != nil {
            string = lang.constVarDefinition
        } else {
            string = ""
        }
        self.constName = "k"+className+nativeName.uppercaseFirstChar()
        
        string = string.replacingOccurrences(of: constKeyName, with: constName!)
        string = string.replacingOccurrences(of: jsonKeyName, with: jsonName)
        return string
    }
    
    
    /** 
    The designated initializer for the class
    */
    init(jsonName: String, nativeName: String, type: String, isArray: Bool, isCustomClass: Bool, lang: LangModel)
    {
        self.jsonName = jsonName.replacingOccurrences(of: " ", with: "")
        self.nativeName = nativeName.replacingOccurrences(of: " ", with: "")
        self.type = type
        self.isArray = isArray
        self.isCustomClass = isCustomClass
        self.lang = lang
    }
    
    
    /**
    Convenience initializer which calls the designated initializer with isArray = false and isCustomClass = false
    */
    convenience init(jsonName: String, nativeName: String, type: String, lang: LangModel){
        self.init(jsonName: jsonName, nativeName: nativeName, type: type, isArray: false, isCustomClass: false, lang: lang)
    }
    
    
    
    
}

//For Equatable implementation
func ==(lhs: Property, rhs: Property) -> Bool
{
    var matched = ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    if !matched{
        matched = (lhs.nativeName == rhs.nativeName && lhs.jsonName == rhs.jsonName && lhs.type == rhs.type && lhs.isCustomClass == rhs.isCustomClass && lhs.isArray == rhs.isArray && lhs.elementsType == rhs.elementsType && lhs.elementsAreOfCustomType == rhs.elementsAreOfCustomType)
    }
    return matched
}
