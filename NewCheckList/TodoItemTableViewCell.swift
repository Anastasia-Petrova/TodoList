//
//  TodoItemTableViewCell.swift
//  NewCheckList
//
//  Created by Anastasia Petrova on 7/11/19.
//  Copyright © 2019 Petrova. All rights reserved.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var itemTextField: UITextField!
    
    @IBAction func checkItem(_ sender: Any) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TodoItemTableViewCell: UITextFieldDelegate {
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
//        if newText.isEmpty {
//            doneButton.isEnabled = false
//        } else {
//            doneButton.isEnabled = true
//        }
        return true
    }
}
