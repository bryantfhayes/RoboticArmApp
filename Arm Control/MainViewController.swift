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
    var armCalibrated: Bool = false
    var camCalibrated: Bool = false
    let upValue = -15
    let downValue = -23
    let alert = UIAlertController(title: "Error!", message:"Message not acknowledged!", preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default) { _ in }
    var isLoading = false
    var startedLoading = false
    var boardAngle: Double?
    
    // MARK: - IBOutlets

    @IBOutlet weak var standbyButton: UIButton!
    @IBOutlet weak var calibrateArmButton: UIButton!
    @IBOutlet weak var calibrateCamButton: UIButton!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var customCommandButton: UIButton!
    @IBOutlet weak var bgOverlayImg: UIImageView!
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var calibratingLbl: UILabel!
    
    // MARK: - IBActions

    @IBAction func customCommandButtonPressed(sender: AnyObject) {
        //SocketSingleton.sharedInstance.flushBuffer()
        performSegueWithIdentifier("toCustomCommandViewControllerSegue", sender: nil)
    }
    
    @IBAction func standbyButtonPressed(sender: AnyObject) {
        let status = SocketSingleton.sharedInstance.setCommand("idle")
        if !status {
            self.presentViewController(self.alert, animated: true){}
        }
    }
    
    @IBAction func calibrateArmButtonPressed(sender: AnyObject) {
        let status = SocketSingleton.sharedInstance.setCommand("calibrate_arm")
        if !status {
            self.presentViewController(self.alert, animated: true){}
        } else {
            armCalibrated = true
            calibrateArmButton.setImage(UIImage(named: "CalibrateArmButtonGreen"), forState: .Normal)
        }
    }
    
    @IBAction func calibrateCameraButtonPressed(sender: AnyObject) {
        let status = SocketSingleton.sharedInstance.setCommand("calibrate_cam")
        if !status {
            self.presentViewController(self.alert, animated: true){}
        } else {
            self.isLoading = true
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue) {
                while true {
                    let (status, msg) = SocketSingleton.sharedInstance.readPacket()
                    if status {
                        if msg == "error" {
                            self.camCalibrated = false
                            self.calibrateCamButton.setImage(UIImage(named: "CalibrateCameraButtonRed"), forState: .Normal)
                        } else {
                            self.boardAngle = Double(msg)
                            self.camCalibrated = true
                            self.calibrateCamButton.setImage(UIImage(named: "CalibrateCameraButtonGreen"), forState: .Normal)
                        }
                        self.isLoading = false
                        break
                    }
                    
                }

            }
            
            
        }
    }
    
    @IBAction func readyButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("toLiveViewControllerSegue", sender: nil)
    }
    
    @IBAction func unwindToMain(unwindSegue: UIStoryboardSegue) {

    }
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(MainViewController.updateUI), userInfo: nil, repeats: true)
        alert.addAction(okAction)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        print("Clearing buffer!")
        SocketSingleton.sharedInstance.flushBuffer()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func updateUI() {
        if isLoading && !startedLoading {
            startedLoading = true
            startLoading()
        } else if !isLoading && startedLoading {
            startedLoading = false
            stopLoading()
        }
        
        if armCalibrated && !isLoading {
            calibrateCamButton.enabled = true
        } else {
            calibrateCamButton.enabled = false
        }
        if camCalibrated && armCalibrated && !isLoading{
            readyButton.enabled = true
            readyButton.setImage(UIImage(named: "ReadyButtonGreen"), forState: .Normal)
        } else {
            readyButton.enabled = false
            readyButton.setImage(UIImage(named: "ReadyButtonWhite"), forState: .Normal)
        }
    }
    
    func startLoading() {
        isLoading = true
        calibratingLbl.hidden = false
        bgOverlayImg.hidden = false
        activityMonitor.hidden = false
        standbyButton.enabled = false
        calibrateArmButton.enabled = false
        calibrateCamButton.enabled = false
        readyButton.enabled = false
        customCommandButton.enabled = false
        backButton.enabled = false
        activityMonitor.startAnimating()
    }
    
    func stopLoading() {
        calibratingLbl.hidden = true
        bgOverlayImg.hidden = true
        activityMonitor.hidden = true
        standbyButton.enabled = true
        calibrateArmButton.enabled = true
        calibrateCamButton.enabled = true
        readyButton.enabled = true
        customCommandButton.enabled = true
        backButton.enabled = true
        self.bgOverlayImg.hidden = true
        self.activityMonitor.hidden = true
        self.activityMonitor.stopAnimating()
        isLoading = false
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toLiveViewControllerSegue" {
            let destinationVC = segue.destinationViewController as! LiveViewController
            destinationVC.boardAngle = self.boardAngle
        }
    }
}