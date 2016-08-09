import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var user: User?
    var users = [[String: AnyObject]]()
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet var userListTable: UITableView!
    
    @IBAction func logoutUser(sender: UIBarButtonItem) {
        user = nil
        SocketIOManager.sharedInstance.closeConnection()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userListTable.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        if user == nil {
            self.performSegueWithIdentifier("GotoLogin", sender: self)
        }
    }

    func getListOfUsers() {
        SocketIOManager.sharedInstance.connectToServerWithUsername(user!.username!,
            completionHandler: { (userList) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if userList != nil {
                    self.users = userList
                    self.userListTable.reloadData()
                    self.userListTable.hidden = false
                }
            })
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tealColor: UIColor = UIColor(red: 0.0/255, green: 167.0/255, blue: 155.0/255, alpha: 1.0)
        let pinkColor: UIColor = UIColor(red: 244.0/255, green: 164.0/255, blue: 189.0/255, alpha: 1.0)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatUser", forIndexPath: indexPath)
        
        cell.textLabel?.text = users[indexPath.row]["username"] as? String
        cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        cell.detailTextLabel?.textColor =
            (users[indexPath.row]["isConnected"] as! Bool) ? tealColor : pinkColor
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChatRoom" {
            let chatView = segue.destinationViewController as! ChatViewController
            chatView.username = user?.username
        }
    }
}

