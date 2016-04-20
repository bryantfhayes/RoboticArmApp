//
//  ViewController.swift
//  Arm Control
//
//  Created by BryantHayes on 4/14/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    enum Mode: Int {
        case Move = 0
        case Train = 1
        case Select = 2
    }
    
    //
    // Variables
    //
    let updateInterval = 0.05
    
    let iPhone_Y_Max = 414.0
    let iPhone_X_Max = 736.0
    let granularityFactor = 1.0
    let xRange = [-10.0,10.0]
    let yRange = [10.0,25.0]
    
    var addr: String =  "edison.local"
    var port: Int = 21224
    var client: UDPClient?
    var coordinatesArray: [Double] = [0.0,20.0,0.0]
    
    var referenceYaw: Double = 0.0
    var currentYaw: Double = 0.0
    
    var touching: Bool = false
    var startingTouch: [Double] = [0,0]
    var currentTouch: [Double] = [0,0]
    
    var _currentMode: Mode = Mode.Move
    
    var currentMode: Mode {
        get {
            return _currentMode
        }
        
        set {
            if newValue == Mode.Move {
                // If coming from training mode, save position
                if _currentMode == Mode.Train {
                    boardParentView.hidden = false
                    rotationSlider.hidden = false
                    keyLocationValues[selectedBtn!] = [coordinatesArray[0], coordinatesArray[1]]
                    print(keyLocationValues)
                    instructionLbl.text = "Location #\(selectedBtn!) saved!"
                } else {
                    instructionLbl.text = " "
                }
                trainBtn.setTitle("TRAIN", forState: UIControlState.Normal)
                
                _currentMode = Mode.Move
            } else if newValue == Mode.Select {
                boardParentView.hidden = false
                rotationSlider.hidden = false
                trainBtn.setTitle("CANCEL", forState: UIControlState.Normal)
                instructionLbl.text = "Select a location"
                _currentMode = Mode.Select
            } else if newValue == Mode.Train {
                boardParentView.hidden = true
                rotationSlider.hidden = true
                trainBtn.setTitle("SAVE", forState: UIControlState.Normal)
                instructionLbl.text = "Goto a Location"
                _currentMode = Mode.Train
            }
        }
    }
    var selectedBtn: Int?
    var currentDegrees: Double = 0.0
    var keyLocationValues = Dictionary<Int, Array<Double>>()
    
    var boardDistance: Double = 20.0
    
    //
    // IBOutlets
    //
    @IBOutlet weak var zSlider: UISlider!
    @IBOutlet weak var rotationSlider: UISlider!
    @IBOutlet weak var coordinateLabel: UILabel!
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var trainBtn: UIButton!
    @IBOutlet weak var boardImg: UIImageView!
    @IBOutlet weak var boardParentView: UIView!
    @IBOutlet var keyLocationBtns: [UIButton]!
    @IBOutlet weak var degreesLbl: UILabel!
    
    
    //
    // IBActions
    //
    @IBAction func zSliderChanged(sender: AnyObject) {
        coordinatesArray[2] = Double(zSlider.value)
        if currentMode == Mode.Move {
            let coordinates = String(format: "%.2lf,%.2lf,%.2lf", coordinatesArray[0], coordinatesArray[1], coordinatesArray[2])
            coordinateLabel.text = coordinates
            // Send a packet
            sendPacket()
        }
    }
    
    @IBAction func onTrainPressed(sender: AnyObject) {
        if currentMode == Mode.Move {
            currentMode = Mode.Select
        } else if currentMode == Mode.Select {
            currentMode = Mode.Move
        } else if currentMode == Mode.Train {
            currentMode = Mode.Move
        }
    }
    
    @IBAction func rotationSliderChanged(sender: AnyObject) {
        let degrees = Double(rotationSlider.value)
        let degreeDelta = degrees - currentDegrees
        degreesLbl.text = "\(Int(degrees)) degs"
        boardParentView.transform = CGAffineTransformMakeRotation((CGFloat(-degrees) * CGFloat(M_PI)) / 180.0)
        rotateButtons(degrees)
        
        print ("Slider changed from \(currentDegrees) to \(degrees). A change of \(degrees - currentDegrees)")
        currentDegrees = degrees
     
        rotateKeyLocations(degreeDelta)
    }
    
    @IBAction func btnPressed(btn: AnyObject) {
        if currentMode == Mode.Select {
            selectedBtn = btn.tag
            currentMode = Mode.Train
        } else if currentMode == Mode.Move {
            // Go to saved location
            if let loc = keyLocationValues[btn.tag] {
                coordinatesArray[0] = loc[0]
                coordinatesArray[1] = loc[1]
                let coordinates = String(format: "%.2lf,%.2lf,%.2lf", coordinatesArray[0], coordinatesArray[1], coordinatesArray[2])
                coordinateLabel.text = coordinates
                // Send a packet
                sendPacket()
                
                //TEMP
                //_ = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector: #selector(ViewController.spin), userInfo: nil, repeats: true)
                
                
            } else {
                coordinateLabel.text = "Location not trained!"
            }
        }
    }
    
    
    
    //
    // Functions
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UDP Connection
        self.client = UDPClient(addr: self.addr, port: self.port)
        _ = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target:self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        zSlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
    }
    
    func update(){
        if currentMode == Mode.Train {
            let coordinates = String(format: "%.2lf,%.2lf,%.2lf", coordinatesArray[0], coordinatesArray[1], coordinatesArray[2])
            coordinateLabel.text = coordinates
            // Send a packet
            sendPacket()
        }
    }
    
    func rotateKeyLocations(theta: Double) {
        for (key, value) in keyLocationValues {
            let relative_y = value[1] - boardDistance
            let new_x = value[0]*cosd(theta) - relative_y*sind(theta)
            let new_y = (value[0]*sind(theta) + relative_y*cosd(theta)) + boardDistance
            
            print("Changing \(value[0]),\(value[1]) to \(new_x),\(new_y) due to change of \(theta) degrees")
            
            keyLocationValues[key]![0] = new_x
            keyLocationValues[key]![1] = new_y
            
        }
    }
    
    func rotateButtons(degrees: Double){
        for btn in keyLocationBtns {
            btn.transform = CGAffineTransformMakeRotation((CGFloat(degrees) * CGFloat(M_PI)) / 180.0)
        }
    }
    
    func map(n: Double, x1: Double, x2: Double, y1: Double, y2: Double) -> Double{
        let slope: Double = 1.0 * (y2 - y1) / (x2 - x1)
        let output = y1 + slope * (n - x1)
        return output
    }
    
    func sendPacket(){
        let coordinates = String(format: "%.2lf,%.2lf,%.2lf\0\n", coordinatesArray[0], coordinatesArray[1], coordinatesArray[2])
        self.client?.send(str: "\(coordinates)")
        print("\(coordinates)")
    }
    
    func sind(degrees: Double) -> Double {
        return sin((degrees * M_PI / 180.0))
    }
    
    func cosd(degrees: Double) -> Double {
        return cos(degrees * M_PI / 180.0)
    }
    
    func spin(){
        rotateKeyLocations(-7.5)
        if let loc = keyLocationValues[selectedBtn!] {
            coordinatesArray[0] = loc[0]
            coordinatesArray[1] = loc[1]
            let coordinates = String(format: "%.2lf,%.2lf,%.2lf", coordinatesArray[0], coordinatesArray[1], coordinatesArray[2])
            coordinateLabel.text = coordinates
            // Send a packet
            sendPacket()
        }
    }
    
    
    //
    // Touch Handling
    //
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touching = true
        let touch = touches.first!.locationInView(view)
        let x = Double(touch.x)
        let y = Double(touch.y)
        let x2 = map(x, x1: 0, x2: iPhone_X_Max, y1: 0, y2: 40)
        let y2 = map(y, x1: iPhone_Y_Max, x2: 0, y1: 10, y2: 25)
        
        if currentMode == Mode.Train {
            coordinatesArray[0] = x2-20
            coordinatesArray[1] = y2
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!.locationInView(view)
        let x = Double(touch.x)
        let y = Double(touch.y)
        let x2 = map(x, x1: 0, x2: iPhone_X_Max, y1: 0, y2: 40)
        let y2 = map(y, x1: iPhone_Y_Max, x2: 0, y1: 10, y2: 25)
    
        if currentMode == Mode.Train {
            coordinatesArray[0] = x2-20
            coordinatesArray[1] = y2
        }
        
    }
    
}

