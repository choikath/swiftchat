//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    var memeArray = ["meme-beyonceamazing", "meme-oprahhighfives","meme-wonderfulwonderwoman", "meme-superduperanchorman"]
    var iconArray = ["banana", "heart", "claps"]
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set basic look and navigation UI
        self.navigationController?.hidesNavigationBarHairline = true
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell  // since our cell is a custom data type
        
    
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.recipientUsername.text = messageArray[indexPath.row].recipient
//        UIImage.gif(name: memes[meme1.tag])
        var memeIndex = Int(arc4random_uniform(UInt32(memeArray.count)))
        var iconIndex = Int(arc4random_uniform(UInt32(iconArray.count)))
        cell.avatarImageView.image = UIImage.gif(name: memeArray[memeIndex])
        cell.iconImageView.image = UIImage(named: iconArray[iconIndex])
        
        
        
        
//        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! { //messages we sent
////            cell.avatarImageView.backgroundColor = UIColor.flatPlum()
////            cell.messageBackground.backgroundColor = UIColor.flatWatermelon()
//        }
//        else {
            //cell.avatarImageView.backgroundColor = UIColor.flatMint()
//            var colorArray = NSArray(ofColorsWithColorScheme:ColorScheme.triadic, with:UIColor.randomFlat(), flatScheme:true) as! UIColor

//            cell.messageBackground.backgroundColor = UIColor.randomFlat()
//            cell.messageBody.textColor = UIColor(contrastingBlackOrWhiteColorOn:      cell.messageBackground.backgroundColor, isFlat:true)

            cell.messageBody.textColor = UIColor.randomFlat()
            cell.recipientUsername.textColor = cell.messageBody.textColor
            
//        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
        
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        <#code#>
//    }
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5)
        {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "Recipient": messageTextfield.text!, "MessageBody": "HighFive!"]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
        
            if error != nil {
                print(error)
            }
            else {
                print("message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = "" // reset to blank
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in  //Firebase will return the snapshot when this function is called.
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]! //unwrap
            let sender = snapshotValue["Sender"]!
            let recipient = snapshotValue["Recipient"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            message.recipient = recipient

            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("error in logging out")
        }
        
    }
    


}
