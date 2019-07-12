//
//  AddItemTableViewController.swift
//  NewCheckList
//
//  Created by Anastasia Petrova on 7/11/19.
//  Copyright © 2019 Petrova. All rights reserved.
//

import UIKit

class AddItemTableViewController: UITableViewController {
    typealias AddItemCallback = (String) -> Void
    typealias EditItemCallback = (String) -> Void
    @IBOutlet weak var textField: UITextField!
    var editingItemName = ""
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        if let newName = textField.text {
            addItemCallback?(newName)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var addItemCallback: AddItemCallback?
    var editItemCallback: EditItemCallback?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = editingItemName
        doneButton.isEnabled = false 
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension AddItemTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
            let stringRange = Range(range, in: oldText) else {
                return false
        }
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
        return true
    }
}
