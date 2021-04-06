//
//  ScreenRecordingProtector.swift
//  PreventScreenshot
//
//  Created by WonHo Choe on 2021/04/05.
//

import UIKit

class ScreenRecordingProtector {
    
    
    private var window: UIWindow?{
        if #available(iOS 13.0, *){
            return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
        }
        return (UIApplication.shared.delegate as? AppDelegate)?.window
    }
    
    func startPreventing(){
        NotificationCenter.default.addObserver(self, selector: #selector(preventScreenshoot), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    func startPreventingScreenshot() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    
    @objc private func preventScreenshoot(){
        if #available(iOS 13.0, *){
            if UIScreen.main.isCaptured {
                window?.isHidden = true
            }else{
                window?.isHidden = false
            }
        }
    }
    
    @objc private func didDetectScreenshot() {
        DispatchQueue.main.async {
            self.hideScreen()
            //self.presentwarningWindow("Screen recording is not allowed in our app!")
        }
    }
    
    private func hideScreen() {
        if UIScreen.main.isCaptured {
            window?.isHidden = true
        } else {
            window?.isHidden = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
