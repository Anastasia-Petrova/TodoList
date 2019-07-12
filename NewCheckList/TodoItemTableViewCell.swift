import UIKit

class TodoItemTableViewCell: UITableViewCell {
    typealias EditItemCallback = (String?) -> Void
    var editItemCallback: EditItemCallback?

    @IBOutlet weak var checkMark: UIButton!
    
    @IBOutlet weak var itemTextField: UITextField!
    
    @IBAction func checkItem(_ sender: Any) {
        if checkMark.image(for: .normal) == UIImage(named: "uncheckedMark") {
            checkMark.setImage(UIImage(named: "checkedMark") , for: .normal)
        } else {
            checkMark.setImage(UIImage(named: "uncheckedMark") , for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension TodoItemTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        editItemCallback?(textField.text)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
            let stringRange = Range(range, in: oldText) else {
                return false
        }
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        return true
    }
}
