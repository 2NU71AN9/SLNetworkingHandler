//
//  Cache+CoreDataProperties.swift
//  
//
//  Created by RY on 2018/8/18.
//
//

import Foundation
import CoreData


extension Cache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged public var response: String?
    @NSManaged public var timeStamp: Int32
    @NSManaged public var url: String?

}
