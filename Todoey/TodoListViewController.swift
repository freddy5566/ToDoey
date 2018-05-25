//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/19.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: UITableViewController {
    
    // MARK: Constant
    
    private let cellID = "toDoListCell"
    private let toDoListArrayKey = "toDoListArrayKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup stuff
        tableView.register(ToDoListCell.self, forCellReuseIdentifier: cellID)
        let textAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        self.title = "items"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTap))
        
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        navigationItem.rightBarButtonItem = add
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        searchBar.delegate = self
        
        //print(dataFilePath)
        
        //loadItems()
    }
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Todoey", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.addTarget(self, action: #selector(backToToDoey(_:)), for: .touchDown)
        return button
    }()
    
    @IBAction private func backToToDoey(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    // MARK: Model
    
//    var selectedCategory: Category? {
//        didSet {
//            loadItems()
//        }
//    }
    
    
    var selectedCategory: CategoryRealm? {
        didSet {
            //loadItems()
        }
    }
    
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
    
//    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        guard let name = selectedCategory?.name else { return }
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
//
//        if let addtionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context\(error)")
//        }
//
//    }
    
    // MARK: Searching
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = UISearchBarStyle.prominent
        search.placeholder = "Come on search me"
        search.sizeToFit()
        return search
    }()
    
    // MARK: Navigation Item Action
    
    @objc private func addTap() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // add new item to item array
            print(textField.text ?? "")
            
            guard let addString = textField.text else { return }
            if addString == "" { return }
//
//            let newItem = Item(context: context)
//            newItem.title = addString
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
//
//            self.itemArray.append(newItem)
//
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems() // update data
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

// MARK: SearchBar methods

extension TodoListViewController: UISearchBarDelegate {
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        
//        loadItems(with: request, predicate: predicate)
//        tableView.reloadData()
//    }
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//                // reset to original page
//                self.loadItems()
//                self.tableView.reloadData()
//            }
//        }
//    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}
