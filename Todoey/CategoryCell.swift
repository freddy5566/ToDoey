//
//  CategoryCell.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/23.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    var categoryName: String? {
        didSet {
           textLabel?.text = categoryName
        }
    }
    
    
}
