import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    var userData: NSDictionary?
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
        }

        SocketChatAPI().makeCall(name, password: pw) { responseObject, error in
            let data = responseObject!
            if data["Error"] != nil {
                self.displayAlertMessage(data["Error"] as! String)
            } else {
                self.loginUser()
            }
        }
    }

    @IBAction func loginWithTwitterButton(sender: UIButton) {
    }

    @IBAction func forgotPassword(sender: UIButton) {
    }

    func displayAlertMessage(message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message,
                                                preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func loginUser() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        userName.delegate = self
        password.delegate = self
        setAppIcon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(textfield: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
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