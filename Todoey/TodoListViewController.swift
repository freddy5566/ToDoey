//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/19.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController{
    
    // MARK: Constant
    
    private let cellID = "toDoListCell"
    private let toDoListArrayKey = "toDoListArrayKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup stuff
        tableView.register(ToDoListCell.self, forCellReuseIdentifier: cellID)
        let textAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        navigationController?.navigationBar.topItem?.title = "Todoey"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTap))
        
        navigationItem.rightBarButtonItem = add
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        print(dataFilePath)
        
        loadItems()
    }
    
    // MARK: Model
    
    private var itemArray: [Item] = []
    private let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private func saveItems() {
        // let encoder = PropertyListEncoder()
        do {
            try context.save()
        } catch {
            print("Error saving context\(error)")
        }
        
        tableView.reloadData()
    }
    
    private func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context\(error)")
        }
        
    }
    
    // MARK: Navigation Item Action
    
    @objc private func addTap() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // add new item to item array
            print(textField.text ?? "")
            
            guard let addString = textField.text else { return }
            if addString == "" { return }
            
            let newItem = Item(context: self.context)
            newItem.title = addString
            newItem.done = false
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none;
        
        return cell
    }
    
    // MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems() // update data
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
}
