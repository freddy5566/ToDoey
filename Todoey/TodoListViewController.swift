//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jamfly on 2018/5/19.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewControllee {
    
    // MARK: init
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        cellID = "toDoListCell"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Constant
    
    private let toDoListArrayKey = "toDoListArrayKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup stuff
        tableView.register(ToDoListCell.self, forCellReuseIdentifier: cellID)
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTap))
        
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        navigationItem.rightBarButtonItem = add
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchBar.delegate = self
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let colorHex = selectedCategory?.color else { return }
        
        updateNavBar(withHexCode: colorHex)
        
        title = selectedCategory!.name
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("Todoey", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.addTarget(self, action: #selector(backToToDoey(_:)), for: .touchDown)
        return button
    }()
    
    // MARK: Nav bar setup
    private func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist. ") }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else { return }
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
         searchBar.barTintColor = navBarColor
    }
    
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
    private let realm = try! Realm()
    
    private func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()

    }
    
    override func deleteData(at indexPath: IndexPath) {
        guard let deleteItem = self.toDoItems?[indexPath.row] else { return }
        
        do {
            try self.realm.write {
                self.realm.delete(deleteItem)
            }
        } catch {
            print("Error deleting category, \(error)")
        }
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
                        
                        newItem.createdDate = Date()
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
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            guard let category = self.selectedCategory else { return cell }
            
            if let color = UIColor(hexString: category.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdDate", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            self.loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                // reset to original page
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}
