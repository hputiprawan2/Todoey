//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Hanna Putiprawan on 2/3/21.
//

import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {

    let realm = try! Realm()
    
    var categories: Results<Category>? // auto-updating container type in Realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // Nil Coalescing Operator
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories?[indexPath.row]
        cell.textLabel?.text = category?.name ?? "No Category yet."
        return cell
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            // current row that is selected
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add A New Category", message: "", preferredStyle: .alert)
        // Alert when user clicks the Add Item button on the UIAlert
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // Alert when user clicks the Add Item button on the UIAlert

            let newCategory = Category()
            newCategory.name = textField.text!

            self.saveCategories(category: newCategory)

        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create A New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data Manipulation Methods
    func saveCategories(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        // Reload UI so new item appears
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
}
