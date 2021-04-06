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
            case .denied:
                print("Gallery: 권한 거부")
            case .restricted, .notDetermined:
                print("Galleru: 선택하지 않음")
            default:
                break
            }
        })
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

