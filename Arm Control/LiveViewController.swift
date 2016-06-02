//
//  LiveViewController.swift
//  Arm Control
//
//  Created by BryantHayes on 5/14/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import UIKit

//TODO: two calibrations in a row doesnt work

enum Gamemode: String {
    case ready = "Game Status: Waiting for trigger"
    case fish_smart = "Game Status: Running"
}

extension UITextView {
    
    func scrollToBottom() {
        let range = NSMakeRange(text.characters.count - 1, 1);
        scrollRangeToVisible(range);
    }
    
}

class LiveViewController: UIViewController {

    // MARK: - Variables
    var boardAngle: Double?
    var timer: NSTimer?
    var gamemode: Gamemode = .ready
    var gameover = false
    var boardSpeed: Double?
    var messageBuffer: String = ""
    var timeRemaining = 120
    
    // MARK: - IBOutlets
    @IBOutlet weak var boardImg: UIImageView!
    @IBOutlet weak var gameStatusLbl: UILabel!
    @IBOutlet weak var boardSpeedLbl: UILabel!
    @IBOutlet weak var boardAngleLbl: UILabel!
    @IBOutlet weak var logTextbox: UITextView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var stopBtn: UIButton!
    
    // MARK: - IBActions
    @IBAction func standbyButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("unwindToMainSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let status = SocketSingleton.sharedInstance.setCommand("ready")
        if !status {
            let alert = UIAlertController(title: "Error!", message:"Message not acknowledged!", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { _ in }
            alert.addAction(okAction)
            
            // Present alert
            self.presentViewController(alert, animated: true){}
            
            // Go back to main view
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LiveViewController.update), userInfo: nil, repeats: true)
    }
    
    func update() {
        if gamemode == .ready {
            timeRemaining = 120
            stopBtn.enabled = true
            timerLbl.textColor = UIColor.whiteColor()
        } else if gamemode == .fish_smart {
            if timeRemaining > 0 {
               timeRemaining -= 1
            } else {
                timerLbl.textColor  = UIColor.redColor()
            }
            
            stopBtn.enabled = false
        }
        let (_,m,s) = secondsToHoursMinutesSeconds(timeRemaining)
        timerLbl.text = String(format: "%d:%02d", m, s)
        gameStatusLbl.text = gamemode.rawValue
        if let speed = boardSpeed {
            boardSpeedLbl.text = String(format:"Board Speed: %.2lf sec/rev", (speed*8)/1000)
        } else {
            boardSpeedLbl.text = "Board Speed: Unknown"
        }
        
        logTextbox.text! += messageBuffer
        logTextbox.scrollToBottom()
        messageBuffer = ""
    }
    
    func getMessages() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            while !self.gameover {
                let (status, msg) = SocketSingleton.sharedInstance.readPacket()
                if status {
                    if msg == "idle,ok" {
                        break
                    }
                    let data = msg.componentsSeparatedByString(":")
                    if data.count == 2 {
                        if data[0] == "state" {
                            if data[1] == "ready" {
                                self.gamemode = .ready
                            } else if data[1] == "fish_smart" {
                                self.gamemode = .fish_smart
                            }
                        } else if data[0] == "info" {
                            self.messageBuffer += data[1]
                        } else if (data[0] == "speed") {
                            self.boardSpeed = Double(data[1])
                        }
                    }
                }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let angle = boardAngle{
            boardAngleLbl.text = String(format: "Board Angle: %.2lfº", angle)
            boardImg.transform = CGAffineTransformMakeRotation((-CGFloat(angle) * CGFloat(M_PI)) / 180.0)
        } else {
            boardAngleLbl.text = "Board Angle: Unknown"
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        getMessages()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @IBAction func stopButtonPressed(sender: AnyObject) {
        let status = SocketSingleton.sharedInstance.setCommand("idle")
        if status {
            self.gameover = true
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
