//
//  ViewController.swift
//  PicToSketch
//
//  Created by 김효석 on 2022/11/08.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
        
    // UIImagePickerController 인스턴스 생성
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var flagImageSave = false // 사진 저장 여부
    
    var resultImage: UIImage?
    var userInfo: [String: UIImage] = [:]
    
    @IBAction func photoLibraryButton(_ sender: UIButton) {
        print("ViewController - photoLibraryButton() clicked")
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            flagImageSave = false
            
            imagePicker.delegate = self // ?? 아직 정확히 이해 못 함
            imagePicker.sourceType = .photoLibrary // 소스 타입을 photoLibrary로 설정
            imagePicker.mediaTypes = [kUTTypeImage as String] // 미디어 형태, MobileCoreServices에 정의되어 있다.
            imagePicker.allowsEditing = false // 편집 허용 여부, true: 허용
            imagePicker.modalPresentationStyle = .overFullScreen
            
            present(imagePicker, animated: true, completion: nil)
        } else {
            myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
        }
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        // 카메라를 사용할 수 있다면
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            flagImageSave = true // 사진 저장 플래그를 true로 설정
            
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            imagePicker.navigationItem.leftBarButtonItem?.title
            
            
            // 뷰 컨트롤러를 imagePicker로 대체
            present(imagePicker, animated: true, completion: nil)
        } else {
            // 카메라를 사용할 수 없을 때 경고 창 출력
            myAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    // 사진 촬영이나 선택이 끝났을 때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 미디어 종류 확인
        // ?? mediaType의 정보?
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        // 미디어가 사진이면
        if mediaType.isEqual(to: kUTTypeImage as NSString as String){
            // 사진 가져오기
            let captureImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            print()
            // flagImageSave가 true 이면 사진을 보관함에 저장
            if flagImageSave {
                UIImageWriteToSavedPhotosAlbum(captureImage, self, nil, nil)
            }
            // 선택한 사진 이미지 뷰에 넣기
//            imgView.image = MyOpenCV.toSketch(captureImage)
            resultImage = MyOpenCV.toSketch(captureImage)
            userInfo = ["ResultImage": resultImage!]
        }
        
        // 화면 닫기
        self.dismiss(animated: true, completion: nil)

        if let resultVC = self.storyboard?.instantiateViewController(identifier: "ResultViewController"){
            // Notification Center
            self.present(resultVC, animated: true) { [weak self] in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "imageNotification"), object: nil, userInfo: self?.userInfo)
            }
        }
    }

    
    // 촬영이나 선택 취소했을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 이미지 피커 제거
        self.dismiss(animated: true, completion: nil)
    }
    
    // 경고 창 츨력
    func myAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

