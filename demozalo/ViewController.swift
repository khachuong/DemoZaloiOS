//
//  ViewController.swift
//  demozalo
//
//  Created by blackhat on 02/11/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

class ViewController: MessagesViewController, MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate, InputBarAccessoryViewDelegate {
    let chuongNkSender = Sender(senderId: "cucnth", displayName: "Hồng Cúc")
   
    var messages: [ChatMessage] = []
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().signInAnonymously()
        ref = Database.database().reference()
        getMessages()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    
    func getMessages() {
        messages = []
        ref.queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) -> Void in
            for child in snapshot.children {
                let data = child as! DataSnapshot
                if let value = data.value as? [String: Any] {
                    let senderID = value["senderID"] as! String
                    let sendeName = value["senderName"] as! String
                    let message =  value["text"] as! String
                    let newMessage = ChatMessage(sender: Sender(senderId: senderID, displayName: sendeName), sentDate: Date(), kind: .text(message), messageId: UUID().uuidString)
                    self.messages.append(newMessage)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
             }
        })
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = ""
        self.ref.child("messages").childByAutoId().setValue(["text": text, "senderName": chuongNkSender.displayName, "senderID": chuongNkSender.senderId])
        getMessages()
    }
    
    var currentSender: SenderType {
            return chuongNkSender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

public struct Sender: SenderType {
    public let senderId: String

    public let displayName: String
}


public struct ChatMessage: MessageType {
    public var sender: MessageKit.SenderType
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
    public let messageId: String
    
}


