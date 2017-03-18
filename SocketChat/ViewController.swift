import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var user: User?
    var users = [[String: AnyObject]]()
    @IBOutlet var userListTable: UITableView!
    var connected: Bool = false

    @IBAction func logoutUser(_ sender: UIBarButtonItem) {
        SocketIOManager.sharedInstance.closeConnection()
        connected = false
        user = nil
        self.performSegue(withIdentifier: "GotoLogin", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userListTable.separatorStyle = .none
        userListTable.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        if user == nil {
            self.performSegue(withIdentifier: "GotoLogin", sender: self)
        } else {
            if !connected {
                loginUser()
            }
            getListOfUsers()
        }
    }

    func loginUser() {
        SocketIOManager.sharedInstance.connectUser(user!.username!)
        connected = true
    }

    func getListOfUsers() {
        SocketIOManager.sharedInstance.getOnlineUsers(
            { (userList) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                if userList != nil {
                    self.users = userList!
                    self.userListTable.reloadData()
                    self.userListTable.isHidden = false
                }
            })
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tealColor: UIColor = UIColor(red: 0.0/255, green: 167.0/255, blue: 155.0/255, alpha: 1.0)
        let pinkColor: UIColor = UIColor(red: 247.0/255, green: 150.0/255, blue: 179.0/255, alpha: 1.0)

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUser", for: indexPath)

        cell.textLabel?.text = users[indexPath.row]["username"] as? String
        cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? tealColor : pinkColor
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.lightText
        }
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatRoom" {
            let chatView = segue.destination as! ChatViewController
            chatView.username = user?.username
        } else {
            if user != nil {
                SocketIOManager.sharedInstance.closeConnection()
            }
        }
    }
}

