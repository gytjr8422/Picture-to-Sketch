//
//  CustomImageView.swift
//  PicToSketch
//
//  Created by 김효석 on 2022/11/21.
//

import Foundation
import UIKit

class CustomImageView: UIImageView {
    override func layoutSubviews() {
        self.layer.cornerRadius = 8
    }
}
