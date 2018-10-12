//
//  GestureLockDemoViewController.swift
//  CCGestureLockSwift
//
//  Created by Hsuan-Chih Chuang on 12/04/2017.
//  Copyright (c) 2017 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit
import CCGestureLock

class GestureLockDemoViewController: UIViewController {

    
    @IBOutlet weak var gestureLock : CCGestureLock!
    @IBOutlet weak var controlView : UIView!
    @IBOutlet weak var leftButton : UIButton!
    @IBOutlet weak var rightButton : UIButton!
    
    private enum LockMode {
        
        case unlocked
        case locked
    }
    private var lockMode : LockMode {
        get {
            return Password.lockSequence == nil ? .unlocked : .locked
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupGestureLock()
        setupControlPanel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func enableButtons(_ enable: Bool) {
        
        [leftButton, rightButton].forEach { (button) in
            button?.isEnabled = enable
            button?.alpha = enable ? 1 : 0.5
        }
    }
    private func setupButtons() {
        
        [leftButton, rightButton].forEach { (button) in
            
            button?.layer.cornerRadius = 5
            button?.layer.borderColor = UIColor.white.cgColor
            button?.layer.borderWidth = 2
            button?.addTarget(
                self,
                action: #selector(buttonTapped),
                for: .touchUpInside
            )
        }
    }
    
    private func setupControlPanel() {
        
        controlView.isHidden = lockMode == .locked
        if !controlView.isHidden {
            setupButtons()
            enableButtons(false)
        }
    }
    
    private func setupGestureLock() {
        
        // Set number of sensors
        gestureLock.lockSize = (3, 3)
        
        // Sensor grid customisations
        gestureLock.edgeInsets = UIEdgeInsetsMake(30, 30, 30, 30)
        
        // Sensor point customisation (normal)
        gestureLock.setSensorAppearance(
            type: .inner,
            radius: 5,
            width: 1,
            color: .white,
            forState: .normal
        )
        gestureLock.setSensorAppearance(
            type: .outer,
            color: .clear,
            forState: .normal
        )
        
        // Sensor point customisation (selected)
        gestureLock.setSensorAppearance(
            type: .inner,
            radius: 3,
            width: 5,
            color: .white,
            forState: .selected
        )
        gestureLock.setSensorAppearance(
            type: .outer,
            radius: 30,
            width: 5,
            color: .green,
            forState: .selected
        )
        
        // Sensor point customisation (wrong password)
        gestureLock.setSensorAppearance(
            type: .inner,
            radius: 3,
            width: 5,
            color: .red,
            forState: .error
        )
        gestureLock.setSensorAppearance(
            type: .outer,
            radius: 30,
            width: 5,
            color: .red,
            forState: .error
        )
        
        // Line connecting sensor points (normal/selected)
        [CCGestureLock.GestureLockState.normal, CCGestureLock.GestureLockState.selected].forEach { (state) in
            gestureLock.setLineAppearance(
                width: 5.5,
                color: UIColor.white.withAlphaComponent(0.5),
                forState: state
            )
        }
        
        // Line connection sensor points (wrong password)
        gestureLock.setLineAppearance(
            width: 5.5,
            color: UIColor.red.withAlphaComponent(0.5),
            forState: .error
        )
        
        gestureLock.addTarget(
            self,
            action: #selector(gestureComplete),
            for: .gestureComplete
        )
        
    }
    
    @objc func buttonTapped(button: UIButton) {
        
        if button == rightButton {
            Password.lockSequence = gestureLock.lockSequence
            dismiss(animated: true, completion: nil)
        } else {
            gestureLock.gestureLockState = .normal
            enableButtons(false)
        }
        
    }
    
    @objc func gestureComplete(gestureLock: CCGestureLock) {
        
        if lockMode == .locked {
            
            if Password.lockSequence! == gestureLock.lockSequence {
                
                Password.lockSequence = nil
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                
                gestureLock.gestureLockState = .error
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    gestureLock.gestureLockState = .normal
                })
            }
            
        } else {
            enableButtons(true)
        }
    }
}

struct Password {
    
    static let passwordKey = "password"
    
    static var lockSequence : [NSNumber]? {
        get {
            return UserDefaults.standard.array(forKey: passwordKey) as? [NSNumber]
        }
        set (lockSequence) {
            UserDefaults.standard.set(lockSequence, forKey: passwordKey)
        }
    }
}
