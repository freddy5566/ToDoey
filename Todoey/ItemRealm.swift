//
//  Item.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/26.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import Foundation
import RealmSwift

class ItemRealm: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdDate: Date?
    @objc dynamic var color: String = ""
    
    var parentCetegory = LinkingObjects(fromType: CategoryRealm.self, property: "items")
    
}
