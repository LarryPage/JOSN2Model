//
//	Constructor.swift
//
//	Create by LiXiangCheng on 7/10/2016
//	Copyright (c) 2016 Wanda. All rights reserved.
//

import Foundation

/** 构造函数 */
class Constructor{

	var bodyEnd : String!
	var bodyStart : String!
	var comment : String!
	var fetchArrayOfCustomTypePropertyFromMap : String!
    var fetchArrayOfBasicTypePropertyFromMap : String!
	var fetchBasicTypePropertyFromMap : String!
	var fetchBasicTypeWithSpecialNeedsPropertyFromMap : String!
	var fetchCustomTypePropertyFromMap : String!
	var signature : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		bodyEnd = dictionary["bodyEnd"] as? String
		bodyStart = dictionary["bodyStart"] as? String
		comment = dictionary["comment"] as? String
		fetchArrayOfCustomTypePropertyFromMap = dictionary["fetchArrayOfCustomTypePropertyFromMap"] as? String
        fetchArrayOfBasicTypePropertyFromMap = dictionary["fetchArrayOfBasicTypePropertyFromMap"] as? String
		fetchBasicTypePropertyFromMap = dictionary["fetchBasicTypePropertyFromMap"] as? String
		fetchBasicTypeWithSpecialNeedsPropertyFromMap = dictionary["fetchBasicTypeWithSpecialNeedsPropertyFromMap"] as? String
		fetchCustomTypePropertyFromMap = dictionary["fetchCustomTypePropertyFromMap"] as? String
		signature = dictionary["signature"] as? String
	}


}
