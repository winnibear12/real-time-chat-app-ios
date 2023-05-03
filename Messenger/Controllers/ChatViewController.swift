//
//  ChatViewController.swift
//  Messenger
//
//  Created by Simon Lee on 2023-04-23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message:MessageType{
    
   public var sender: MessageKit.SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKit.MessageKind
    
}

extension MessageKind{
    var messageKindString: String{
        switch self{
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}


struct Sender: SenderType{
    
    var photoURL: String
    var senderId: String
    var displayName: String
}


class ChatViewController: MessagesViewController {
    
    public static var dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        
        return formattre
    }()
    
    public let otherUserEmail: String
    public var isNewConversation = false
    
    
    private var messages = [Message]()
    
    private var selfSender: Sender?{
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        
        return Sender(photoURL: "",
               senderId: email,
               displayName: "Simon")
    }
    
    init(with email: String){
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder: has not been implemented") 
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()

        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
      
        
//        DispatchQueue.main.async {
//               self.messagesCollectionView.reloadData()
//               self.messagesCollectionView.scrollToLastItem(animated: false)
//           }
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    


}

extension ChatViewController: InputBarAccessoryViewDelegate{
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
        let selfSender = self.selfSender,
        let messageId = createMessageId() else{
            return
        }
        
        print("Sending: \(text)")
        
        //send message
        if isNewConversation{
            //create convo in database
            let mmessage = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: mmessage, completion: { success in
                if success{
                    print("message sent")
                }
                else{
                    print("failed to send")
                }
            })
            
        }
        else{
            //append to existing conversation data
        }
        
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        
       
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created message id: \(newIdentifier)")
        
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    var currentSender: MessageKit.SenderType {
        if let sender = selfSender{
            return sender
        }
            fatalError("Self Sender is nil, email should be cached")
            return Sender(photoURL: "", senderId: "12", displayName: "")
    }

    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
}


