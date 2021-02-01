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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
//        if let items = userDefaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
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
    
    func loadItems() {
        // Fetch result in a form of item, require to specify data type
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
}

