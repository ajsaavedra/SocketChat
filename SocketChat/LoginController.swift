import UIKit

class LoginController: UIViewController, UITextFieldDelegate {

    var user: User?
    var userData: NSDictionary?
    var username: String?
    var pw: String?

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func loginButton(_ sender: UIButton) {
        username = userName.text!
        pw = password.text!

        if username!.isEmpty || pw!.isEmpty {
            displayAlertMessage("All fields are required.")
            return
        } else {
            loginUser()
        }
    }

    @IBAction func loginWithTwitterButton(_ sender: UIButton) {
    }

    @IBAction func forgotPassword(_ sender: UIButton) {
    }

    func displayAlertMessage(_ message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func loginUser() {
        SocketChatAPI().makeCall(userName.text!, password: self.pw!) { responseObject, error in
            let userData = responseObject!
            if userData["Error"] != nil {
                self.displayAlertMessage(userData["Error"] as! String)
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.viewController!.user = User()
                appDelegate.viewController!.user?.nameUser(self.userName.text!)

                SocketIOManager.sharedInstance.establishConnection()
                self.dismiss(animated: true, completion: nil)
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

    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
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
