import UIKit

class ChatViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate  {

    @IBOutlet weak var chatTextfield: UITextView!
    @IBOutlet weak var userAlertLabel: UILabel!
    @IBOutlet weak var userTypingLabel: UILabel!
    @IBOutlet weak var tableChatView: UITableView!
    
    var username: String!
    var chatMessages = [[String: AnyObject]]()
    var teal =  UIColor(red: 0.0/255, green: 167.0/255, blue: 155.0/255, alpha: 1.0)
    var cream = UIColor(red: 255.0/255, green: 237.0/255, blue: 210.0/255, alpha: 2.0)

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
        tableChatView.separatorStyle = .None
        userTypingLabel.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleUserTypingNotification(_:)), name: "userTypingNotification", object: nil)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("chatTextCell", forIndexPath: indexPath) as UITableViewCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderUsername = currentChatMessage["username"] as! String
        let message = currentChatMessage["message"] as! String
        let messageDate = formatJSONDate(currentChatMessage["date"] as! String)

        if senderUsername == username {
            cell.textLabel?.textAlignment = NSTextAlignment.Right
            cell.detailTextLabel?.textAlignment = NSTextAlignment.Right
            cell.textLabel?.textColor = teal
            cell.backgroundColor = cream
        } else {
            cell.backgroundColor = teal
            cell.textLabel?.textColor = cream
        }
        
        cell.textLabel?.text = message
        cell.detailTextLabel?.text = "by \(senderUsername.uppercaseString) @ \(messageDate)"
        cell.detailTextLabel?.textColor = UIColor.darkGrayColor()

        return cell
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        SocketIOManager.sharedInstance.sendUserStartedTypingMessage(username)
        return true
    }
    
    func handleUserTypingNotification(notification: NSNotification) {
        if let typingUsersDictionary = notification.object as? [String: AnyObject] {
            var names = ""
            var totalTypingUsers = 0
            for (typingUser, _) in typingUsersDictionary {
                if typingUser != username {
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUsers += 1
                }
            }
            
            if totalTypingUsers > 0 {
                let verb = (totalTypingUsers == 1) ? "is" : "are"
                
                userTypingLabel.text = "\(names) \(verb) now typing a message..."
                userTypingLabel.hidden = false
            } else {
                userTypingLabel.hidden = true
            }
        }
    }
    
    func formatJSONDate(date: String) -> String {
        let dateFor: NSDateFormatter = NSDateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let parsedDate = dateFor.dateFromString(date)
        
        dateFor.dateFormat = "MMM dd', 'yyyy HH:mm:ss"
        dateFor.timeZone = NSTimeZone(name: "UTC")
        let timeStamp = dateFor.stringFromDate(parsedDate!)
        return timeStamp
    }
}