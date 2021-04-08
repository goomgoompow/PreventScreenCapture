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
        configureDataSource()
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
        PHPhotoLibrary.requestAuthorization({status in
            switch status{
            case .authorized:
                print("Gallery: 권한 추가")
            case .denied,.restricted, .notDetermined:
                print("Gallery: 권한 거부")
                print("Galleru: 선택하지 않음")
                DispatchQueue.background(completion: self.setAuthAlert)
                //self.setAuthAlert()
            default:
                break
            }
        })
    }
    
    func setAuthAlert(){
        let authAlertController : UIAlertController
            = UIAlertController(title: "사진첩 접근 권한 요청", message: "사진첩 권한을 허용해야만 앱을 사용할 수 있습니다.", preferredStyle: .alert)
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

