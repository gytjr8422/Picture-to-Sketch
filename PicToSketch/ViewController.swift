//
//  ViewController.swift
//  PicToSketch
//
//  Created by 김효석 on 2022/11/08.
//

import UIKit
import MobileCoreServices
import Photos
import GoogleMobileAds

class ViewController: UIViewController {
    
    // 광고
    var bannerView: GADBannerView!
        
    // UIImagePickerController 인스턴스 생성
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var flagImageSave = false // 사진 저장 여부
    
    var resultImage: UIImage?
    var userInfo: [String: UIImage] = [:]
    
    @IBAction func photoLibraryButton(_ sender: UIButton) {
        print("ViewController - photoLibraryButton() clicked")
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            DispatchQueue.main.async {
                self.openPhotoLibrary()
            }
        } else {
            albumAuth()
        }
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        if AVCaptureDevice.authorizationStatus(for: .video) == AVAuthorizationStatus.authorized {
            DispatchQueue.main.async {
                self.openCamera()
            }
        } else {
            cameraAuth()
//            showAlertAuth("카메라")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // In this case, we instantiate the banner with desired ad size.
        // 배너의 사이즈 설정
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        
        // 광고 배너 아이디 설정
        bannerView.adUnitID = "ca-app-pub-2709183664449693/2947552418"
        bannerView.rootViewController = self
        
        // 광고 로드
        bannerView.load(GADRequest())
        
        // 델리겟을 배너뷰에 연결
        bannerView.delegate = self
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

            resultImage = MyOpenCV.toSketch(captureImage)
            userInfo = ["ResultImage": resultImage!]
        }

        // 화면 닫기
        self.dismiss(animated: true, completion: nil)

        if let resultVC = self.storyboard?.instantiateViewController(identifier: "ResultViewController"){
            // Notification Center
            resultVC.modalTransitionStyle = .crossDissolve
            resultVC.modalPresentationStyle = .fullScreen
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

extension ViewController {
        /**
        카메라 접근 권한 판별하는 함수
        */
       func cameraAuth() {
           AVCaptureDevice.requestAccess(for: .video) { granted in
               if granted {
                   print("권한 허용")
                   DispatchQueue.main.async {
                       self.openCamera()
                   }
               } else {
                   print("권한 거부")
                   DispatchQueue.main.async {
                       self.showAlertAuth("카메라")
                   }
               }
           }
       }
    
       /**
        라이브러리 접근 권한 판별하는 함수
        */
       func albumAuth() {
           switch PHPhotoLibrary.authorizationStatus() {
           case .denied:
               print("거부")
               self.showAlertAuth("라이브러리")
           case .authorized:
               print("허용")
               self.openPhotoLibrary()
           case .notDetermined, .restricted:
               print("아직 결정하지 않은 상태")
               PHPhotoLibrary.requestAuthorization { state in
                   if state == .authorized {
                       self.openPhotoLibrary()
                   } else {
                       DispatchQueue.main.async {
                           self.dismiss(animated: true, completion: nil)
                       }
                   }
               }
           default:
               break
           }
       }

       /**
        권한을 거부했을 때 띄어주는 Alert 함수
        - Parameters:
        - type: 권한 종류
        */
       func showAlertAuth(
           _ type: String
       ) {
           if let appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String {
               let alertVC = UIAlertController(
                   title: "설정",
                   message: "\(appName)이(가) \(type) 접근 허용되어 있지 않습니다. 사진 변환 기능을 사용하기 위해서는 \(type) 접근이 허용되어 있어야 합니다. 설정화면으로 이동하시겠습니까?",
                   preferredStyle: .alert
               )
               let cancelAction = UIAlertAction(
                   title: "취소",
                   style: .cancel,
                   handler: nil
               )
               let confirmAction = UIAlertAction(title: "이동하여 허가", style: .default) { _ in
                   UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
               }
               alertVC.addAction(cancelAction)
               alertVC.addAction(confirmAction)
               self.present(alertVC, animated: true, completion: nil)
           }
       }
       
       /**
        아이폰에서 라이브러리에 접근하는 함수
        */
       private func openPhotoLibrary() {
           if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
               DispatchQueue.main.async {
                   self.imagePicker.sourceType = .photoLibrary
                   self.imagePicker.modalPresentationStyle = .currentContext
                   self.imagePicker.mediaTypes = [kUTTypeImage as String] // 미디어 형태, MobileCoreServices에 정의되어 있다.
                   self.imagePicker.allowsEditing = false
                   self.present(self.imagePicker, animated: true, completion: nil)
               }
           } else {
               print("라이브러리에 접근할 수 없습니다.")
           }
       }

       /**
        아이폰에서 카메라에 접근하는 함수
        */
       private func openCamera() {
           if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
               self.imagePicker.sourceType = .camera
               self.imagePicker.modalPresentationStyle = .currentContext
               self.imagePicker.mediaTypes = [kUTTypeImage as String] // 미디어 형태, MobileCoreServices에 정의되어 있다.
               self.imagePicker.allowsEditing = false
               self.present(self.imagePicker, animated: true, completion: nil)
           } else {
               print("카메라에 접근할 수 없습니다.")
           }
       }
}


// 배너뷰 관련
extension ViewController: GADBannerViewDelegate {
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
        // 화면에 배너뷰 추가
        
        addBannerViewToView(bannerView)
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
