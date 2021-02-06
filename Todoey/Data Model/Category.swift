//
//  Category.swift
//  Todoey
//
//  Created by Hanna Putiprawan on 2/5/21.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>() // forward relationship
}
