//
//  ScreenProtector.swift
//  PreventScreenshot
//
//  Created by Eric Yang on 19/9/20.
//

import UIKit
import Photos


class ScreenProtector {
    private var warningWindow: UIWindow?

    private var window: UIWindow? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
    }

    func startPreventingRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    }

    func startPreventingScreenshot() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    @objc private func didBecomeActiveNoti(){
        
    }
    
    @objc private func didEnterBackgroundNotification(){
        
    }
    
    @objc private func willResignActiveNotification(){
        
    }
    
    @objc private func screenCaptureChanged(){
        DispatchQueue.main.async {
            self.hideScreen()
            self.presentwarningWindow("Screen recording is not allowed in our app!")
        }
    }
    
    @objc private func didDetectRecording() {
        DispatchQueue.main.async {
            self.hideScreen()
            self.presentwarningWindow("Screen recording is not allowed in our app!")
        }
    }

@objc private func didDetectScreenshot() {
    print("print didDetectScreenshot----")
    DispatchQueue.background(completion: {
        self.presentwarningWindow( "보안 정책에 따라 화면을 캡쳐할 수 없습니다. 캡쳐된 이미지를 삭제해주세요!")
                self.hideScreen()
                //self.grandAccessAndDeleteTheLastPhoto()
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: self.grandAccessAndDeleteTheLastPhoto)
    })
}

    private func hideScreen() {
        if UIScreen.main.isCaptured {
            window?.isHidden = true
        } else {
            window?.isHidden = false
        }
    }
    
    private func presentwarningWindow(_ message: String) {
        // Remove exsiting
        warningWindow?.removeFromSuperview()
        warningWindow = nil

        guard let frame = window?.bounds else { return }

        // Warning label
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.text = message

        // warning window
        var warningWindow = UIWindow(frame: frame)

        let windowScene = UIApplication.shared
            .connectedScenes
            .first {
                $0.activationState == .foregroundActive
            }
        if let windowScene = windowScene as? UIWindowScene {
            warningWindow = UIWindow(windowScene: windowScene)
        }

        warningWindow.frame = frame
        warningWindow.backgroundColor = .black
        warningWindow.windowLevel = UIWindow.Level.statusBar + 1
        warningWindow.clipsToBounds = true
        warningWindow.isHidden = false
        warningWindow.addSubview(label)

        self.warningWindow = warningWindow

        UIView.animate(withDuration: 0.15) {
            label.alpha = 1.0
            label.transform = .identity
        }
        warningWindow.makeKeyAndVisible()
    }
    
    func grandAccessAndDeleteTheLastPhoto() {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        if(fetchResult.lastObject != nil){
            let lastAsset  = fetchResult.lastObject! as PHAsset
            let arrayToDelete = NSArray(object: lastAsset)
            deletePhoto(arrayToDelete)
        }
        self.hideScreen()
    }
    
    func deletePhoto(_ array : NSArray) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(array)},
                completionHandler: { [self]
                success, error in
                //NSLog("Finished deleting asset. %@", (success ? "Success" : error!))
                print("success: @ , error: @", success, error)
                if !success {
                    self.deletePhoto(array)
                }else{
                    DispatchQueue.background(completion: {
                        warningWindow?.removeFromSuperview()
                        warningWindow = nil
                    })
                }
            })
    }
    
    
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0 , background :(()->Void)? = nil, completion:(()->Void)? = nil ){
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion{
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
