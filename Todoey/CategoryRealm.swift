//
//  Category.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/26.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryRealm: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<ItemRealm>()
    
}
