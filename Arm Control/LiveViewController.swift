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
    var boardAngle: Double?
    
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
    
    override func viewWillAppear(animated: Bool) {
        if let angle = boardAngle{
            boardAngleLbl.text = String(format: "Board Angle: %.2lfº", angle)
            boardImg.transform = CGAffineTransformMakeRotation((-CGFloat(angle) * CGFloat(M_PI)) / 180.0)
        } else {
            boardAngleLbl.text = "Board Angle: Unknown"
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
