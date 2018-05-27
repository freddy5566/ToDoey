//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/23.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewControllee {
    
    // MARK: init
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        cellID = "categoryCell"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Constant
    private let categoryArrayKey = "categoryArrayKey"
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: cellID)
        
        let textAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        self.title = "Todoey"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        
        navigationItem.rightBarButtonItem = add
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        loadCategories()
    }
    
    // MARK: Add New Category
    
    @objc private func addButtonPressed() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // add new category to category array
            print(textField.text ?? "")
            
            guard let addString = textField.text else { return }
            if addString == "" { return }
            
            let newCategory = CategoryRealm()
            newCategory.name = addString
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Model
    
    private var categoryArray: Results<CategoryRealm>?
    private let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    
    private func save(category: CategoryRealm) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context\(error)")
        }
        
        tableView.reloadData()
    }
    
    private func loadCategories() {
        
        categoryArray = realm.objects(CategoryRealm.self)
        tableView.reloadData()
    }
    
    override func deleteData(at indexPath: IndexPath) {
        
        guard let deleteCategory = self.categoryArray?[indexPath.row] else { return }
        
        do {
            try self.realm.write {
                self.realm.delete(deleteCategory)
            }
        } catch {
            print("Error deleting category, \(error)")
        }
    }
    
    // MARK: TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categoryArray?[indexPath.row]
        
        cell.textLabel?.text = category?.name ?? "NO Category Yet"
        cell.backgroundColor = UIColor.randomFlat
        cell.backgroundColor = UIColor(hexString: category?.color ?? "1D9BF6")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let toDo = TodoListViewController(style: .plain)
            toDo.selectedCategory = categoryArray?[indexPath.row]
            
            self.navigationController?.pushViewController(toDo, animated: true)
        }
    }
    
}
