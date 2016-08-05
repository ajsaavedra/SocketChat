import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var chatTextfield: UITextView!
    @IBOutlet weak var userAlertLabel: UILabel!
    @IBOutlet weak var userTypingLabel: UILabel!

    @IBAction func sendChat(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor =
            UIColor(red: 0.0/255, green: 167.0/255, blue: 155.0/255, alpha: 1.0)
        chatTextfield.delegate = self
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}