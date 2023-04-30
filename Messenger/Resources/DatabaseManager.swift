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
            completion(true)
        })
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


