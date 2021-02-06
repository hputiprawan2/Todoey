//
//  ViewController.swift
//  Todoey
//
//  Created by Hanns Putiprawan on 01/30/2021.
//

import UIKit
import RealmSwift

// Inherite UITableViewController and having a UITableViewController (instead just View)
// no need to link the IBOutlet, delegate, data source
class TodoListViewController: UITableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            // happen immediately after the variable get set with the value
            loadItems()
            // So when we called loadItems() we certain that we already get the value for selectedCategory, not called before which will crash the app 
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            // Ternary Operator -> value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Item Added"
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done // Toggle done boolean - reverse value
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadData()
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done

        // Delete item; ** Update DB before update view
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
//        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        // Alert when user clicks the Add Item button on the UIAlert
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Alert when user clicks the Add Item button on the UIAlert

            do {
                if let currentCategory = self.selectedCategory {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                }
            } catch {
                print("Error saving new items, \(error)")
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create A New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Models Manipulation Methods
    func saveItems(item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving context \(error)")
        }
        // Reload UI so new item appears
        self.tableView.reloadData()
    }
    
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true) // get all the item that belongs to that selected category
        tableView.reloadData()
    }
}

// MARK: - SearchBar Methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Reload the tableView to what user search for
        todoItems = todoItems?.filter("title CONTAIN[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
    }

    // Clear search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // keyboard goes away
            }

        }
    }
}
