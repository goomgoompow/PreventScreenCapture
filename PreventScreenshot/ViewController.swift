//
//  ViewController.swift
//  PreventScreenshot
//
//  Created by Eric Yang on 19/9/20.
//

import UIKit
import Photos

class ViewController: UIViewController {
    let images: [UIImage] = [UIImage(named: "selfie1")!,
                             UIImage(named: "selfie2")!,
                             UIImage(named: "selfie3")!,
                             UIImage(named: "selfie4")!]
    enum Section {
        case main
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        if #available(iOS 14.0, *){
            configureDataSource()
        }
        //requestGalleryPermission()
        print("viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        requestGalleryPermission()
        NotificationCenter.default.addObserver(self, selector: #selector(onResume), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func onResume(){
        requestGalleryPermission()
    }
    
    func requestCameraPermission(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if granted {
                print("Camera: 권한 허용")
            } else {
                print("Camera: 권한 거부")
            }
        })
    }
    
    func requestGalleryPermission(){
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite){
                status in
                switch status {
                case .authorized:
                    print("authorized")
                case .limited , .denied, .notDetermined, .restricted:
                    print("limited access granted")
                    DispatchQueue.background(completion: self.setAuthAlert)
                default:
                    break
                }
            }
        } else {
            // Fallback on earlier versions
            PHPhotoLibrary.requestAuthorization({
                status in
                switch status {
                case .authorized:
                    print("authorized")
                case .limited , .denied, .notDetermined, .restricted:
                    print("limited access granted")
                    DispatchQueue.background(completion: self.setAuthAlert)
                default:
                    break
                }
            })
        }
    }
    
    func setAuthAlert(){
        let authAlertController : UIAlertController
            = UIAlertController(title: "사진첩 접근 권한 요청", message: "사진 접근 허용을 '모든 사진'으로 허용해야 앱을 사용할 수 있습니다.\n(스크린 캡쳐시 해당 파일 삭제하기 위함)", preferredStyle: .alert)
        let authAction : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings, options: [:] , completionHandler: nil)
            }
        })
        authAlertController.addAction(authAction)
        self.present(authAlertController, animated: true, completion: nil)
        
    }
}

extension ViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                             heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .black
        view.addSubview(collectionView)
    }
    @available(iOS 14.0, *)
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ImageCollectionViewCell, Int> { (cell, indexPath, identifier) in
            // Populate the cell with image
            cell.configure(image: self.images[indexPath.row % 4])
        }
      

        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<100))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

