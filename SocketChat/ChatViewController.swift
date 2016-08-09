import UIKit

class ChatViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate  {

    @IBOutlet weak var chatTextfield: UITextView!
    @IBOutlet weak var userAlertLabel: UILabel!
    @IBOutlet weak var userTypingLabel: UILabel!
    @IBOutlet weak var tableChatView: UITableView!
    
    var username: String!
    var chatMessages = [[String: AnyObject]]()
    var teal =  UIColor(red: 0.0/255, green: 167.0/255, blue: 155.0/255, alpha: 1.0)

    @IBAction func sendChat(sender: UIButton) {
        if chatTextfield.text.characters.count > 0 {
            SocketIOManager.sharedInstance.sendMessage(chatTextfield.text!, withUsername: username)
            chatTextfield.text = ""
            chatTextfield.resignFirstResponder()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableChatView.delegate = self
        tableChatView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor = teal
        chatTextfield.delegate = self
        tableChatView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.chatMessages.append(messageInfo)
                self.tableChatView.reloadData()
            })
        }
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath)
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderUsername = currentChatMessage["username"] as! String
        let message = currentChatMessage["message"] as! String
        let messageDate = currentChatMessage["date"] as! String
        
        if senderUsername == username {
            cell.textLabel?.textAlignment = NSTextAlignment.Right
            cell.detailTextLabel?.textAlignment = NSTextAlignment.Right
            cell.textLabel?.textColor = teal
        } else {
            cell.backgroundColor = UIColor.darkGrayColor()
        }
        
        cell.textLabel?.text = message
        cell.detailTextLabel?.text = "by \(senderUsername.uppercaseString) @ \(messageDate)"
        
        return cell
    }
}