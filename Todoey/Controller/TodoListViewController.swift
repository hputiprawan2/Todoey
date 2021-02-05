//
//  ViewController.swift
//  Todoey
//
//  Created by Hanns Putiprawan on 01/30/2021.
//

import UIKit
import CoreData

// Inherite UITableViewController and having a UITableViewController (instead just View)
// no need to link the IBOutlet, delegate, data source
class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
//    let userDefaults = UserDefaults.standard
    // UserDefaults DB plist - very small save
    // Need to be careful when using UserDefaults, cuz it's not an actual DB
    // Only small amount could be saved in UserDefaults - impact efficiency if large
    
    // AppDelegate = UIApplication.shared.delegate = live application object; app delegate of the app object
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: Category? {
        didSet {
            // happen immediately after the variable get set with the value
            loadItems()
            // So when we called loadItems() we certain that we already get the value for selectedCategory, not called before which will crash the app 
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
    }

    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        // Ternary Operator -> value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggle done boolean - reverse value
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        // Delete item; ** Update DB before update view
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        // Alert when user clicks the Add Item button on the UIAlert
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Alert when user clicks the Add Item button on the UIAlert

            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
//            // Add new item to UserDefaults DB
//            self.userDefaults.set(self.itemArray, forKey: "TodoListArray")

            self.saveItems()

        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create A New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Models Manipulation Methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        // Reload UI so new item appears
        self.tableView.reloadData()
    }
    
    // = Item.fetchRequest() is a default value
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        request.predicate = predicate
        
        // Fetch result in a form of item, require to specify data type
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: - SearchBar Methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Reload the tableView to what user search for
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        let sortDesciptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDesciptor]
        
        loadItems(with: request)
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
