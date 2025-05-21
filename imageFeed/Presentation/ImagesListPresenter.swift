//
//  ImagesListPresenter.swift
//  imageFeed
//
//  Created by Medina Huseynova on 21.05.25.
//

import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    func viewDidLoad()
    func updateTableViewAnimated()
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
    func configure(_ cell: ImagesListCell, at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    private let service = ImagesListService.shared
    private let helper: ImagesListHelper
    
    init(view: ImagesListViewControllerProtocol, helper: ImagesListHelper) {
        self.view = view
        self.helper = helper
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        service.fetchPhotosNextPage()
    }
    
    @objc func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = service.photos
        guard newPhotos.count > oldCount else { return }
        
        let indexPaths = (oldCount..<newPhotos.count).map {
            IndexPath(row: $0, section: 0)
        }
        
        photos = newPhotos
        view?.insertRows(at: indexPaths)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            service.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        service.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success:
                    
                    self.photos = self.service.photos
                    
                    let newPhoto = self.photos[indexPath.row]
                    self.view?.updateLikeButton(at: indexPath, isLiked: newPhoto.isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    self.view?.showLikeErrorAlert()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configure(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        view?.configureCell(cell, with: photo, delegate: view as? ImagesListCellDelegate)// делегируем UI на ViewController
    }
}
