//
//	Author.swift
//
//	Create by LiXiangCheng on 7/10/2016
//	Copyright (c) 2016 Wanda. All rights reserved.
//	Model file Generated using JOSN2Model: https://github.com/LarryPage/JOSN2Model

import Foundation

/** 作者 */
class Author : NSObject, NSCoding{
    
    var website : String!
    var email : String!
    var name : String!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: NSDictionary){
        website = dictionary["website"] as? String
        email = dictionary["email"] as? String
        name = dictionary["name"] as? String
    }
    
    /**
     * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> NSDictionary
    {
        let dictionary = NSMutableDictionary()
        if website != nil{
            dictionary["website"] = website
        }
        if email != nil{
            dictionary["email"] = email
        }
        if name != nil{
            dictionary["name"] = name
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        website = aDecoder.decodeObject(forKey: "website") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    @objc func encode(with aCoder: NSCoder)
    {
        if website != nil{
            aCoder.encode(website, forKey: "website")
        }
        if email != nil{
            aCoder.encode(email, forKey: "email")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        
    }
    
}
