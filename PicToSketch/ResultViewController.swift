//
//  ResultViewController.swift
//  PicToSketch
//
//  Created by 김효석 on 2022/11/14.
//

import Foundation
import UIKit
 
class ResultViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    @IBAction func saveImageButton(_ sender: UIImage) {
        UIImageWriteToSavedPhotosAlbum(resultImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // notification 이라는 방송 수신기 장착
        NotificationCenter.default.addObserver(self, selector: #selector(recieveImage(_:)), name: NSNotification.Name(rawValue: "imageNotification"), object: nil)
    }
    
    
    @objc fileprivate func recieveImage(_ notification: NSNotification) {
        print("ResultViewController - recieveImage() called")
        if let resultImage = notification.userInfo?["ResultImage"] as? UIImage {
            self.resultImageView.image = resultImage
        }
    }
    
    @objc fileprivate func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Failed! 라이브러리 접근 권한을 확인해주세요.", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "스케치 이미지가 라이브러리에 저장되었습니다.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
