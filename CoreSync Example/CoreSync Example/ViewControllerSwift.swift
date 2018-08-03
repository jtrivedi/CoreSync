//
//  ViewControllerSwift.swift
//  CoreSync Example
//
//  Created by Tom Baranes on 03/08/2018.
//  Copyright © 2018 jtrivedi. All rights reserved.
//

import UIKit
import CoreSync

class ViewControllerSwift: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let A = [String: Any]()
        let B = [String: Any]()
        CoreSync.diff(asJSON: A, B)
    }

}
