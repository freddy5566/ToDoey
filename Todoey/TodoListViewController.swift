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
        
        loadItems()
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

    var selectedCategory: CategoryRealm? {
        didSet {
            loadItems()
        }
    }
    
    private var toDoItems: Results<ItemRealm>?
    private let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let realm = try! Realm()
    
    private func loadItems() {

        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()

    }
    
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

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = ItemRealm()
                        newItem.title = addString
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
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
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none;
        } else {
            cell.textLabel?.text = "No Items added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    //realm.delete(item)
                }
                self.tableView.reloadData()
            } catch {
                print("Error saving done status, \(error)")
            }
        }
    
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
