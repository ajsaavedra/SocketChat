import UIKit

class SignUpController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirmation: UITextField!

    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func signUp(sender: UIButton) {
        let name = userName.text!
        let pw = password.text!
        let pwc = passwordConfirmation.text!

        if name.isEmpty || pw.isEmpty || pwc.isEmpty {
            displayAlertMessage("All fields are required.")
            return
        } else if pw != pwc {
            displayAlertMessage("Passwords do not match.")
            return
        } else {
            registerUser()
            return
        }
    }

    func displayAlertMessage(message: String) {
        let alertController = UIAlertController(title: "Alert", message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func registerUser() {
        
    }

    @IBAction func dismissView(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textfield: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.delegate = self
        password.delegate = self
        passwordConfirmation.delegate = self
    }
}