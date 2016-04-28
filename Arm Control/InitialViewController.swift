//
//  InitialViewController.swift
//  Arm Control
//
//  Created by BryantHayes on 4/28/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    // MARK: - Variables
    
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    @IBAction func onButtonPressed(sender: AnyObject) {
        SocketSingleton.sharedInstance.sendPacket("on:\0\n")
        performSegueWithIdentifier("toMainViewControllerSegue", sender: nil)
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        SocketSingleton.sharedInstance.sendPacket("off:\0\n")
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}