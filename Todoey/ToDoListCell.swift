//
//  ToDoListCell.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/20.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit

class ToDoListCell: UITableViewCell {
    
    var toDoitems: String? {
        didSet {
            textLabel?.text = toDoitems
        }
    }
    
    
  
    
    
    
    
}
