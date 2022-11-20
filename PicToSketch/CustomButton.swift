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
    }
}
