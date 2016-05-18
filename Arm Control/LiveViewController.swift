//
//  LiveViewController.swift
//  Arm Control
//
//  Created by BryantHayes on 5/14/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    // MARK: - Variables
    
    // MARK: - IBOutlets
    @IBOutlet weak var boardImg: UIImageView!
    @IBOutlet weak var gameStatusLbl: UILabel!
    @IBOutlet weak var boardSpeedLbl: UILabel!
    @IBOutlet weak var boardAngleLbl: UILabel!
    @IBOutlet weak var logTextbox: UITextView!
    
    // MARK: - IBActions
    @IBAction func standbyButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("unwindToMainSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
