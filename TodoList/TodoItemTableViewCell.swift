import UIKit

class TodoItemTableViewCell: UITableViewCell {
    typealias EditItemCallback = (String?) -> Void
    
    @IBOutlet private var textField: UITextField!
    
    @IBOutlet weak var reminderTime: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        self.backgroundColor = UIColor.white
        textField.attributedText = nil
        reminderTime.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with viewModel: TodoItemViewModel, shouldAllowEditingText: Bool) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        if let time = viewModel.reminindDate {
            reminderTime.text = dateFormatter.string(from: time)
            reminderTime.textColor = viewModel.isExpired ? UIColor.red : UIColor.lightGray
        } 
        textField.text = viewModel.text
        textField.isUserInteractionEnabled = shouldAllowEditingText
        if viewModel.isChecked {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: textField.text!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            textField.attributedText = attributeString
            self.backgroundColor = UIColor.lightGray
        }
    }
}
