import UIKit

class TodoItemTableViewCell: UITableViewCell {
    typealias EditItemCallback = (String?) -> Void
    typealias CheckBoxCallback = () -> Void
    var editItemCallback: EditItemCallback?
    var checkBoxCallback: CheckBoxCallback?

    @IBOutlet private var checkMark: UIButton!
    
    @IBOutlet private var textField: UITextField!
    
    @IBAction func checkItem(_ sender: Any) {
        checkBoxCallback?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkMark.setImage(UIImage(named: "uncheckedMark") , for: .normal)
        textField.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(with viewModel: TodoItemViewModel) {
        textField.text = viewModel.text
        checkMark.setImage(UIImage(named: viewModel.checkBoxIconName), for: .normal)
        if viewModel.isChecked {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: textField.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            textField.attributedText = attributeString
        }
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
