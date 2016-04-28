//
//  SettingsViewController.swift
//  Arm Control
//
//  Created by BryantHayes on 4/28/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Variables
    
    // MARK: - IBOutlets
    @IBOutlet weak var targetIpLabel: UILabel!
    @IBOutlet weak var targetPortLabel: UILabel!
    
    // MARK: - IBActions
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        targetIpLabel.text = "\(SocketSingleton.sharedInstance.addr)"
        targetPortLabel.text = "\(SocketSingleton.sharedInstance.port)"
    }
}