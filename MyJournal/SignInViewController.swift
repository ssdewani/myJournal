//
//  SignInViewController.swift
//  MyJournal
//
//  Created by Salim Dewani on 1/20/17.
//  Copyright © 2017 Salim Dewani. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

var uid: String!
var storageRef: FIRStorageReference!
var ref: FIRDatabaseReference!
var storage: FIRStorage!



class SignInViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func firebaseLogin(_ credential: FIRAuthCredential) {
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            uid =  user!.uid
            ref = FIRDatabase.database().reference()
            storage = FIRStorage.storage()
            storageRef = storage.reference(forURL: "gs://myjournal-d55cc.appspot.com")
            self.performSegue(withIdentifier: "showTableSegue", sender: self)
            
            if let error = error {
                return
            }
        }
    }
    

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
