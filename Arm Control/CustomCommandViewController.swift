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
    var selectedKeypoint: Int = -1
    var keypointStatus: [Bool] = [true, true, true, true, true, true, true, true]
    
    // MARK: - IBOutlets
    @IBOutlet weak var commandEntrybox: UITextField!
    @IBOutlet var keypointBtn: [UIButton]!
    
    // MARK: - IBActions
    @IBAction func sendButtonPressed(sender: AnyObject) {
        if let msg = commandEntrybox.text {
            let status = SocketSingleton.sharedInstance.setCommand(msg)
            if !status {
                let alert = UIAlertController(title: "Error!", message:"Message not acknowledged!", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default) { _ in }
                alert.addAction(okAction)
                
                self.presentViewController(alert, animated: true){}
            }
        }
        
    }
    
    @IBAction func updateButtonPressed(sender: AnyObject) {
        var sendStr = "custom_keypoints"
        for i in 0...keypointStatus.count-1 {
            if keypointStatus[i] {
                sendStr += ",1"
            } else {
                sendStr += ",0"
            }
        }
        SocketSingleton.sharedInstance.setCommand(sendStr)
        print(sendStr)
    }
    
    @IBAction func goodButtonPressed(sender: AnyObject) {
        keypointStatus[selectedKeypoint] = true
        keypointBtn[selectedKeypoint].setImage(UIImage(named: "\(selectedKeypoint)"), forState: .Normal)
        selectedKeypoint = -1
    }
    
    @IBAction func badButtonPressed(sender: AnyObject) {
        keypointStatus[selectedKeypoint] = false
        keypointBtn[selectedKeypoint].setImage(UIImage(named: "\(selectedKeypoint)_red"), forState: .Normal)
        selectedKeypoint = -1
    }
    
    @IBAction func keyButtonPressed(sender: AnyObject) {
        let idx = sender.tag
        if selectedKeypoint == -1 {
            let status = SocketSingleton.sharedInstance.setCommand("kp,\(idx)")
            if status {
                keypointBtn[idx].setImage(UIImage(named: "\(idx)_yellow"), forState: .Normal)
                selectedKeypoint = idx
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

