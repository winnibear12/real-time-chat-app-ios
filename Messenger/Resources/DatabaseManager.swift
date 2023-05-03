//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Simon Lee on 2023-04-19.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String)->String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
}

// MARK: - Account Management

extension DatabaseManager{
    
    public func userExists(with email: String, compeletion:@escaping((Bool)->Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else{
                compeletion(false)
                return
            }
            
            compeletion(true)
        })
        
    }
    
    
    
    ///Inserts new user to Database
    public func insertUser(with user: ChatAppUser, completion:@escaping(Bool)->Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: {error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]{
                    //append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                         "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                }
                else{
                    //create that array
                    let newCollection: [[String:String]]=[
                        ["name": user.firstName + " " + user.lastName,
                         "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                }
            })
            
            
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else{
                completion(.failure(DatabaseErrror.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseErrror: Error{
        case failedToFetch
    }
}

/*
 
    users => [
 
        [
            "name":
            "safe_email":
        ],
        [
            "name":
            "safe_email":
        ]
    ]
 
 */


//MARK: - Sending messages / conversations

extension DatabaseManager{
    
    /*
        "fsdafewfs" {
            "messages":[
                {
                    "id": String,
                    "type": text, photo, video,
                    "content": String,
                    "date": Date(),
                    "sender_email": String,
                    "isRead": true/false,
     
                }
     
            ]
        
        }
        
     
        conversation => [
     
            [
                "conversation_id": "fsdafewfs"
                "other_user_email":
                "latest_message": => {
                    "date: Date()
                    "latest_message": "message"
                    "is_read": true/false
                }
            ],
        ]
     
     */
    
    // Creates a new conversation with target user email and first messgae sent
    public func createNewConversation(with otherUserEmail: String, firstMessage:Message, completion: @escaping (Bool)->Void ){
        //44:03
    }
    
    // Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void){
        
    }
    
    // Gets all messagees for a givven conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>)->Void){
        
    }
    
    // Sends a message with tarfet conversation and message
    public func sendMessage(to conversation: String, message: Message,compeletion: @escaping (Bool)->Void){
        
        
    }
    
}


struct ChatAppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
        
    }
    
    var profilePictureFileName: String{
        //winnibear12-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}


