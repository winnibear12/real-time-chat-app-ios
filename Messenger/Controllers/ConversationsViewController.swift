//
//  ViewController.swift
//  Messenger
//
//  Created by Simon Lee on 2023-04-16.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        validateAuth()
        
        
    }
    
    private func validateAuth(){
        //        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated:false)
        }
        
    }
    
}
