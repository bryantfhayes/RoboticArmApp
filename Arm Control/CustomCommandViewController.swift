//
//  CustomCommandViewController.swift
//  Arm Control
//
//  Created by BryantHayes on 5/14/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import UIKit

class CustomCommandViewController: UIViewController {

    // MARK: - Variables
    let alert = UIAlertController(title: "Error!", message:"Message not acknowledged!", preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default) { _ in }
    
    // MARK: - IBOutlets
    @IBOutlet weak var commandEntrybox: UITextField!
    
    // MARK: - IBActions
    @IBAction func sendButtonPressed(sender: AnyObject) {
        if let msg = commandEntrybox.text {
            let status = SocketSingleton.sharedInstance.setCommand(msg)
            if !status {
                self.presentViewController(self.alert, animated: true){}
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.addAction(okAction)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomCommandViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

