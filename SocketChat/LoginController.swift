import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func loginButton(sender: UIButton) {
        let name = userName.text!
        let pw = password.text!
        
        if name.isEmpty || pw.isEmpty {
            displayAlertMessage("All fields are required.")
            return
        } else if userDoesNotExist() {
            displayAlertMessage("Invalid User");
        } else if isIncorrectPassword() {
            displayAlertMessage("Incorrect password");
        } else {
            loginUser()
            return
        }
    }

    @IBAction func loginWithTwitterButton(sender: UIButton) {
    }

    @IBAction func forgotPassword(sender: UIButton) {
    }
    
    func displayAlertMessage(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func userDoesNotExist() -> Bool {
        return false
    }
    
    func isIncorrectPassword() -> Bool {
        return false
    }
    
    func loginUser() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.delegate = self
        password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textfield: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
}