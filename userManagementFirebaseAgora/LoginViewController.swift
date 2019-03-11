//
//  LoginViewController.swift
//  userManagementFirebaseAgora
//
//  Created by Floyd 2001 on 3/5/19.
//  Copyright © 2019 Agora.io. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var userAuthenticated: AuthDataResult?
    
    @IBOutlet weak var textFieldEmailAddress: UITextField!
    @IBOutlet weak var textFieldEmailPassword: UITextField!
    
    @IBOutlet weak var labelSignInStatus: UILabel!
    
    @IBAction func userDidTapButtonSignIn(_ sender: UIButton) {
        
        if let email = textFieldEmailAddress?.text, let password = textFieldEmailPassword?.text {
         
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if let u = user {
                    // User is found,
                        print(u.user.email ?? "Display Name")
                    self.userAuthenticated = u
                    self.performSegue(withIdentifier: "joinToChannel", sender: nil)
                    
                } else {
                    print("\(String(describing: error?.localizedDescription))")
                }
                
            })
            
        }
        
}
    
    @IBAction func userDidTapButtonRegister(_ sender: Any) {
        
    if let email = textFieldEmailAddress?.text, let password = textFieldEmailPassword?.text {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        
                        if let u = user {
                            
                            print(u.user.email!)
                            
                        } else {
                            print("User's email registration failed.")
                            print("\(String(describing: error?.localizedDescription))")
                        }
                        
                    })
                }
    
            }
    
    @IBAction func userDidTapJoinChannelButton(_ sender: Any) {
        
         //        performSegue(withIdentifier: "loginToChannel", sender: UIButton.self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.userAuthenticated = userAuthenticated
            print("prepare for segue ran.")
        } else {
            print("prepare for segue did not run.")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textFieldEmailAddress.resignFirstResponder()
        textFieldEmailPassword.resignFirstResponder()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        handle = Auth.auth().addStateDidChangeListener {
            (auth, user) in
        }
    }
    
}
