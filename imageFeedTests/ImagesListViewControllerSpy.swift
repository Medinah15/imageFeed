//
//  ImagesListViewControllerSpy.swift
//  imageFeedTests
//
//  Created by Medina Huseynova on 22.05.25.
//

import Foundation
import imageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    var insertRowsCalled = false
    var updateLikeButtonCalled = false
    var showLikeErrorAlertCalled = false
    var configuredCell: (cell: ImagesListCell, photo: Photo, delegate: ImagesListCellDelegate?)?
    
    var presenter: imageFeed.ImagesListPresenterProtocol?
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
    }
    
    func updateLikeButton(at indexPath: IndexPath, isLiked: Bool) {
        updateLikeButtonCalled = true
    }
    
    func showLikeErrorAlert() {
        showLikeErrorAlertCalled = true
    }
    
    func configureCell(_ cell: ImagesListCell, with photo: Photo, delegate: ImagesListCellDelegate?) {
        configuredCell = (cell, photo, delegate)
    }
}

