//
//  CustomButton.swift
//  PicToSketch
//
//  Created by 김효석 on 2022/11/08.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 8
        if self.isHighlighted == true {
            self.layer.backgroundColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor(named: "BackgroundColor")?.cgColor
        } else {
            self.layer.backgroundColor = UIColor(named: "ButtonColor")?.cgColor
            self.layer.borderWidth = 0
        }
    }
}
