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
        }

        SocketChatAPI().makeCallToRegister(name, password: pw, confirmation: pwc) { responseObject, error in
            let data = responseObject!
            if data["Error"] != nil {
                self.displayAlertMessage(data["Error"] as! String)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func displayAlertMessage(message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
        setAppIcon()
    }

    func setAppIcon() {
        let imageName = "logo.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: self.view.bounds.size.width/2 - image!.size.width/2,
                                 y: 0, width: image!.size.width, height: image!.size.height)
        view.addSubview(imageView)
    }
}