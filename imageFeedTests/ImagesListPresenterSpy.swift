//
//  ImagesListPresenterSpy.swift
//  imageFeedTests
//
//  Created by Medina Huseynova on 22.05.25.
//

import imageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    var photos: [imageFeed.Photo] = []
    var viewDidLoadCalled = false
    var willDisplayCellCalled = false
    var didTapLikeCalled = false
    var configuredCellIndexPath: IndexPath?
    
    var view: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableViewAnimated() {
        
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalled = true
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func configure(_ cell: ImagesListCell, at indexPath: IndexPath) {
        configuredCellIndexPath = indexPath
    }
}

