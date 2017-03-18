import UIKit

class ChatViewController:  UIViewController, UITableViewDelegate,
    UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate  {

    @IBOutlet weak var chatTextfield: UITextView!
    @IBOutlet weak var userAlertLabel: UILabel!
    @IBOutlet weak var userTypingLabel: UILabel!
    @IBOutlet weak var tableChatView: UITableView!

    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    var username: String!
    var chatMessages = [[String: AnyObject]]()
    var teal =  UIColor(red: 0.0/255, green: 167.0/255, blue: 155.0/255, alpha: 1.0)
    var cream = UIColor(red: 255.0/255, green: 237.0/255, blue: 210.0/255, alpha: 2.0)
    var bannerLabelTimer: Timer!

    @IBAction func sendChat(_ sender: UIButton) {
        if chatTextfield.text.characters.count > 0 {
            SocketIOManager.sharedInstance.sendMessage(chatTextfield.text!, withUsername: username)
            chatTextfield.text = ""
            chatTextfield.resignFirstResponder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableChatView.delegate = self
        tableChatView.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.tintColor = teal
        chatTextfield.delegate = self
        tableChatView.separatorStyle = .none
        userTypingLabel.isHidden = true
        userAlertLabel.isHidden = true

        setChatRoomObservers()
    }

    func setChatRoomObservers() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(ChatViewController.handleUserTypingNotification(_:)),
                         name: NSNotification.Name(rawValue: "userTypingNotification"), object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(ChatViewController.handleUserEnteredChatRoom),
                         name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(ChatViewController.handleUserLeftChatRoom),
                         name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: nil)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.chatMessages.append(messageInfo)
                self.tableChatView.reloadData()
                let numOfSections = self.tableChatView.numberOfSections
                let numOfRows = self.tableChatView.numberOfRows(inSection: numOfSections-1)
                let indexPath = IndexPath(row: numOfRows-1, section: numOfSections-1)
                self.tableChatView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            })
        }
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return chatMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatTextCell", for: indexPath) as UITableViewCell

        let currentChatMessage = chatMessages[indexPath.row]
        let senderUsername = currentChatMessage["username"] as! String
        let message = currentChatMessage["message"] as! String
        let messageDate = formatJSONDate(currentChatMessage["date"] as! String)

        if senderUsername == username {
            cell.textLabel?.textAlignment = NSTextAlignment.right
            cell.detailTextLabel?.textAlignment = NSTextAlignment.right
            cell.textLabel?.textColor = teal
            cell.backgroundColor = cream
        } else {
            cell.backgroundColor = teal
            cell.textLabel?.textColor = cream
        }

        cell.textLabel?.text = message
        cell.detailTextLabel?.text = "by \(senderUsername.uppercased()) @ \(messageDate)"
        cell.detailTextLabel?.textColor = UIColor.darkGray

        return cell
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        SocketIOManager.sharedInstance.sendUserStartedTypingMessage(username)
        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        SocketIOManager.sharedInstance.sendStopTypingMessage(username)
        return true
    }

    func handleUserTypingNotification(_ notification: Notification) {
        let usersTyping = notification.object as! [String]
        if usersTyping.count > 0 {
            if usersTyping.count > 3 {
                userTypingLabel.text = "This chat room is busy!"
                userTypingLabel.isHidden = false
                return
            }

            var userIsTyping = false
            for user in 0..<usersTyping.count {
                if usersTyping[user] == username {
                   userIsTyping = true
                }
            }

            var verb = ""
            if userIsTyping {
                verb = usersTyping.count > 2 ? "are" : "is"
            } else {
                verb = usersTyping.count >= 2 ? "are" : "is"
            }

            var names = ""
            for user in 0..<usersTyping.count {
                if usersTyping[user] != username {
                    names += "\(usersTyping[user])"
                    userTypingLabel.text = "\(names) \(verb) now typing a message..."
                    userTypingLabel.isHidden = false
                }
                if user < usersTyping.count-1 && usersTyping[user+1] != username {
                    names += ", "
                }
            }
        } else {
            userTypingLabel.isHidden = true
        }
    }

    func handleUserEnteredChatRoom(_ notification: Notification) {
        let connectedUserInfo = notification.object as! String
        userAlertLabel.text = "\(connectedUserInfo) was just connected!"
        showBannerLabelAnimated()
    }

    func handleUserLeftChatRoom(_ notification: Notification) {
        let disconnectedUsername = notification.object as! String
        userAlertLabel.text = "\(disconnectedUsername) has left."
        showBannerLabelAnimated()
    }

    func showBannerLabelAnimated() {
        UIView.animate(withDuration: 0.75, animations: { () -> Void in
            self.userAlertLabel.isHidden = false
            self.userAlertLabel.alpha = 1.0
        }, completion: { (finished) -> Void in
            self.bannerLabelTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                        selector: #selector(ChatViewController.hideBannerLabel), userInfo: nil, repeats: false)
        }) 
    }

    func hideBannerLabel() {
        if bannerLabelTimer != nil {
            bannerLabelTimer.invalidate()
            bannerLabelTimer = nil
        }

        UIView.animate(withDuration: 0.75, animations: { () -> Void in
            self.userAlertLabel.isHidden = true
            self.userAlertLabel.alpha = 0.0
        }, completion: { (finished) -> Void in
        }) 
    }

    func formatJSONDate(_ date: String) -> String {
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        let parsedDate = dateFor.date(from: date)

        dateFor.dateFormat = "MMM dd', 'yyyy HH:mm:ss"
        dateFor.timeZone = TimeZone(identifier: "UTC")
        let timeStamp = dateFor.string(from: parsedDate!)
        return timeStamp
    }
}
