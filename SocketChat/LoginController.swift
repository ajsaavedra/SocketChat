import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    var user: User?
    var userData: NSDictionary?
    var username: String?
    var pw: String?

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func backgroundTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func loginButton(sender: UIButton) {
        username = userName.text!
        pw = password.text!

        if username!.isEmpty || pw!.isEmpty {
            displayAlertMessage("All fields are required.")
            return
        } else {
            loginUser()
        }
    }

    @IBAction func loginWithTwitterButton(sender: UIButton) {
    }

    @IBAction func forgotPassword(sender: UIButton) {
    }

    func displayAlertMessage(message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message,
                                                preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func loginUser() {
        SocketChatAPI().makeCall(userName.text!, password: self.pw!) { responseObject, error in
            let userData = responseObject!
            if userData["Error"] != nil {
                self.displayAlertMessage(userData["Error"] as! String)
            } else {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.viewController!.user = User()
                appDelegate.viewController!.user?.nameUser(self.userName.text!)

                SocketIOManager.sharedInstance.establishConnection()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
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