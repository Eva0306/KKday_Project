//
//  WishList+CoreDataProperties.swift
//  DiscountArea
//
//  Created by Nicky Y on 2024/8/30.
//
//

import Foundation
import CoreData


extension WishList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WishList> {
        return NSFetchRequest<WishList>(entityName: "WishList")
    }

    @NSManaged public var productId: String?

}

extension WishList : Identifiable {

}
