//
//  ViewController.swift
//  CCGestureLock
//
//  Created by Hsuan-Chih Chuang on 04/13/2017.
//  Copyright (c) 2017 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        present(
            GestureLockDemoViewController(),
            animated: true,
            completion: nil
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

