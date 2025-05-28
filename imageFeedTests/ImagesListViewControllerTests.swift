//
//  ImagesListViewControllerTests.swift
//  imageFeedTests
//
//  Created by Medina Huseynova on 22.05.25.
//

@testable import imageFeed
import XCTest


final class ImagesListViewControllerTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsConfigureCell() {
        // given
        let cell = ImagesListCell()
        let presenter = ImagesListPresenterSpy()
        
        // when
        presenter.configure(cell, at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertEqual(presenter.configuredCellIndexPath, IndexPath(row: 0, section: 0))
    }
    
    func testPresenterCallsWillDisplayCell() {
        // given
        let presenter = ImagesListPresenterSpy()
        presenter.willDisplayCell(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(presenter.willDisplayCellCalled)
    }
    
    func testPresenterCallsDidTapLike() {
        // given
        let presenter = ImagesListPresenterSpy()
        
        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(presenter.didTapLikeCalled)
    }
    
    func testViewControllerShowsLikeErrorAlert() {
        // given
        let spy = ImagesListViewControllerSpy()
        
        // when
        spy.showLikeErrorAlert()
        
        // then
        XCTAssertTrue(spy.showLikeErrorAlertCalled)
    }
    
    func testViewControllerUpdatesLikeButton() {
        // given
        let spy = ImagesListViewControllerSpy()
        
        // when
        spy.updateLikeButton(at: IndexPath(row: 0, section: 0), isLiked: true)
        
        // then
        XCTAssertTrue(spy.updateLikeButtonCalled)
    }
}

