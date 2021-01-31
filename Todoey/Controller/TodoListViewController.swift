//
//  ViewController.swift
//  Todoey
//
//  Created by Hanns Putiprawan on 01/30/2021.
//

import UIKit

// Inherite UITableViewController and having a UITableViewController (instead just View)
// no need to link the IBOutlet, delegate, data source
class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
//    let userDefaults = UserDefaults.standard // UserDefaults DB plist - very small save
//    // Need to be careful when using UserDefaults, cuz it's not an actual DB
//    // Only small amount could be saved in UserDefaults - impact efficiency if large
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
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

        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Alert when user clicks the Add Item button on the UIAlert
            let newItem = Item()
            newItem.title = textField.text!
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        // Reload UI so new item appears
        self.tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
            
        }
    }
    
}

