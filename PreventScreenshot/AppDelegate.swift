//
//  AppDelegate.swift
//  PreventScreenshot
//
//  Created by Eric Yang on 19/9/20.
//

import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let screenProtecter = ScreenProtector()
    private let screenRecoding = ScreenRecordingProtector()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

          screenProtecter.startPreventingRecording()
        screenProtecter.startPreventingScreenshot()
//        screenProtecter.foo()
        
//        NotificationCenter.default.addObserver(forName:UIApplication.userDidTakeScreenshotNotification, object: nil, queue: nil, using: applicationUserDidTakeScreenshot)
//        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground");
    }
    
   

}

extension AppDelegate{
    func applicationUserDidTakeScreenshot(_ notification: Notification) {
        guard let keyWindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}),
              let rootVC = keyWindow.rootViewController
              else {
            return
        }
        let alert = UIAlertController(title:"스크린샷 감지", message: "스크린샷이 감지 되었습니다.",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                rootVC.present(alert, animated: true, completion: nil)

    }
}
