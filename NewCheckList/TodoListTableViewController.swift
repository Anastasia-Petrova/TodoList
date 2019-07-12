//
//  TodoListTableViewController.swift
//  NewCheckList
//
//  Created by Anastasia Petrova on 7/11/19.
//  Copyright © 2019 Petrova. All rights reserved.
//

import UIKit
import CoreData

class TodoListTableViewController: UITableViewController {
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let aivc = storyboard.instantiateViewController(withIdentifier: "AddItemTableViewController") as! AddItemTableViewController
        aivc.addItemCallback = { [weak self] (name) in
            self?.addNewItemToDB(newName: name)
        }
        self.navigationController?.pushViewController(aivc, animated: true)
    }
    
    lazy var todoListFetchController: NSFetchedResultsController<TodoItem> = CoreDataManager.instance.fetchedResultsController(entityName: "TodoItem",
                                                                                                                               keyForSort: "name")

    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        todoListFetchController.delegate = self
    }
    
    public func performFetch() {
        do {
            try todoListFetchController.performFetch()
        } catch {
            print(error)
        }
    }

   override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(inSection: section)
    }
    
    public func numberOfItems(inSection section: Int) -> Int {
        if let sections = todoListFetchController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = todoListFetchController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath) as! TodoItemTableViewCell
        cell.todoLabel.text = item.name
        cell.checkmark.text = ""
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //         if segue.identifier == "EditItemSegue" {
        if let aivc = segue.destination as? AddItemTableViewController {
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell) {
                let item = todoListFetchController.object(at: indexPath)
                if let newEditingItemName = item.name {
                    aivc.editingItemName = newEditingItemName
                }
                //                    addItemDetailViewController.itemToEdit = item
                //                    addItemDetailViewController.delegate = self
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as! TodoItemTableViewCell
        if cell.checkmark.text == "" {
            cell.checkmark.text = "√"
        } else {
            cell.checkmark.text = ""
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.deleteItem(indexPath: indexPath)
    }
    
    func addNewItemToDB(newName: String) {
        let item = TodoItem(context: CoreDataManager.instance.managedObjectContext)
        item.name = newName
        CoreDataManager.instance.saveContext()
    }
    
    func deleteItem(indexPath: IndexPath) {
        let item = todoListFetchController.object(at: indexPath)
        CoreDataManager.instance.managedObjectContext.delete(item)
        CoreDataManager.instance.saveContext()
    }
}

extension TodoListTableViewController: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update: break
            
        default: break
        }
    }
}



