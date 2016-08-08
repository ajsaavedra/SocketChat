import UIKit

class ViewController: UITableViewController {

    var user: String!
    @IBOutlet weak var welcomeLabel: UILabel!

    @IBAction func logoutUser(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("GotoLogin", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        if user != nil {
            self.performSegueWithIdentifier("GotoLogin", sender: self)
        } else {
            
        }
    }
}

