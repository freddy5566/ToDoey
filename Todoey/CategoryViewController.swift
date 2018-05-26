//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/23.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {
    
    // MARK: Constant
    
    private let cellID = "categoryCell"
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
    
    //private var categoryArray: [Category] = []
    private var categoryArray: Results<CategoryRealm>?
    private let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private func save(category: CategoryRealm) {
        // let encoder = PropertyListEncoder()
        do {
            // core data way
            // try context.save()
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
        
        
//        do {
//            categoryArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context\(error)")
//        }
        tableView.reloadData()
        
        
    }
    
    // MARK: TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let category = categoryArray?[indexPath.row]
        
        
        cell.textLabel?.text = category?.name ?? "NO Category Yet"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let toDo = TodoListViewController()
            toDo.selectedCategory = categoryArray?[indexPath.row]
            
            self.navigationController?.pushViewController(toDo, animated: true)
        }
        
        
    }
    
}
