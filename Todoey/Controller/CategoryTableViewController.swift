//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Hanna Putiprawan on 2/3/21.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories: Results<Category>? // auto-updating container type in Realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")}
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(#colorLiteral(red: 0.910805583, green: 0.4249960184, blue: 0.6569120288, alpha: 1), returnFlat: true)] // font title color
            navBarAppearance.backgroundColor = #colorLiteral(red: 0.910805583, green: 0.4249960184, blue: 0.6569120288, alpha: 1)
            navBar.tintColor = ContrastColorOf(#colorLiteral(red: 0.910805583, green: 0.4249960184, blue: 0.6569120288, alpha: 1), returnFlat: true) // font navBar color
            navBar.scrollEdgeAppearance = navBarAppearance // set entire background beyond safeview
        }
    }

    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // Nil Coalescing Operator
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) // tap into that cell
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category yet."
        let color = UIColor(hexString: categories?[indexPath.row].color ?? "FFFFFF")
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
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
            newCategory.color = UIColor.randomFlat().hexValue()

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
    
    override func updateModel(at indexPath: IndexPath) {
        if let currentCategory = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(currentCategory)
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
    }
}
