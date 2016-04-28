//
//  MainViewController.swift
//  Arm Control
//
//  Created by BryantHayes on 4/28/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Variables
    var coordinates: [Int] = [0,35,-15]
    let upValue = -15
    let downValue = -23
    
    // MARK: - IBOutlets
    @IBOutlet weak var xPositionSlider: UISlider!
    @IBOutlet weak var yPositionSlider: UISlider!
    @IBOutlet weak var xPositionLabel: UILabel!
    @IBOutlet weak var yPositionLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("toSettingsViewControllerSegue", sender: nil)
    }
    
    @IBAction func xSliderChanged(sender: UISlider) {
        xPositionLabel.text = "X = \(Int(sender.value))"
    }
    
    @IBAction func xSliderDone(sender: UISlider) {
        coordinates[0] = Int(sender.value)
        SocketSingleton.sharedInstance.sendXYZ(coordinates)
    }
    
    @IBAction func ySliderChanged(sender: UISlider) {
        yPositionLabel.text = "Y = \(Int(sender.value))"
    }
    
    @IBAction func ySliderDone(sender: UISlider) {
        coordinates[1] = Int(sender.value)
        SocketSingleton.sharedInstance.sendXYZ(coordinates)
    }
    
    @IBAction func upButtonPressed(sender: AnyObject) {
        coordinates[2] = upValue
        SocketSingleton.sharedInstance.sendXYZ(coordinates)
    }
    
    @IBAction func downButtonPressed(sender: AnyObject) {
        coordinates[2] = downValue
        SocketSingleton.sharedInstance.sendXYZ(coordinates)
    }
    
    @IBAction func unwindFromSettings(unwindSegue: UIStoryboardSegue) {

    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}