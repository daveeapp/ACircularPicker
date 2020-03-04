//
//  ViewController.swift
//  Example-iOS
//
//  Created by Davee on 2020/3/2.
//  Copyright © 2020 Davee. All rights reserved.
//

import UIKit
import ACircularPicker

class ViewController: UIViewController {
    @IBOutlet weak var circularPicker: ACircularPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        test1()
        
        test2()
    }
    
    func test1() {
        self.circularPicker.options = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"];
        self.circularPicker.drawingIncrement = 3;
        self.circularPicker.selectedIndex = 0;
        self.circularPicker.topLabel = nil
        self.circularPicker.scalePointEnable = true;
        self.circularPicker.addTarget(self, action: #selector(self.onPickerValueChanged(picker:)), for: .valueChanged)
    }
    
    func test2() {
        var labels = [String]()
        for i in 0..<60 {
            labels.append(String(i))
        }
        self.circularPicker.options = labels;
        self.circularPicker.drawingIncrement = 5;
        self.circularPicker.preferSelected(value: "30");
        self.circularPicker.scaleTextSize = 11
        
        self.circularPicker.scalePointEnable = false
        
        self.circularPicker.topLabel = "Speed";
        self.circularPicker.topLabelColor = .blue
        
        self.circularPicker.bottomLabelColor = .blue
        self.circularPicker.textForBottom = { (picker) in
            return picker.selectedValue! + " km/h"
        }
    }

    @objc func onPickerValueChanged(picker: ACircularPicker) {
        print("selected value = " + (picker.selectedValue ?? "nil"))
    }

}

