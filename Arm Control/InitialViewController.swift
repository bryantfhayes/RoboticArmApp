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
    @IBOutlet weak var errorLbl: UILabel!
    
    // MARK: - IBActions
    @IBAction func onStartButtonPressed(sender: AnyObject) {
        /*
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            let someData = getData(username, password)
            /* do something with someData */
        }
        */
        
        let success = SocketSingleton.sharedInstance.ping()
        if success {
            performSegueWithIdentifier("toMainViewControllerSegue", sender: nil)
        } else {
            errorLbl.hidden = false
            NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(InitialViewController.hideErrorLbl), userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        //SocketSingleton.sharedInstance.sendPacket("off:\0\n")
    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        errorLbl.hidden = true;
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func hideErrorLbl() {
        errorLbl.hidden = true
    }
}