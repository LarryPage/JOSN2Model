//
//  StringExtension.swift
//  JSON2Model
//
//	Create by LiXiangCheng on 7/10/2016
//	Copyright (c) 2016 Wanda. All rights reserved.

import Foundation

extension String{
    /**
    Very simple method converts the last characters of a string to convert from plural to singular. For example "parties" will be changed to "party" and "stars" will be changed to "star"
    The method does not handle any special cases, like uncountable name i.e "people" will not be converted to "person"
     单数
    */
    func toSingular() -> String
    {
        var singular = self
        let length = self.characters.count
        if length > 3{
            let range = Range(characters.index(endIndex, offsetBy: -3) ..< endIndex)
            
            let lastThreeChars = self.substring(with: range)
            if lastThreeChars == "ies" {
                singular = self.replacingOccurrences(of: lastThreeChars, with: "y", options: [], range: range)
                return singular
            }
                
        }
        if length > 2{
            let range = Range(characters.index(endIndex, offsetBy: -1) ..< endIndex)
            let lastChar = self.substring(with: range)
            if lastChar == "s" {
                singular = self.replacingOccurrences(of: lastChar, with: "", options: [], range: range)
                return singular
            }
        }
        return singular
    }
    
    /**
    Converts the first character to its lower case version
    
    - returns: the converted version
    */
    func lowercaseFirstChar() -> String{
        if self.characters.count > 0{
            let range = Range(startIndex ..< characters.index(startIndex, offsetBy: 1))
            let firstLowerChar = self.substring(with: range).lowercased()
            
            return self.replacingCharacters(in: range, with: firstLowerChar)
        }else{
            return self
        }
        
    }
    
    /**
    Converts the first character to its upper case version
    
    - returns: the converted version
    */
    func uppercaseFirstChar() -> String{
        if self.characters.count > 0{
            let range = Range(startIndex ..< characters.index(startIndex, offsetBy: 1))
            let firstUpperChar = self.substring(with: range).uppercased()
            
            return self.replacingCharacters(in: range, with: firstUpperChar)
        }else{
            return self
        }
        
    }
}
